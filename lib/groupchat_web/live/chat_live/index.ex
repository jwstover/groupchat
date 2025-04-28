defmodule GroupchatWeb.ChatLive.Index do
  @moduledoc false

  use GroupchatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(form: to_form(%{"message" => ""}))}
  end

  def handle_event("validate", %{"message" => message}, socket) do
    {:noreply, socket |> assign(form: to_form(%{"message" => message}))}
  end

  def handle_event("send", %{"message" => message}, socket) do
    {:noreply, socket |> assign(form: to_form(%{"message" => ""}))}
  end

  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col gap-4">
      <div class="flex-grow border border-base-content/20 shadow bg-base-100 rounded-box"></div>

      <div class="border border-base-content/20 shadow bg-base-100 rounded-box p-2">
        <.simple_form for={@form} phx-change="validate" phx-submit="send">
          <.input type="textarea" class="min-h-min" rows="1" phx-debounce={300} field={@form[:message]} placeholder="Send a message" />
          
          <div class="flex items-center justify-end">
            <button class="btn btn-primary btn-sm">
              <.icon name="hero-paper-airplane" />
            </button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end
end
