defmodule Groupchat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GroupchatWeb.Telemetry,
      Groupchat.Repo,
      {DNSCluster, query: Application.get_env(:groupchat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Groupchat.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Groupchat.Finch},
      # Start a worker by calling: Groupchat.Worker.start_link(arg)
      # {Groupchat.Worker, arg},
      # Start to serve requests, typically the last entry
      GroupchatWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :groupchat]},
      {Registry, keys: :unique, name: Groupchat.ChatRegistry},
      {Groupchat.ChatSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Groupchat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GroupchatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
