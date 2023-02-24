defmodule LiveViewTrackerPoc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveViewTrackerPocWeb.Telemetry,
      # Start the Ecto repository
      LiveViewTrackerPoc.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveViewTrackerPoc.PubSub},
      # Start Finch
      {Finch, name: LiveViewTrackerPoc.Finch},
      # Start the Endpoint (http/https)
      LiveViewTrackerPocWeb.Endpoint,
      # Start a worker by calling: LiveViewTrackerPoc.Worker.start_link(arg)
      # {LiveViewTrackerPoc.Worker, arg}
      LiveViewTrackerPoc.PIDTracker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveViewTrackerPoc.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveViewTrackerPocWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
