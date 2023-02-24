defmodule LiveViewTrackerPoc.Repo do
  use Ecto.Repo,
    otp_app: :live_view_tracker_poc,
    adapter: Ecto.Adapters.Postgres
end
