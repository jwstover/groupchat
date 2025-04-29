defmodule Groupchat.ChatSupervisor do
  @moduledoc false

  alias Groupchat.Chat.ChatServer
  use DynamicSupervisor

  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(thread_id) do
    spec = {ChatServer, thread_id: thread_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def get_chat_server_pid(thread_id) do
    case Registry.lookup(Groupchat.ChatRegistry, thread_id) do
      [{pid, _value}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
