defmodule ExClusterWeb.Router do
  use ExClusterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExClusterWeb do
    pipe_through :api
    get "/", DefaultController, :index
    get "/id", DefaultController, :id
    get "/ecs", DefaultController, :ecs
    get "/connect", DefaultController, :connect_all
    get "/ping", DefaultController, :ping_all
    get "/all_ids", DefaultController, :all_ids
  end
end
