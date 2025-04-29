defmodule GroupchatWeb.ChatComponents do
  @moduledoc false

  use GroupchatWeb, :html

  def chat_input(assigns) do
    ~H"""
    <div class="border border-base-content/20 shadow bg-base-100 rounded-box p-2">
      <.simple_form for={@form} phx-change="validate" phx-submit="send">
        <.input
          id="chat-input"
          type="textarea"
          class="max-h-min"
          phx-debounce={300}
          field={@form[:message]}
          placeholder="Send a message"
          phx-hook="ChatInput"
          phx-update="ignore"
        />

        <div class="flex items-center justify-end gap-2">
          <.button class="btn-sm">
            <.icon name="hero-cpu-chip" />
            <span :if={@assistant.loading} class="loading"></span>
            <span :if={@assistant.ok?}>{@assistant.result.name}</span>
          </.button>
          <button class="btn btn-primary btn-sm">
            <.icon name="hero-paper-airplane" />
          </button>
        </div>
      </.simple_form>
    </div>
    """
  end
end
