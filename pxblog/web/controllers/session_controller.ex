defmodule Pxblog.SessionController do
  use Pxblog.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  plug :scrub_params, "user" when action in [:create]

  alias Pxblog.User

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end

  defp failed_login(conn) do
    dummy_checkpw()
    conn
    |> put_session(:current_user, nil)
    |> put_flash(:error, "We are sorry. This is an invalid combination of your user name and password. Maybe next time around?")
    |> redirect(to: page_path(conn, :index))
    |> halt()
  end

  defp sign_in(user, _password, conn) when is_nil(user) do
    failed_login(conn)
  end

  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username})
      |> put_flash(:info, "Congratulations and Welcome! The sign in was successful.")
      |> redirect(to: page_path(conn, :index))
    else
      failed_login(conn)
    end
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}})
  when not is_nil(username) and not is_nil(password) do
    user = Repo.get_by(User, username: username)
    sign_in(user, password, conn)
  end

  def create(conn, _) do
    failed_login(conn)
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Signed out successfully!")
    |> redirect(to: page_path(conn, :index))
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
