defmodule Mix.Tasks.CleanOpenaiResources do
  @moduledoc false

  use Mix.Task

  alias Groupchat.Repo
  alias Groupchat.OpenAI.Assistant
  alias Groupchat.OpenAIApi.AssistantsApi

  @impl Mix.Task
  def run(_args) do
    Application.get_env(:groupchat, :env) in [:dev, :test] ||
      raise """
      BE CAREFUL!!!
      `mix clean_openai_resources` should only be run in dev or test mode!
      """

    Application.load(:groupchat)
    Application.ensure_all_started(:groupchat)
    Mix.Ecto.ensure_repo(Groupchat.Repo, [])

    try do
      Mix.shell().info("Deleting Assistants")

      Repo.all(Assistant)
      |> Enum.each(fn asst ->
        AssistantsApi.delete(asst.openai_assistant_id)
      end)
    rescue
      _ -> Mix.shell().info("Encountered error when cleaning uploads")
    end

    Application.stop(:groupchat)
  end
end
