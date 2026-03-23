defmodule PokeqlWeb.DocsController do
  use PokeqlWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/docs/index.html")
  end
end
