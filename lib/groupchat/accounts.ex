defmodule Groupchat.Accounts do
  @moduledoc false

  use Ash.Domain, otp_app: :groupchat, extensions: [AshAdmin.Domain, AshPhoenix]

  admin do
    show? true
  end

  resources do
    resource Groupchat.Accounts.Token

    resource Groupchat.Accounts.User do
      define :get_user_by_id, action: :get_by_id, args: [:id], get?: true
      define :request_magic_link, args: [:email]
      define :set_default_assistant, args: [:default_assistant_id]
    end
  end
end
