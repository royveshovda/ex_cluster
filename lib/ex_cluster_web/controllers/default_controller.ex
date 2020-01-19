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

    # "nrk.no" |> to_charlist() |> :inet_res.lookup(:in, :a) |> List.first() |> :inet_parse.ntoa |> to_string()
    
    json(conn, %{"ip" => ip, "nodes" => nodes})
  end

  def connect(conn, _params) do
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

    first = nodes |> List.first
    IO.inspect(first)

    {:ok, adr} = :inet.parse_address(to_charlist(first))
    #IO.inspect(adr)
    #{:ok, {:hostent, name, _, :inet, 4, _}} = :inet.gethostbyaddr(adr)
    {:ok, {:hostent, name, _, :inet, 4, _}} = :inet.gethostbyaddr(adr)
    #res = :inet.gethostbyaddr(adr)
    #IO.inspect(name)


    n = "ex_cluster@" <> to_string(name)

    #res = Node.connect(String.to_atom(n))
    res = :epmdless_dist.add_node(String.to_atom(n), 17012)

    #json(conn, %{"status" => "ok", "node" => n})
    json(conn, %{"status" => "ok", "adr" => inspect(adr), "node" => n, "result" => inspect(res)})
  end

  def connect2(conn, _params) do
    res = :epmdless_dist.add_node(:"ex_cluster@node2.local", 17013)
    :epmdless_dist.add_node(:"ex_cluster@node3.local", 17014)
    #res2 = :epmdless.list_nodes()
    res2 = :epmdless_dist.list_nodes()

    #json(conn, %{"status" => "ok", "node" => n})
    json(conn, %{"status" => "ok", "result" => inspect(res), "result2" => inspect(res2)})
  end
end