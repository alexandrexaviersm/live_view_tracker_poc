defmodule LiveViewTrackerPocWeb.TrackerDashboardLive do
  use LiveViewTrackerPocWeb, :live_view

  alias LiveViewTrackerPoc.PIDTracker
  alias LiveViewTrackerPoc.PubSub

  @topic "reload"

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(PubSub, @topic)

    socket = assign_entries(socket)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>LiveView Tracker</h1>
    <div id="processes">
      <h2>Processes</h2>
      <%= for {_key, process} <- @entries do %>
        <button phx-click="show-info" phx-value-id={process.id}>
          <%= "#{inspect(process.pid)} =>" %>
          <%= "#{process.name}" %>
        </button>
        <br>
      <% end %>
    </div>

    <div id="events">
      <h2>Events History</h2>
        <%= inspect(@pid_events) %>
    </div>

    <div id="diff">
      <h2>Diff History</h2>
        <%= inspect(@pid_diffs) %>
    </div>

    <div id="info">
      <h2>Processes Info</h2>
        <%= inspect(@pid_state) %>
        <%= inspect(@pid_state) %>
    </div>
    """
  end

  def handle_event("show-info", %{"id" => id}, socket) do
    process = Map.get(socket.assigns.entries, String.to_integer(id)) |> IO.inspect()

    socket =
      assign(socket,
        pid_events: process.event_history,
        pid_diffs: process.diff_history,
        pid_state: :sys.get_state(process.pid),
        pid_status: :sys.get_status(process.pid)
      )

    {:noreply, socket}
  end

  def handle_info(:reload, socket) do
    socket = assign_entries(socket)

    {:noreply, socket}
  end

  defp assign_entries(socket) do
    socket
    |> assign(:entries, PIDTracker.list())
    |> assign(:pid_events, nil)
    |> assign(:pid_diffs, nil)
    |> assign(:pid_state, nil)
    |> assign(:pid_status, nil)
  end
end
