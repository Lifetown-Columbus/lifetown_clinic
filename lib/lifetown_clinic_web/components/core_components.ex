defmodule LifetownClinicWeb.CoreComponents do
  use Phoenix.Component

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField
  attr :label, :string, default: nil
  attr :rest, :global, include: ~w(autocomplete list type)
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"

  def input(%{type: "text"} = assigns) do
    ~H"""
    <div phx-feedback-for={@field.name}>
      <label for={@field.name}><%= @label %></label>
      <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
      <%= for {err, _} <- @field.errors do %>
        <.error><%= err %></.error>
      <% end %>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@field.name}>
      <label for={@field.id}><%= @label %></label>
      <select id={@field.id} name={@field.name} {@rest}>
        <%= Phoenix.HTML.Form.options_for_select(@options, @field.value) %>
      </select>

      <%= for {err, _} <- @field.errors do %>
        <.error><%= err %></.error>
      <% end %>
    </div>
    """
  end

  def input(%{type: "date"} = assigns) do
    ~H"""
    <div phx-feedback-for={@field.name}>
      <label for={@field.id}><%= @label %></label>
      <input
        type="date"
        name={@field.name}
        value={Phoenix.HTML.Form.normalize_value("date", @field.value)}
      />

      <%= for {err, _} <- @field.errors do %>
        <.error><%= err %></.error>
      <% end %>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <p>Weird Error... Call Stephen</p>
    """
  end

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden error">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end
end
