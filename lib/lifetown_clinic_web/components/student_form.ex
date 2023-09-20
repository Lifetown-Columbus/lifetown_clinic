defmodule LifetownClinicWeb.StudentForm do
  use Phoenix.LiveComponent

  alias LifetownClinic.Schema.Student

  def update(assigns, socket) do
    form =
      assigns.student
      |> Student.changeset(%{})
      |> to_form()

    {:ok, assign(socket, :form, form)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input type="text" field={@form[:name]} />
      </.form>
    </div>
    """
  end

  def handle_event("validate", _prams, socket) do
    IO.puts("validation!")
    {:noreply, socket}
  end

  def handle_event("save", _prams, socket) do
    IO.puts("save!")
    {:noreply, socket}
  end

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global, include: ~w(type)

  defp input(assigns) do
    ~H"""
    <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
    """
  end
end
