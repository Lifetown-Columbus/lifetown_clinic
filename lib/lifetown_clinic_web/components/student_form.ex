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

    lessons_count =
      form.source
      |> Ecto.Changeset.get_field(:lessons)
      |> Enum.filter(fn lesson -> !lesson.delete end)
      |> Enum.count()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:schools, schools)
      |> assign(:student, assigns.student)
      |> assign(:lessons_count, lessons_count)

    {:ok, socket}
  end

  def handle_event("add_lesson", _, socket) do
    socket =
      socket
      |> update(:form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_field(changeset, :lessons)

        count =
          existing
          |> Enum.filter(fn lesson -> !lesson.delete end)
          |> Enum.count()

        if count < 6 do
          changeset =
            Ecto.Changeset.put_assoc(
              changeset,
              :lessons,
              existing ++ [%{inserted_at: Timex.now() |> Timex.to_datetime()}]
            )

          to_form(changeset)
        else
          to_form(changeset)
        end
      end)
      |> assign(
        :lessons_count,
        socket.assigns.form
        |> Phoenix.HTML.Form.inputs_for(:lessons)
        |> Enum.filter(fn lesson -> !Phoenix.HTML.Form.input_value(lesson, :delete) end)
        |> Enum.count()
      )

    {:noreply, socket}
  end

  def handle_event("remove_lesson", _, socket) do
    socket =
      socket
      |> update(:form, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_field(changeset, :lessons)

        index = Enum.find_index(existing, fn l -> !l.delete end)

        if is_nil(index) do
          to_form(changeset)
        else
          changeset
          |> Ecto.Changeset.put_assoc(:lessons, remove_lesson(existing, index))
          |> to_form()
        end
      end)
      |> assign(
        :lessons_count,
        socket.assigns.form
        |> Phoenix.HTML.Form.inputs_for(:lessons)
        |> Enum.filter(fn lesson -> !Phoenix.HTML.Form.input_value(lesson, :delete) end)
        |> Enum.count()
      )

    {:noreply, socket}
  end

  def handle_event("validate", %{"student" => params}, socket) do
    form =
      socket.assigns.student
      |> Student.changeset(params)
      |> to_form()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"student" => params}, socket) do
    case Students.save_student(socket.assigns.student, params) do
      {:ok, _} ->
        send(self(), :student_confirmed)
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp remove_lesson(existing, index) do
    {to_delete, rest} = List.pop_at(existing, index)

    if Ecto.Changeset.change(to_delete).data.id do
      List.replace_at(existing, index, Ecto.Changeset.change(to_delete, delete: true))
    else
      rest
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
        <fieldset>
          <label for="lessons">Lessons Completed <%= @lessons_count %></label>
          <div class="progress-inputs">
            <.inputs_for :let={lesson} field={@form[:lessons]}>
              <.progress field={lesson} />
            </.inputs_for>

            <%= for i <- 0..(6-@lessons_count), i>0 do %>
              <div class="star star-empty">
                <span>&#9734;</span>
              </div>
            <% end %>
          </div>

          <button
            type="button"
            disabled={@lessons_count == 6}
            phx-target={@myself}
            phx-click="add_lesson"
          >
            <span>Add Lesson</span>
          </button>

          <button
            class="cancel"
            type="button"
            disabled={@lessons_count == 0}
            phx-target={@myself}
            phx-click="remove_lesson"
          >
            <span>Remove Lesson</span>
          </button>
        </fieldset>
        <button>Save</button>
      </.form>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField

  defp progress(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.field, :delete)
      )

    ~H"""
    <div class={if(@deleted, do: "hide")}>
      <div class="lesson">
        <input
          type="hidden"
          name={Phoenix.HTML.Form.input_name(@field, :delete)}
          value={to_string(Phoenix.HTML.Form.input_value(@field, :delete))}
        />
        <div class="star star-filled">
          <span>&#9733;</span>
        </div>
      </div>
    </div>
    """
  end
end
