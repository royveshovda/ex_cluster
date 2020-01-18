defmodule ExClusterWeb.Router do
  use ExClusterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExClusterWeb do
    pipe_through :api
    get "/", DefaultController, :index
  end
end
