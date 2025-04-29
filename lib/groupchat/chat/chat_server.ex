defmodule Groupchat.Chat.ChatServer do
  @moduledoc false

  use GenServer

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                                  CLIENT API                                  │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @doc """
  Starts the chat server.
  """
  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  @doc """
  Gets the current state of the chat server.
  """
  def add_message(pid, sender, message, timeout \\ 60_000) do
    GenServer.call(pid, {:add_message, sender, message}, timeout)
  end

  # ╭──────────────────────────────────────────────────────────────────────────────╮
  # │                               SERVER CALLBACKS                               │
  # ╰──────────────────────────────────────────────────────────────────────────────╯

  @impl true
  def init(state) do
    {:ok, updated_chain} =
      %{llm: ChatOpenAI.new!(%{model: "gpt-4o"})}
      |> LLMChain.new()

    state = Map.put(state, :llm_chain, updated_chain)

    {:ok, state}
  end

  @impl true
  def handle_call({:add_message, _sender, message}, _from, state) do
    llm_chain = state.llm_chain

    {:ok, updated_chain} =
      LLMChain.add_message(llm_chain, Message.new_user!(message))
      |> LLMChain.run()

    {:reply, updated_chain.last_message.content, %{state | llm_chain: updated_chain}}
  end
end
