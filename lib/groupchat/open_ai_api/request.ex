defmodule Groupchat.OpenAIApi.Request do
  @moduledoc false

  @openai_api_path "https://api.openai.com/v1"

  def new do
    OpenaiEx.new(api_key())
  end

  def delete(path, opts \\ []) do
    request(:delete, path, opts)
  end

  def get(path, opts \\ []) do
    request(:get, path, opts)
  end

  def post(path, opts) do
    request(:post, path, opts)
  end

  def request(method, path, opts) do
    headers = Keyword.get(opts, :headers, []) |> Keyword.merge(default_headers())
    opts = Keyword.merge(opts, method: method, url: path, headers: headers)

    {_req, resp} =
      Req.new(base_url: @openai_api_path)
      |> Req.run(opts)

    case resp do
      %{status: 401} -> {:error, :invalid_authentication}
      %{status: 403} -> {:error, :region_not_supported}
      %{status: 429} -> {:error, :rate_limit_reached}
      %{status: 500} -> {:error, :internal_server_error}
      %{status: 503} -> {:error, :service_overloaded}
      %{status: 200, body: body} -> {:ok, body}
    end
  end

  def default_headers do
    [
      {"content-type", "application/json"},
      {"openai-beta", "assistants=v2"},
      {"authorization", "Bearer #{api_key()}"}
    ]
  end

  defp api_key do
    Application.get_env(:groupchat, :openai_key)
  end
end
