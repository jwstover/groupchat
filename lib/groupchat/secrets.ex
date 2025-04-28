defmodule Groupchat.Secrets do
  @moduledoc false

  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Groupchat.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:groupchat, :token_signing_secret)
  end
end
