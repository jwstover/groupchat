defmodule Groupchat.Chat.ChatServer do
  @moduledoc false

  use GenServer

  require Logger

  alias Groupchat.OpenAIApi.MessagesApi
  alias Groupchat.OpenAIApi.RunsApi

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                                  CLIENT API                                  │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @doc """
  Starts the chat server.
  """
  def start_link(thread_id: thread_id) do
    GenServer.start_link(__MODULE__, %{thread_id: thread_id}, name: via_tuple(thread_id))
  end

  defp via_tuple(thread_id) do
    {:via, Registry, {Groupchat.ChatRegistry, thread_id}}
  end

  @doc """
  Gets the current state of the chat server.
  """
  def add_message_and_run(pid, message, sender_id, thread_id, assistant_id) do
    GenServer.cast(pid, {:add_message_and_run, message, sender_id, thread_id, assistant_id})
  end

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                               SERVER CALLBACKS                               │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:add_message_and_run, message, sender_id, thread_id, assistant_id}, state) do
    {:ok, message} =
      MessagesApi.create(thread_id, %{
        content: message,
        role: "user",
        metadata: %{sender_id: sender_id}
      })

    Phoenix.PubSub.broadcast(Groupchat.PubSub, "chat##{thread_id}", {:message, message})

    {:ok, run_stream} = RunsApi.stream(thread_id, assistant_id)

    IO.puts(inspect(run_stream))
    IO.puts(inspect(run_stream.task_pid))

    run_stream.body_stream
    |> Stream.flat_map(& &1)
    |> Enum.each(fn event ->
      Phoenix.PubSub.broadcast(
        Groupchat.PubSub,
        "chat##{thread_id}",
        {:assistant_stream_event, event}
      )
    end)

    {:noreply, state}
  end
end
