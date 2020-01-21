defmodule ClusterFinder do
  def poll() do
    ip = fetch_own_ip()
    iid = fetch_image_id()

    nodes =
      fetch_all_node_ips()
      |> Enum.filter(fn i -> i != ip end)
      |> Enum.map(fn i -> fetch_id(i) end)
      |> Enum.filter(fn n -> n["imageID"] == iid end)
      |> Enum.map(fn n -> n["node"] end)
      |> Enum.map(fn n -> String.to_atom(n) end)
    
    nodes
    #[]
  end

  defp fetch_metadata() do
    System.fetch_env!("ECS_CONTAINER_METADATA_URI")
      |> HTTPoison.get!
      |> (fn res -> Poison.decode!(res.body) end).()
  end

  def fetch_id(ip) do
    url = "http://" <> ip <> "/id"
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode!(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{"imageID" => "unknown", "node" => "unknown"}
      {:error, %HTTPoison.Error{reason: _reason}} ->
        %{"imageID" => "error", "node" => "error"}
      _ ->
        %{"imageID" => "error", "node" => "very wrong"}
    end
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