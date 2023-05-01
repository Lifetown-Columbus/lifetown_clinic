defmodule LifetownClinic.Reception do
  @moduledoc """
  The Reception context.
  """
  use GenServer
  alias Phoenix.PubSub

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

  def confirm(name) do
    GenServer.call(__MODULE__, {:confirm, name})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def handle_call({:confirm, name}, _from, state) do
    PubSub.broadcast(@pubsub, "front_desk", :student_removed)

    state =
      MapSet.reject(state, fn student ->
        student.name == name
      end)

    {:reply, state, state}
  end

  def handle_call({:check_in, name}, _from, state) do
    name = String.trim(name)

    if String.length(name) > 0 do
      PubSub.broadcast(@pubsub, "front_desk", :student_checked_in)
      {:reply, :ok, MapSet.put(state, %{name: name})}
    else
      {:reply, {:error, "Name cannot be blank"}, state}
    end
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end
