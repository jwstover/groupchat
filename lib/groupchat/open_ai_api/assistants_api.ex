defmodule Groupchat.OpenAIApi.AssistantsApi do
  @moduledoc false

  alias Groupchat.OpenAIApi.Request

  def create(params) do
    body = Jason.encode!(params)
    Request.post("/assistants", body: body)
  end

  def list(params) do
    query_params = URI.encode_query(params)
    path = "/assistants?#{query_params}"
    Request.get(path)
  end

  def delete(assistant_id) do
    Request.delete("/assistants/#{assistant_id}")
  end
end
