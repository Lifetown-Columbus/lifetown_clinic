defmodule LifetownClinic.FrontDeskTest do
  use LifetownClinic.DataCase

  alias LifetownClinic.FrontDesk
  alias LifetownClinic.Student

  test "patients can check in" do
    FrontDesk.check_in("billy")

    assert FrontDesk.all() == [%Student{id: nil, name: "billy"}]
  end
end
