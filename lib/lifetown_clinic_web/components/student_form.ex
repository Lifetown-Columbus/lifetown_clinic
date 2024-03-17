defmodule LifetownClinicWeb.StudentForm do
  use LifetownClinicWeb, :live_component

  alias LifetownClinic.Schema.{School, Student}
  alias LifetownClinic.Students
  alias LifetownClinic.Repo

  def update(assigns, socket) do
    form =
      assigns.student
      |> Student.changeset(%{})
      |> to_form()

    schools =
      School.all()
      |> Repo.all()
      |> Enum.reduce([], fn %{id: id, name: name}, list ->
        [{String.to_atom(name), id}] ++ list
      end)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:schools, schools)
      |> assign(:student, assigns.student)
      |> assign(:save_callback, assigns.save_callback)

    {:ok, socket}
  end

  def handle_event("add_lesson", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing =
          changeset
          |> Ecto.Changeset.get_field(:lessons)

        changeset =
          Ecto.Changeset.put_assoc(
            changeset,
            :lessons,
            existing ++ [%{inserted_at: Timex.now() |> Timex.to_datetime()}]
          )

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("remove_lesson", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_field(changeset, :lessons)
        {to_delete, rest} = List.pop_at(existing, index)

        new_lessons =
          if Ecto.Changeset.change(to_delete).data.id do
            List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
          else
            rest
          end

        changeset
        |> Ecto.Changeset.put_assoc(:lessons, new_lessons)
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("validate", %{"student" => params}, socket) do
    form =
      socket.assigns.student
      |> Student.changeset(params)
      |> Map.put(:action, :update)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"student" => params}, socket) do
    case Students.save_student(socket.assigns.student, params) do
      {:ok, student} ->
        socket.assigns.save_callback.(student)
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
        <.input
          type="select"
          prompt="Pick a School"
          label="School"
          field={@form[:school_id]}
          options={@schools}
        />
        <fieldset>
          <label for="lessons">Lessons Completed</label>
          <.inputs_for :let={lesson} field={@form[:lessons]}>
            <.progress cid={@myself} field={lesson} />
          </.inputs_for>
          <button type="button" phx-target={@myself} phx-click="add_lesson">Add Lesson</button>
        </fieldset>
        <button disabled={!@form.source.valid?}>Save</button>
      </.form>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField
  attr :cid, Phoenix.LiveComponent.CID

  defp progress(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.field, :delete) == true
      )

    ~H"""
    <div class={if(@deleted, do: "deleted")}>
      <div class="lesson">
        <pre><%= @field.index %></pre>
        <pre><%= @field.data.id %></pre>
        <input
          type="hidden"
          name={Phoenix.HTML.Form.input_name(@field, :delete)}
          value={to_string(Phoenix.HTML.Form.input_value(@field, :delete))}
        />
        <.input
          type="select"
          prompt="Pick a lesson"
          label="Lesson Number"
          field={@field[:number]}
          options={[1, 2, 3, 4, 5, 6]}
        />
        <.input type="date" label="Completed On" field={@field[:completed_at]} />

        <button
          class="cancel-chill"
          disabled={@deleted}
          type="button"
          phx-target={@cid}
          phx-value-index={@field.index}
          phx-click="remove_lesson"
        >
          X
        </button>
      </div>
    </div>
    """
  end
end
