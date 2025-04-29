defmodule Groupchat.OpenAI do
  @moduledoc false

  use Ash.Domain,
    otp_app: :groupchat,
    extensions: [AshAdmin.Domain]

  alias Groupchat.OpenAIApi.RunsApi
  alias Groupchat.OpenAIApi.MessagesApi
  alias Groupchat.OpenAIApi.ThreadsApi
  alias Groupchat.OpenAIApi.AssistantsApi
  alias Groupchat.Accounts
  alias Groupchat.Accounts.User

  admin do
    show? true
  end

  resources do
    resource Groupchat.OpenAI.Assistant do
      define :get_assistant_by_id, action: :get_by_id, args: [:id], get?: true
      define :create_assistant, action: :create
      define :delete_assistant, action: :delete
    end

    resource Groupchat.OpenAI.Thread do
      define :do_create_thread, action: :create_thread
      define :get_thread_by_id, action: :get_by_id, args: [:id], get?: true
    end

    resource Groupchat.OpenAI.Message
  end

  def create_default_assistant_for_user(%User{} = user, opts \\ []) do
    with {:ok, response} <- AssistantsApi.create(%{name: "Default", model: "gpt-4.1"}),
         {:ok, assistant} <-
           create_assistant(
             %{
               openai_assistant_id: response["id"],
               name: "Default",
               model: "gpt-4.1",
               user_id: user.id
             },
             opts
           ),
         {:ok, _} <- Accounts.set_default_assistant(user, assistant.id, opts) do
      {:ok, assistant}
    end
  end

  def get_or_create_default_assistant_for_user(user) do
    get_or_create_default_assistant_for_user(user, [])
  end

  def get_or_create_default_assistant_for_user(%User{default_assistant_id: nil} = user, opts) do
    create_default_assistant_for_user(user, opts)
  end

  def get_or_create_default_assistant_for_user(%User{default_assistant_id: assistant_id}, opts) do
    get_assistant_by_id(assistant_id, opts)
  end

  def create_thread(user_id, assistant_id) when is_binary(user_id) and is_binary(assistant_id) do
    {:ok, response} = ThreadsApi.create(%{})

    do_create_thread(%{
      user_id: user_id,
      assistant_id: assistant_id,
      openai_thread_id: response["id"]
    })
  end

  def add_message_and_run(message, thread_id, assistant_id, user_id) do
    {:ok, _response} =
      MessagesApi.create(thread_id, %{
        content: message,
        role: "user",
        metadata: %{user_id: user_id}
      })

    RunsApi.create(thread_id, %{assistant_id: assistant_id})
  end
end
