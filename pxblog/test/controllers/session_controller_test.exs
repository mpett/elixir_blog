defmodule Pxblog.SessionControllerTest do
  use Pxblog.ConnCase
  alias Pxblog.User

  setup do
    User.changeset(%User{}, %{username: "test", password: "test", password_confirmation: "test", email: "test@test.com"})
    |> Repo.insert
    {:ok, conn: build_conn()}
  end

  test "shows the login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "creates a new user session for a valid user", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "test", password: "test"}
    assert get_session(conn, :current_user)
    assert get_flash(conn, :info) == "Congratulations and Welcome! The sign in was successful."
    assert redirected_to(conn) == page_path(conn, :index)
  end

  test "does not create a session with a bad login", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "test", password: "wrong"}
    refute get_session(conn, :current_user)
    assert get_flash(conn, :error) == "We are sorry. This is an invalid combination of your user name and password. Maybe next time around?"
    assert redirected_to(conn) = page_path(conn, :index)
  end

  test "does not create a session if user does not exist", %{conn: conn} do
    conn = post conn, session_path(conn, :create), user: %{username: "foo", password: "wrong"}
    assert get_flash(conn, :error) == "We are sorry. This is an invalid combination of your user name and password. Maybe next time around?"
    assert redirected_to(conn) == page_path(conn, :index)
  end
end
