defmodule LifetownClinic.ReceptionTest do
  use LifetownClinic.DataCase

  alias LifetownClinic.Reception
  alias LifetownClinic.Schema.Student

  test "patients can check in" do
    Reception.check_in("billy")

    assert Reception.all() == MapSet.new([%Student{id: nil, name: "billy"}])
  end
end
