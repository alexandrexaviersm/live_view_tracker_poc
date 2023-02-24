defmodule LiveViewTrackerPoc.PIDTracker do
  use GenServer

  alias LiveViewTrackerPoc.PubSub
  alias LiveViewTrackerPoc.Processes

  @topic "lv_starts"
  @reload_topic "reload"
  @topic_events "lv_events"

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: :tracker)
  end

  def list do
    GenServer.call(:tracker, :list)
  end

  def get_state(pid) do
    GenServer.call(:tracker, {:get_state, pid})
  end

  def get_status(pid) do
    GenServer.call(:tracker, {:get_status, pid})
  end

  # Server (callbacks)

  @impl true
  def init(_init_arg) do
    Phoenix.PubSub.subscribe(PubSub, @topic)
    Phoenix.PubSub.subscribe(PubSub, @topic_events)

    {:ok, Processes.List.new()}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state.entries, state}
  end

  @impl true
  def handle_info({:pid, %{pid: pid, name: name}}, state) do
    Phoenix.PubSub.broadcast(PubSub, @reload_topic, :reload)
    Process.monitor(pid)

    new_list = Processes.List.add_entry(state, %Processes.Process{pid: pid, name: name})

    {:noreply, new_list}
  end

  @impl true
  def handle_info({:event, %{name: name, pid: pid}}, state) do
    Phoenix.PubSub.broadcast(PubSub, @reload_topic, :reload)

    entry = state.entries |> Map.values() |> Enum.find(&(&1.pid == pid))

    updated_entry_events =
      if entry.event_history == nil, do: [name], else: [name | entry.event_history]

    updated_entry = %{entry | event_history: updated_entry_events}

    state = Processes.List.update_entry(state, updated_entry)

    {:noreply, state}

    {:noreply, state}
  end

  @impl true
  def handle_info({:diff, %{params: %{"test" => params}, pid: pid}}, state) do
    Phoenix.PubSub.broadcast(PubSub, @reload_topic, :reload)

    params = Jason.decode!(params)

    entry = state.entries |> Map.values() |> Enum.find(&(&1.pid == pid))

    updated_entry_diff =
      if entry.diff_history == nil, do: [params], else: [params | entry.diff_history]

    updated_entry = %{entry | diff_history: updated_entry_diff}

    state = Processes.List.update_entry(state, updated_entry)

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    Phoenix.PubSub.broadcast(PubSub, @reload_topic, :reload)

    entry = state.entries |> Map.values() |> Enum.find(&(&1.pid == pid))

    state = Processes.List.delete_entry(state, entry.id)

    {:noreply, state}
  end
end
