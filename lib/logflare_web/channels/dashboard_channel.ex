defmodule LogflareWeb.DashboardChannel do
  @moduledoc false
  use LogflareWeb, :channel
  alias Logflare.Source.LocalStore

  def join("dashboard:" <> source_token, _payload, socket) do
    cond do
      is_admin?(socket) ->
        LocalStore.broadcast_on_join(String.to_atom(source_token))
        {:ok, socket}

      has_source?(source_token, socket) ->
        LocalStore.broadcast_on_join(String.to_atom(source_token))
        {:ok, socket}

      true ->
        {:error, %{reason: "Not authorized!"}}
    end
  end

  intercept ["log_count"]

  def handle_out("log_count", msg, socket) do
    push(socket, "log_count", msg)
    {:noreply, socket}
  end

  intercept ["buffer"]

  def handle_out("buffer", msg, socket) do
    push(socket, "buffer", msg)
    {:noreply, socket}
  end

  intercept ["rate"]

  def handle_out("rate", msg, socket) do
    push(socket, "rate", msg)
    {:noreply, socket}
  end

  defp has_source?(source_token, socket) do
    Enum.map(socket.assigns[:user].sources, & &1.token)
    |> Enum.member?(String.to_existing_atom(source_token))
  end

  defp is_admin?(socket) do
    socket.assigns[:user].admin
  end
end
