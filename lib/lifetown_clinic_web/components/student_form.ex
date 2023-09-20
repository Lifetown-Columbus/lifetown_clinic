defmodule LifetownClinicWeb.StudentForm do
  use Phoenix.LiveComponent

  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Students

  def update(assigns, socket) do
    form =
      assigns.student
      |> Student.changeset(%{})
      |> to_form()

    {:ok, assign(socket, :form, form)}
  end

  def handle_event("validate", %{"student" => params}, socket) do
    form =
      socket.assigns.form.data
      |> Student.changeset(params)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"student" => params}, socket) do
    case Students.save_student(params, socket.assigns.form.data) do
      {:ok, student} ->
        IO.inspect(student)
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input type="text" field={@form[:name]} />
        <button>Save</button>
      </.form>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField
  attr :rest, :global, include: ~w(type)

  defp input(assigns) do
    ~H"""
    <div phx-feedback-for={@field.name}>
      <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
      <%= for {err, _} <- @field.errors do %>
        <.error><%= err %></.error>
      <% end %>
    </div>
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
