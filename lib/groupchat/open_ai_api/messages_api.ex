defmodule Groupchat.OpenAIApi.MessagesApi do
  @moduledoc false

  alias Groupchat.OpenAIApi.Request

  def create(thread_id, params) do
    body = Jason.encode!(params)

    Request.post("/threads/#{thread_id}/messages", body: body)
  end

  def list(thread_id, params) do
    query_params = URI.encode_query(params)

    Request.get("/threads/#{thread_id}/messages?#{query_params}")
  end
end
