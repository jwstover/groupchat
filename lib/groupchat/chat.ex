defmodule Groupchat.Chat do
  @moduledoc false

  def send_message(message, from, chat_id) do
    Phoenix.PubSub.broadcast(Groupchat.PubSub, "chat##{chat_id}", {:message, from, message})
  end

  def subscribe_to_chat(chat_id) do
    Phoenix.PubSub.subscribe(Groupchat.PubSub, "chat##{chat_id}")
  end
end
