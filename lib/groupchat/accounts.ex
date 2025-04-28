defmodule Groupchat.Accounts do
  use Ash.Domain, otp_app: :groupchat, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Groupchat.Accounts.Token
    resource Groupchat.Accounts.User
  end
end
