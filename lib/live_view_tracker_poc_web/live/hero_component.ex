defmodule LiveViewTrackerPocWeb.HeroComponent do
  use LiveViewTrackerPocWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="hero"><%= @content %></div>
    """
  end
end
