# web/controllers/user_controller
defmodule ExClusterWeb.DefaultController do
  use ExClusterWeb, :controller

  def index(conn, _params) do
    nodes = Node.list()
    self = Node.self()
    json(conn, %{"self" => self, "nodes" => nodes})
  end
end