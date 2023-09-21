defmodule LifetownClinicWeb.StudentForm do
  use Phoenix.LiveComponent

  alias LifetownClinic.Schema.School
  alias LifetownClinic.Schema.Student
  alias LifetownClinic.Students
  alias LifetownClinic.Repo

  def update(assigns, socket) do
    form =
      assigns.student
      |> Student.changeset(%{})
      |> to_form()

    schools =
      School
      |> Repo.all()
      |> Enum.reduce([], fn %{id: id, name: name}, list ->
        [{String.to_atom(name), id}] ++ list
      end)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:schools, schools)

    {:ok, socket}
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
      {:ok, _} ->
        send(self(), :student_confirmed)
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  attr :possible_schools, :list, default: []
  attr :schools, :list, default: []

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input type="text" label="Name" field={@form[:name]} />
        <.input type="select" label="School" field={@form[:school_id]} options={@schools} />
        <button>Save</button>
      </.form>
    </div>
    """
  end

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField
  attr :label, :string, default: nil
  attr :rest, :global, include: ~w(autocomplete list type)
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"

  defp input(%{type: "text"} = assigns) do
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

  defp input(%{type: "select"} = assigns) do
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

  defp input(assigns) do
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
