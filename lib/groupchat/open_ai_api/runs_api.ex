defmodule Groupchat.OpenAIApi.RunsApi do
  @moduledoc false

  alias Groupchat.OpenAIApi.Request
  alias OpenaiEx.Beta.Threads.Runs

  def create(thread_id, params) do
    body = Jason.encode!(params)

    Request.post("/threads/#{thread_id}/runs", body: body)
  end

  def stream(thread_id, assistant_id) do
    openai = Request.new()
    run_req = Runs.new(thread_id: thread_id, assistant_id: assistant_id)
    Runs.create(openai, run_req, stream: true)
  end
end
