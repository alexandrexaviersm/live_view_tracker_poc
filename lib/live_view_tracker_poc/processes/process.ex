defmodule LiveViewTrackerPoc.Processes.Process do
  defstruct [:id, :pid, :name, :event_history, :diff_history]
end
