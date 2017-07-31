defmodule Pxblog.Router do
  use Pxblog.Web, :router



  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers



  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Pxblog do
    pipe_through :browser # Use the default browser stack
    resources "/posts", PostController
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create]
    get "/", PageController, :index
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Signed out succesfully!")
    |> redirect(to: page_path(conn, :index))
  end

  # Other scopes may use custom stacks.
  # scope "/api", Pxblog do
  #   pipe_through :api
  # end
end
