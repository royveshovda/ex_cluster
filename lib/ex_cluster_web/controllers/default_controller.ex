# web/controllers/user_controller
require Logger

defmodule ExClusterWeb.DefaultController do
  use ExClusterWeb, :controller

  def index(conn, _params) do
    nodes = Node.list()
    nodes2 = :epmdless_dist.list_nodes()
    self = Node.self()
    imageid = fetch_image_id()
    
    json(conn, %{"self" => self, "nodes" => nodes, "nodes2" => inspect(nodes2), "imageID" => imageid})
  end

  def id(conn, _params) do
    node = Node.self()
    ip = fetch_own_ip()
    imageid = fetch_image_id()
    
    json(conn, %{"node" => node, "imageID" => imageid, "ip" => ip})
  end

  def ecs(conn, _params) do
    ip = fetch_own_ip()

    nodes =
      fetch_all_node_ips()
      |> Enum.filter(fn i -> i != ip end)

    meta = fetch_metadata()

    taskmeta =
      System.fetch_env!("ECS_CONTAINER_METADATA_URI")<>"/task"
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
    
    json(conn, %{"ip" => ip, "nodes" => nodes, "meta" => meta, "taskmeta" => taskmeta})
  end

  def ping_all(conn, _params) do
    ip = fetch_own_ip()

    nodes =
      fetch_all_node_ips()
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
    ip = fetch_own_ip()
    iid = fetch_image_id()

    nodes = 
      fetch_all_node_ips()
      |> Enum.filter(fn i -> i != ip end)
      |> Enum.map(fn i -> fetch_id(i) end)
      |> Enum.filter(fn n -> n["imageID"] == iid end)
      |> Enum.map(fn n -> n["node"] end)
    
    results = 
      nodes
      |> Enum.map(fn n -> connect_node(n) end)

    # TODO: Handle errors

    json(conn, %{"status" => "ok", "nodes" => nodes, "results" => inspect(results)})
  end

  #defp connect_ip(ip) do
  #  {:ok, adr} = :inet.parse_address(to_charlist(ip))
  #  {:ok, {:hostent, name, _, :inet, 4, _}} = :inet.gethostbyaddr(adr)
  #  node = String.to_atom("ex_cluster@" <> to_string(name))
  #  :epmdless_dist.add_node(node, 17012)
  #  #Node.connect(node)
  #end

  defp connect_node(name) do
    node = String.to_atom(name)
    :epmdless_dist.add_node(node, 17012)
    #Node.connect(node)
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

  def all_ids(conn, _params) do
    nodes =
      fetch_all_node_ips()
      |> Enum.map(fn i -> fetch_id(i) end)

      json(conn, %{"nodes" => nodes})
  end

  def fetch_id(ip) do
    "http://" <> ip <> "/id"
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
  end

  defp fetch_metadata() do
    System.fetch_env!("ECS_CONTAINER_METADATA_URI")
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
  end

  defp fetch_own_ip() do
    fetch_metadata()
      |> Map.get("Networks")
      |> List.first
      |> Map.get("IPv4Addresses")
      |> List.first
  end

  defp fetch_all_node_ips() do
    System.fetch_env!("SERVICE_NAME")
      |> to_charlist
      |> :inet_res.lookup(:in, :a)
      |> Enum.map(fn i -> :inet_parse.ntoa(i) end)
      |> Enum.map(fn i -> to_string(i) end)
  end

  defp fetch_image_id() do
    fetch_metadata()
      |> Map.get("ImageID")
  end
end