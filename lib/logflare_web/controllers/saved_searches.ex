defmodule LogflareWeb.SavedSearchesController do
  use LogflareWeb, :controller
  alias Logflare.SavedSearches

  plug LogflareWeb.Plugs.SetVerifySource
       when action in [:delete]

  def delete(conn, %{"id" => search_id} = _params) do
    saved_search =
      Enum.find(conn.assigns.source.saved_searches, fn x ->
        x.id == String.to_integer(search_id)
      end)

    case SavedSearches.delete(saved_search) do
      {:ok, _response} ->
        conn
        |> put_flash(:info, "Saved search deleted!")
        |> redirect(to: Routes.source_path(conn, :dashboard))

      {:error, _response} ->
        conn
        |> put_flash(:error, "Something went wrong!")
        |> redirect(to: Routes.source_path(conn, :dashboard))
    end
  end
end