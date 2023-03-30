defmodule LifetownClinic.FrontDesk do
  @moduledoc """
  The FrontDesk context.
  """
  use GenServer
  alias LifetownClinic.Student

  def init([]) do
    {:ok, []}
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
    {:reply, :ok, [student | state]}
  end

  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end
