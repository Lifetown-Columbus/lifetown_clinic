defmodule LifetownClinic.FrontDeskTest do
  use LifetownClinic.DataCase

  alias LifetownClinic.FrontDesk
  alias LifetownClinic.Student

  test "patients can check in" do
    {:ok, pid} = FrontDesk.start_link([])

    FrontDesk.check_in(pid, "billy")

    assert FrontDesk.all(pid) == [%Student{id: nil, name: "billy"}]
  end
end
