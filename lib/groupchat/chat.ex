defmodule Groupchat.Chat do
  @moduledoc false

  alias Groupchat.Chat.ChatServer
  alias Groupchat.ChatSupervisor

  def get(thread_id) do
    ChatSupervisor.get_chat_server_pid(thread_id)
    |> case do
      {:ok, pid} -> {:ok, pid}
      _ -> ChatSupervisor.start_child(thread_id)
    end
  end

  def send_message(message, sender_id, thread_id, assistant_id) do
    {:ok, pid} = get(thread_id)

    ChatServer.add_message_and_run(pid, message, sender_id, thread_id, assistant_id)

    :ok
  end

  def subscribe_to_chat(chat_id) do
    Phoenix.PubSub.subscribe(Groupchat.PubSub, "chat##{chat_id}")
  end
end
