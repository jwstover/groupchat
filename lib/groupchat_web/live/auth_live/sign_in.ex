defmodule GroupchatWeb.AuthLive.SignIn do
  @moduledoc false

  use GroupchatWeb, :live_view

  def mount(_params, _session, socket) do
    form =
      Groupchat.Accounts.form_to_request_magic_link(
        context: %{private: %{ash_authentication?: true}}
      )
      |> to_form()

    {:ok, socket |> assign(:form, form)}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, socket |> assign(:form, form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:error, form} ->
        {:noreply, assign(socket, form: form)}

      _ok ->
        {:noreply, put_flash(socket, :info, "A login link has been emailed to you.")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="flex min-h-full flex-col justify-center px-6 py-12 lg:px-8 lg:-my-32">
      <div class="sm:mx-auto sm:w-full sm:max-w-sm">
        <div class="grid place-items-center">
          <.icon name="hero-chat-bubble-left-right" class="w-10 h-10" />
        </div>

        <h2 class="mt-10 text-center text-2xl/9 font-bold tracking-tight">
          Sign in to your account
        </h2>
      </div>

      <div class="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
        <.simple_form for={@form} phx-change="validate" phx-submit="submit">
          <div class="space-y-6">
            <.input
              field={@form[:email]}
              class="w-full"
              label="Email Address"
              type="email"
              autocomplete="email"
              phx-debounce={300}
              required
            />
            <.button type="submit" class="btn-primary w-full">Get Login Link</.button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end
end
