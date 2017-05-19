defmodule RealWorld.Web.ProfileController do
  use RealWorld.Web, :controller
  use Guardian.Phoenix.Controller

  alias RealWorld.Accounts.{Users, User}

  action_fallback RealWorld.Web.FallbackController

  plug Guardian.Plug.EnsureAuthenticated, %{handler: RealWorld.Web.SessionController} when action in [:follow, :unfollow]

  def show(conn, %{"username" => username}, current_user, _) do
    case Users.get_by_username(username) do
      user = %User{} ->
        conn
        |> put_status(:ok)
        |> render("show.json", user: user, following: Users.is_following?(current_user, user))
      nil ->
        conn
        |> put_status(:not_found)
        |> render(RealWorld.Web.ErrorView, "404.json")
    end
  end

  def follow(conn, %{"username" => username}, current_user, _) do
    case Users.get_by_username(username) do
      follower = %User{} ->
        current_user
        |> Users.follow(follower)

        conn
        |> put_status(:ok)
        |> render("show.json", user: follower, following: Users.is_following?(current_user, follower))
      nil ->
        conn
        |> put_status(:not_found)
        |> render(RealWorld.Web.ErrorView, "404.json")
    end
  end

  def unfollow(conn, %{"username" => username}, current_user, _) do
    case Users.get_by_username(username) do
      follower = %User{} ->
        current_user
        |> Users.unfollow(follower)

        conn
        |> put_status(:ok)
        |> render("show.json", user: follower, following: Users.is_following?(current_user, follower))
      nil ->
        conn
        |> put_status(:not_found)
        |> render(RealWorld.Web.ErrorView, "404.json")
    end
  end

end
