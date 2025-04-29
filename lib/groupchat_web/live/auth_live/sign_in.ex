defmodule GroupchatWeb.AuthLive.SignIn do
  @moduledoc false

  use GroupchatWeb, :live_view

  def mount(_params, _session, socket) do
    form =
      Groupchat.Accounts.form_to_request_magic_link(context: %{private: %{ash_authentication?: true}})
      |> to_form()

    {:ok, socket |> assign(:form, form)}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    IO.inspect(params, label: "================== PARAMS\n")
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, socket |> assign(:form, form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:error, form} ->
        IO.inspect(form, label: "================== FORM\n")
        {:noreply, assign(socket, form: form)}

      ok ->
        IO.inspect(ok, label: "================== OK\n")
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      GroupchatWeb.AuthLive.SignIn
      <.simple_form for={@form} phx-change="validate" phx-submit="submit">
        <.input field={@form[:email]} type="email" />
        <.button type="submit">Get Login Link</.button>
      </.simple_form>
    </div>
    """
  end
end
