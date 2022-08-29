defmodule HeroComponent do
  use GameoflifeWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="hero"><%= @content %></div>
    """
  end
end
