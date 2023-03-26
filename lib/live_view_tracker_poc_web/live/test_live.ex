defmodule LiveViewTrackerPocWeb.TestLive do
  use LiveViewTrackerPocWeb, :live_view

  alias LiveViewTrackerPoc.PubSub

  @topic "lv_starts"
  @topic_events "lv_events"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.broadcast(PubSub, @topic, {:pid, %{pid: self(), name: socket.view}})
    end

    socket =
      attach_hook(socket, :my_hook, :handle_event, fn
        "track-diff", params, socket ->
          Phoenix.PubSub.broadcast(
            PubSub,
            @topic_events,
            {:diff, %{params: params, pid: self()}}
          )

          {:halt, socket}

        event, params, socket ->
          Phoenix.PubSub.broadcast(
            PubSub,
            @topic_events,
            {:event, %{name: event, pid: self(), params: params}}
          )

          {:cont, socket}
      end)

    socket = assign(socket, number: 1, class: "true")

    {:ok, socket}
  end

  def render(assigns) do
    h = ~H"""
    <div>Test</div>

    <button phx-click="click" class={@class}>
      Counter: <%= convert(@number) %>
    </button>

    <div id="diff" phx-hook="TrackDiff"></div>
    """

    h |> IO.inspect(label: :heex)
    h.static |> IO.inspect(label: :static)

    dynamic = h.dynamic.(assigns)
    IO.inspect(dynamic, label: :dynamic)

    h
  end

  def handle_event("click", _, socket) do
    socket = update(socket, :number, &(&1 + 1))
    socket = assign(socket, class: change(socket.assigns.class))

    {:noreply, socket}
  end

  defp convert(1), do: "One"
  defp convert(2), do: "Two"
  defp convert(3), do: "Three"
  defp convert(4), do: "Four"
  defp convert(5), do: "Five"
  defp convert(6), do: "Six"
  defp convert(number), do: number

  defp change("true"), do: "false"
  defp change("false"), do: "true"
end
