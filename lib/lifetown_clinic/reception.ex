defmodule LifetownClinic.Reception do
  @moduledoc """
  The Reception context.
  """
  use GenServer
  alias Phoenix.PubSub
  alias LifetownClinic.Schema.Student

  @pubsub LifetownClinic.PubSub

  def init([]) do
    {:ok, MapSet.new()}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def check_in(name) do
    GenServer.call(__MODULE__, {:check_in, name})
  end

  def remove(name) do
    GenServer.call(__MODULE__, {:remove, name})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def handle_call({:check_in, name}, _from, state) do
    student = Student.changeset(%Student{}, %{name: name})

    if student.valid? do
      PubSub.broadcast(@pubsub, "front_desk", :student_checked_in)
      {:reply, :ok, MapSet.put(state, Ecto.Changeset.apply_changes(student))}
    else
      msg =
        Ecto.Changeset.traverse_errors(student, fn {message, opts} ->
          Regex.replace(~r"%{(\w+)}", message, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
        |> Map.values()
        |> Enum.join(" ")

      {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:remove, name}, _from, state) do
    PubSub.broadcast(@pubsub, "front_desk", :student_removed)

    state =
      MapSet.reject(state, fn student ->
        student.name == name
      end)

    # Repo.insert!(%Student{name: name})
    {:reply, state, state}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end
