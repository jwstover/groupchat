defmodule Groupchat.Chat do
  @moduledoc false

  alias Groupchat.Chat.ChatServer

  def new do
    ChatServer.start_link()
  end

  def send_message(message, from, chat_id, chat_pid) do
    Phoenix.PubSub.broadcast(Groupchat.PubSub, "chat##{chat_id}", {:message, from, message})

    Task.start(fn ->
      response = ChatServer.add_message(chat_pid, from, message)

      Phoenix.PubSub.broadcast(
        Groupchat.PubSub,
        "chat##{chat_id}",
        {:message, "ChatGPT", response}
      )
    end)
  end

  def subscribe_to_chat(chat_id) do
    Phoenix.PubSub.subscribe(Groupchat.PubSub, "chat##{chat_id}")
  end
end
