defmodule LifetownClinicWeb.StudentForm do
  use Phoenix.LiveComponent

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

    {:ok, socket}
  end

  def handle_event("add_lesson", _, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing =
          changeset
          |> Ecto.Changeset.get_field(:lessons)

        count =
          existing
          |> Enum.filter(fn lesson -> !lesson.delete end)
          |> Enum.count()
          |> IO.inspect()

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

  attr :possible_schools, :list, default: []
  attr :schools, :list, default: []

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input type="text" label="Name" field={@form[:name]} />
        <.input type="select" label="School" field={@form[:school_id]} options={@schools} />
        <fieldset>
          <label for="lessons">Lessons Completed</label>
          <.inputs_for :let={lesson} field={@form[:lessons]}>
            <.progress cid={@myself} field={lesson} />
          </.inputs_for>
        </fieldset>
        <button type="button" phx-target={@myself} phx-click="add_lesson">Add Lesson</button>
        <button>Save</button>
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
    <div class={if(@deleted, do: "hide")}>
      <div class="lesson">
        <input
          type="hidden"
          name={Phoenix.HTML.Form.input_name(@field, :delete)}
          value={to_string(Phoenix.HTML.Form.input_value(@field, :delete))}
        />
        <p>
          <%= to_string(Phoenix.HTML.Form.input_value(@field, :inserted_at)) %>
        </p>
        <button
          class="cancel"
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
