# web/controllers/user_controller
require Logger

defmodule ExClusterWeb.DefaultController do
  use ExClusterWeb, :controller

  def index(conn, _params) do
    nodes = Node.list()
    nodes2 = :epmdless_dist.list_nodes()
    self = Node.self()
    json(conn, %{"self" => self, "nodes" => nodes, "nodes2" => inspect(nodes2)})
  end


  def env(conn, _params) do
    envs = System.get_env()
    json(conn, %{"environment" => envs})
  end

  def ips(conn, _params) do
    {:ok, ips_raw} = :inet.getif()
    ips = ips_raw |> Enum.map(fn {i,_,_} -> to_string(:inet.ntoa(i)) end)
    json(conn, %{"ips" => ips})
  end

  def ecs(conn, _params) do
    ip =
      System.fetch_env!("ECS_CONTAINER_METADATA_URI")
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
      |> Map.get("Networks")
      |> List.first
      |> Map.get("IPv4Addresses")
      |> List.first

    nodes =
      System.fetch_env!("SERVICE_NAME")
      |> to_charlist
      |> :inet_res.lookup(:in, :a)
      |> Enum.map(fn i -> :inet_parse.ntoa(i) end)
      |> Enum.map(fn i -> to_string(i) end)
      |> Enum.filter(fn i -> i != ip end)

    meta =
      System.fetch_env!("ECS_CONTAINER_METADATA_URI")
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()

    # "nrk.no" |> to_charlist() |> :inet_res.lookup(:in, :a) |> List.first() |> :inet_parse.ntoa |> to_string()
    
    json(conn, %{"ip" => ip, "nodes" => nodes, "meta" => meta})
  end

  def ping_all(conn, _params) do
    ip =
      System.fetch_env!("ECS_CONTAINER_METADATA_URI")
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
      |> Map.get("Networks")
      |> List.first
      |> Map.get("IPv4Addresses")
      |> List.first

    nodes =
      System.fetch_env!("SERVICE_NAME")
      |> to_charlist
      |> :inet_res.lookup(:in, :a)
      |> Enum.map(fn i -> :inet_parse.ntoa(i) end)
      |> Enum.map(fn i -> to_string(i) end)
      |> Enum.filter(fn i -> i != ip end)

    results = 
      nodes
      |> Enum.map(fn i -> ping(i) end)

    json(conn, %{"nodes" => nodes, "results" => results})
  end

  defp ping(ip) do
    {:ok, adr} = :inet.parse_address(to_charlist(ip))
    {:ok, {:hostent, name, _, :inet, 4, _}} = :inet.gethostbyaddr(adr)
    node = String.to_atom("ex_cluster@" <> to_string(name))
    :net_adm.ping(node)
  end

  def connect_all(conn, _params) do
    ip =
      System.fetch_env!("ECS_CONTAINER_METADATA_URI")
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
      |> Map.get("Networks")
      |> List.first
      |> Map.get("IPv4Addresses")
      |> List.first

    nodes =
      System.fetch_env!("SERVICE_NAME")
      |> to_charlist
      |> :inet_res.lookup(:in, :a)
      |> Enum.map(fn i -> :inet_parse.ntoa(i) end)
      |> Enum.map(fn i -> to_string(i) end)
      |> Enum.filter(fn i -> i != ip end)

    results = 
      nodes
      |> Enum.map(fn n -> connect(n) end)

    json(conn, %{"status" => "ok", "nodes" => nodes, "results" => results})
  end

  defp connect(ip) do
    {:ok, adr} = :inet.parse_address(to_charlist(ip))
    {:ok, {:hostent, name, _, :inet, 4, _}} = :inet.gethostbyaddr(adr)

    node = String.to_atom("ex_cluster@" <> to_string(name))
    :epmdless_dist.add_node(node, 17012)
  end

  def connect_all2(conn, _params) do
    result = 
      ["node1.local", "node2.local", "node3.local"]
      |> Enum.map(fn n -> connect2(n) end)
    json(conn, %{"status" => "ok", "results" => result})
  end

  defp connect2(name) do
    node = String.to_atom("ex_cluster@" <> name)
    :epmdless_dist.add_node(node, 17012)
  end

  def ping_all2(conn, _params) do
    result = 
      ["node1.local", "node2.local", "node3.local"]
      |> Enum.map(fn n -> ping2(n) end)
    json(conn, %{"status" => "ok", "results" => result})
  end

  defp ping2(name) do
    node = String.to_atom("ex_cluster@" <> name)
    :net_adm.ping(node)
  end
end