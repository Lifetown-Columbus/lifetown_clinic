defmodule LifetownClinic.Factory do
  use ExMachina.Ecto, repo: LifetownClinic.Repo
  alias LifetownClinic.Schema.{School, Student}

  def school_factory do
    %School{
      name:
        "#{Faker.Address.city()} #{Enum.random(["High School", "Middle School", "Elementary"])}"
    }
  end

  def student_factory do
    %Student{
      name: sequence(Faker.Person.first_name()),
      lessons: [],
      school: fn -> build(:school) end
    }
  end
end
