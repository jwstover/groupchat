defmodule Groupchat.OpenAI.Thread do
  @moduledoc false

  use Ash.Resource,
    otp_app: :groupchat,
    domain: Groupchat.OpenAI,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "threads"
    repo Groupchat.Repo
  end

  actions do
    defaults [:read]

    read :get_by_id do
      argument :id, :uuid_v7, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    create :create_thread do
      accept [:*]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :openai_thread_id, :string do
      allow_nil? false
      public? true
    end

    attribute :title, :string do
      public? true
    end

    attribute :status, :string do
      public? true
    end

    attribute :metadata, :map do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Groupchat.Accounts.User do
      allow_nil? false
      public? true
    end

    belongs_to :assistant, Groupchat.OpenAI.Assistant do
      allow_nil? false
      public? true
    end
  end
end
