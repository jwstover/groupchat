defmodule GroupchatWeb.ChatLive.Index do
  @moduledoc false

  use GroupchatWeb, :live_view

  def mount(_params, _session, socket) do
    
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      GroupchatWeb.ChatLive.Index
    </div>
    """
  end
end
