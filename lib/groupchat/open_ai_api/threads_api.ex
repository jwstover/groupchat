defmodule Groupchat.OpenAIApi.ThreadsApi do
  @moduledoc false

  alias Groupchat.OpenAIApi.Request

  def create(params) do
    body = Jason.encode!(params)

    Request.post("/threads", body: body)
  end
end
