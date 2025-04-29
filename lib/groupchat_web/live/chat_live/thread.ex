defmodule GroupchatWeb.ChatLive.Thread do
  @moduledoc false

  use GroupchatWeb, :live_view

  require Logger

  import GroupchatWeb.ChatComponents

  alias Groupchat.OpenAIApi.MessagesApi
  alias Groupchat.OpenAI
  alias Groupchat.Chat

  on_mount {GroupchatWeb.LiveUserAuth, :live_user_required}

  def mount(%{"thread_id" => thread_id}, _session, socket) do
    {:ok,
     socket
     |> assign(form: to_form(%{"message" => ""}))
     |> assign(:thread, OpenAI.get_thread_by_id!(thread_id))
     |> assign(:assistant_stream_message, nil)
     |> stream_configure(:messages, dom_id: & &1["id"])
     |> assign_assistant()
     |> stream_messages()
     |> subscribe()}
  end

  defp assign_assistant(socket) do
    user = socket.assigns.current_user

    assign_async(socket, :assistant, fn ->
      {:ok, asst} = OpenAI.get_or_create_default_assistant_for_user(user, actor: user)
      {:ok, %{assistant: asst}}
    end)
  end

  defp stream_messages(socket) do
    thread_id = socket.assigns.thread.openai_thread_id
    {:ok, %{"data" => messages}} = MessagesApi.list(thread_id, %{order: "desc"})

    stream(socket, :messages, messages |> Enum.reverse())
  end

  defp subscribe(socket) do
    chat_id = socket.assigns.thread.openai_thread_id

    connected?(socket) && Chat.subscribe_to_chat(chat_id)

    socket
  end

  def handle_event("validate", %{"message" => message}, socket) do
    {:noreply, socket |> assign(form: to_form(%{"message" => message}))}
  end

  def handle_event("send", %{"message" => message}, socket) do
    Logger.debug("MESSAGE: #{message}")

    current_user = socket.assigns.current_user
    thread_id = socket.assigns.thread.openai_thread_id
    assistant_id = socket.assigns.assistant.result.openai_assistant_id

    Chat.send_message(message, current_user.id, thread_id, assistant_id)

    {:noreply, socket |> assign(form: to_form(%{"message" => ""}))}
  end

  def handle_info({:message, message}, socket) do
    Logger.debug("RECEIVED MESSAGE: #{inspect(message)}")

    socket = stream_insert(socket, :messages, message, at: -1)
    {:noreply, socket}
  end

  def handle_info(
        {:assistant_stream_event, %{event: "thread.message.created", data: data}},
        socket
      ) do
    Logger.debug("MESSAGE CREATED: #{inspect(data)}")

    {:noreply, assign(socket, :assistant_stream_message, data)}
  end

  def handle_info(
        {:assistant_stream_event, %{event: "thread.message.delta", data: data}},
        socket
      ) do
    Logger.debug("MESSAGE DELTA: #{inspect(data)}")

    assistant_message =
      socket.assigns.assistant_stream_message
      |> Map.update("content", [], fn content -> content ++ data["delta"]["content"] end)

    socket =
      socket
      |> assign(:assistant_stream_message, assistant_message)
      |> stream_insert(:messages, assistant_message)

    {:noreply, socket}
  end

  def handle_info(
        {:assistant_stream_event, %{event: "thread.message.completed", data: data}},
        socket
      ) do
    Logger.debug("MESSAGE COMPLETED: #{inspect(data)}")

    {:noreply, assign(socket, :assistant_stream_message, nil)}
  end

  def handle_info(event, socket) do
    Logger.error("UNHANDLED EVENT: #{inspect(event)}")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col gap-4">
      <div
        id="messages-window"
        class="flex-grow overflow-auto space-y-2 -mx-4 p-4"
        phx-update="stream"
        phx-hook="AutoScroll"
      >
        <div
          :for={{dom_id, message} <- @streams.messages}
          id={dom_id}
          class={[
            "chat hidden",
            (message["metadata"]["sender_id"] == @current_user.id && "chat-end") || "chat-start"
          ]}
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
            {message["metadata"]["sender_id"]} <time class="text-xs opacity-50">12:46</time>
          </div>
          <div class={[
            "chat-bubble max-w-[70%]",
            message["metadata"]["sender_id"] == @current_user.id && "chat-bubble-info"
          ]}>
            <p class="whitespace-pre-wrap">{message_content(message)}</p>
          </div>
        </div>
      </div>

      <.chat_input form={@form} assistant={@assistant} />
    </div>
    """
  end

  defp message_content(message) do
    message["content"]
    |> Enum.reduce("", fn
      %{"type" => "text", "text" => %{"value" => value}}, content -> content <> value
      _, content -> content
    end)
  end
end
