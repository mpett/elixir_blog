defmodule Pxblog.SessionController do
  use Pxblog.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2]

  plug :scrub_params, "user" when action in [:create]

  alias Pxblog.User

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  def create(conn, %{"user" => user_params}) do
    Repo.get_by(User, username: user_params["username"])
    |> sign_in(user_params["password"], conn)
  end

  defp sign_in(user, password, conn) when is_nil(user) do
    conn
    |> put_flash(:error, "We are sorry. This is an invalid combination of your user name and password. Maybe next time around?")
    |> redirect(to: page_path(conn, :index))
  end

  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username})
      |> put_flash(:info, "Congratulations and Welcome! The sign in was successful.")
      |> redirect(to: page_path(conn, :index))
    else
      conn
      |> put_session(:current_user, nil)
      |> put_flash(:error, "We are sorry. This is an invalid combination of your user name and password. Maybe next time around?")
      |> redirect(to: page_path(conn, :index))
    end
  end
end
