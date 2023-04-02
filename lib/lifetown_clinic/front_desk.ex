defmodule LifetownClinic.FrontDesk do
  @moduledoc """
  The FrontDesk context.
  """
  use GenServer
  alias Phoenix.PubSub
  alias LifetownClinic.Student

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

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  def handle_call({:check_in, name}, _from, state) do
    student = %Student{name: name}
    PubSub.broadcast(@pubsub, "front_desk", :student_checked_in)

    {:reply, :ok, MapSet.put(state, student)}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end
