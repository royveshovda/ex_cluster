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
    get "/connect", DefaultController, :connect
    get "/connect2", DefaultController, :connect2
  end
end
