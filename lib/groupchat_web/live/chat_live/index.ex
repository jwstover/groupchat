defmodule GroupchatWeb.ChatLive.Index do
  @moduledoc false

  use GroupchatWeb, :live_view

  require Logger

  alias Groupchat.Chat

  on_mount {GroupchatWeb.LiveUserAuth, :live_user_required}

  @chat_id "1234"

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:chat_id, @chat_id)
     |> assign(form: to_form(%{"message" => ""}))
     |> assign_chat()
     |> stream_messages()
     |> subscribe()}
  end

  defp assign_chat(socket) do
    {:ok, pid} = Chat.new()

    assign(socket, :chat_pid, pid)
  end

  defp stream_messages(socket) do
    messages = [
      %{id: 1, text: "Message one", from: "Jake"},
      %{
        id: 2,
        text: """
        This is a longer multiline message. it also has a really long line so that we can check that word wrapping is working properly.

        Testing one two three four.
        """,
        from: "Jake"
      }
    ]

    stream(socket, :messages, messages)
  end

  defp subscribe(socket) do
    chat_id = socket.assigns.chat_id

    connected?(socket) && Chat.subscribe_to_chat(chat_id)

    socket
  end

  def handle_event("validate", %{"message" => message}, socket) do
    {:noreply, socket |> assign(form: to_form(%{"message" => message}))}
  end

  def handle_event("send", %{"message" => message}, socket) do
    Logger.debug("MESSAGE: #{message}")

    chat_id = socket.assigns.chat_id
    chat_pid = socket.assigns.chat_pid
    current_user = socket.assigns.current_user

    Chat.send_message(message, current_user.id, chat_id, chat_pid)

    {:noreply, socket |> assign(form: to_form(%{"message" => ""}))}
  end

  def handle_info({:message, from, message}, socket) do
    Logger.debug("RECEIVED MESSAGE FROM #{from}: #{message}")

    message = %{id: Ecto.UUID.generate(), text: message, from: from}

    socket = stream_insert(socket, :messages, message, at: -1)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col gap-4">
      <div
        id="messages-window"
        class="flex-grow overflow-auto space-y-2 p-2 border border-base-content/20 shadow bg-base-100 rounded-box"
        phx-update="stream"
      >
        <div
          :for={{dom_id, message} <- @streams.messages}
          id={dom_id}
          class={["chat hidden", (message.from == @current_user.id && "chat-end") || "chat-start"]}
          phx-mounted={JS.show(display: "grid")}
        >
          <div class="chat-image avatar">
            <div class="w-10 rounded-full">
              <img
                alt="Tailwind CSS chat bubble component"
                src="https://img.daisyui.com/images/stock/photo-1534528741775-53994a69daeb.webp"
              />
            </div>
          </div>
          <div class="chat-header mb-1">
            {message.from} <time class="text-xs opacity-50">12:46</time>
          </div>
          <div class={[
            "chat-bubble max-w-[70%]",
            message.from == @current_user.id && "chat-bubble-info"
          ]}>
            <p class="whitespace-pre-wrap">{message.text}</p>
          </div>
        </div>
      </div>

      <div class="border border-base-content/20 shadow bg-base-100 rounded-box p-2">
        <.simple_form for={@form} phx-change="validate" phx-submit="send">
          <.input
            id="chat-input"
            type="textarea"
            class="max-h-min"
            phx-debounce={300}
            field={@form[:message]}
            placeholder="Send a message"
            phx-hook="ChatInput"
            phx-update="ignore"
          />

          <div class="flex items-center justify-end">
            <button class="btn btn-primary btn-sm">
              <.icon name="hero-paper-airplane" />
            </button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end
end
