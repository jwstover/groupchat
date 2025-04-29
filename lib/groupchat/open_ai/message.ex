defmodule Groupchat.OpenAI.Message do
  @moduledoc false

  use Ash.Resource,
    otp_app: :groupchat,
    domain: Groupchat.OpenAI,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "messages"
    repo Groupchat.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :openai_message_id, :string do
      allow_nil? false
      public? true
    end

    attribute :role, :atom do
      allow_nil? false
      public? true

      constraints one_of: [:user, :assistant]
    end

    attribute :content, :string do
      public? true
    end

    attribute :raw_json, :map do
      public? true
    end

    attribute :token_count, :integer do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :thread, Groupchat.OpenAI.Thread do
      allow_nil? false
    end

    belongs_to :sender, Groupchat.Accounts.User do
      allow_nil? false
    end
  end
end
