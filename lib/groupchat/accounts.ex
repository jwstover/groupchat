defmodule Groupchat.Accounts do
  @moduledoc false

  use Ash.Domain, otp_app: :groupchat, extensions: [AshAdmin.Domain, AshPhoenix]

  admin do
    show? true
  end

  resources do
    resource Groupchat.Accounts.Token
    resource Groupchat.Accounts.User do
      define :request_magic_link, args: [:email]
    end
  end
end
