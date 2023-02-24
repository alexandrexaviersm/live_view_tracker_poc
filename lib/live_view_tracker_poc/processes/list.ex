defmodule LiveViewTrackerPoc.Processes.List do
  defstruct auto_id: 1, entries: %{}

  alias LiveViewTrackerPoc.Processes

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %Processes.List{},
      &add_entry(&2, &1)
    )
  end

  def size(processes_list) do
    map_size(processes_list.entries)
  end

  def add_entry(processes_list, entry) do
    entry = Map.put(entry, :id, processes_list.auto_id)
    new_entries = Map.put(processes_list.entries, processes_list.auto_id, entry)

    %Processes.List{processes_list | entries: new_entries, auto_id: processes_list.auto_id + 1}
  end

  def entries(processes_list, date) do
    processes_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(processes_list, %{} = new_entry) do
    update_entry(processes_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(processes_list, entry_id, updater_fun) do
    case Map.fetch(processes_list.entries, entry_id) do
      :error ->
        processes_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(processes_list.entries, new_entry.id, new_entry)
        %Processes.List{processes_list | entries: new_entries}
    end
  end

  def delete_entry(processes_list, entry_id) do
    %Processes.List{processes_list | entries: Map.delete(processes_list.entries, entry_id)}
  end
end
