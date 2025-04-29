defmodule Groupchat.OpenAI.Assistant do
  @moduledoc false

  use Ash.Resource,
    otp_app: :groupchat,
    domain: Groupchat.OpenAI,
    data_layer: AshPostgres.DataLayer

  alias Groupchat.Accounts.User

  postgres do
    table "assistants"
    repo Groupchat.Repo
  end

  actions do
    defaults [:read]

    read :get_by_id do
      argument :id, :uuid_v7
    end

    create :create do
      accept [:*]
    end

    destroy :delete
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :openai_assistant_id, :string do
      public? true
      allow_nil? false
    end

    attribute :name, :string do
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :model, :string do
      public? true
      default "gpt-4o"
    end

    attribute :tools, :map do
      public? true
    end

    attribute :instructions, :string do
      public? true
    end

    attribute :metadata, :map do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, User do
      public? true
      allow_nil? false
    end
  end
end
