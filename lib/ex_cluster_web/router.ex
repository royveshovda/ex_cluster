defmodule ExClusterWeb.Router do
  use ExClusterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExClusterWeb do
    pipe_through :api
    get "/", DefaultController, :index
    get "/env", DefaultController, :env
    get "/ips", DefaultController, :ips
    get "/ecs", DefaultController, :ecs
    get "/connect", DefaultController, :connect_all
    get "/ping", DefaultController, :ping_all
    get "/connect2", DefaultController, :connect_all2
    get "/ping2", DefaultController, :ping_all2
  end
end
