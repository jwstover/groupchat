defmodule GroupchatWeb.ChatLive.Index do
  @moduledoc false

  use GroupchatWeb, :live_view

  require Logger

  import GroupchatWeb.ChatComponents

  alias Groupchat.Chat
  alias Groupchat.OpenAI

  on_mount {GroupchatWeb.LiveUserAuth, :live_user_required}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(form: to_form(%{"message" => ""}))
     |> assign_assistant()}
  end

  defp assign_assistant(socket) do
    user = socket.assigns.current_user

    assign_async(socket, :assistant, fn ->
      {:ok, asst} = OpenAI.get_or_create_default_assistant_for_user(user, actor: user)
      {:ok, %{assistant: asst}}
    end)
  end

  def handle_event("validate", %{"message" => message}, socket) do
    {:noreply, socket |> assign(form: to_form(%{"message" => message}))}
  end

  def handle_event("send", %{"message" => message}, socket) do
    Logger.debug("MESSAGE: #{message}")

    assistant = socket.assigns.assistant.result
    current_user = socket.assigns.current_user

    {:ok, thread} = OpenAI.create_thread(current_user.id, assistant.id)

    Chat.send_message(
      message,
      current_user.id,
      thread.openai_thread_id,
      assistant.openai_assistant_id
    )

    {:noreply, push_navigate(socket, to: ~p"/chat/#{thread.id}")}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto flex flex-col h-full w-full justify-center space-y-8">
      <div class="flex flex-col items-center space-y-4">
        <.icon name="hero-chat-bubble-oval-left" class="h-8 w-8" />
        <h1 class="text-xl font-semibold">What can I help you with today?</h1>
      </div>
      <.chat_input form={@form} assistant={@assistant} />
    </div>
    """
  end
end
