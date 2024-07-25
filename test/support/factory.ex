defmodule LifetownClinic.Factory do
  use ExMachina.Ecto, repo: LifetownClinic.Repo
  alias LifetownClinic.Schema.{School, Student, Lesson}

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

  def lesson_factory do
    %Lesson{
      student: build(:student),
      number: sequence(:number, [1, 2, 3, 4, 5, 6]),
      completed_at: Timex.today()
    }
  end
end
