# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LifetownClinic.Repo.insert!(%LifetownClinic.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias LifetownClinic.Repo
alias LifetownClinic.Schema.{Lesson, School, Student}

schools =
  0..20
  |> Enum.map(fn i -> %School{name: "School #{i}"} end)
  |> Enum.map(&Repo.insert!/1)

students =
  0..350
  |> Enum.map(fn i ->
    %Student{
      name: "Student #{i}",
      school_id: Enum.random(schools).id
    }
  end)
  |> Enum.map(&Repo.insert!/1)

# create a random amound of lessons for each student between 0 and 10. 
# All should have the lesson number set to 1.
# All dates should be within the same year.
lessons =
  students
  |> Enum.map(fn student ->
    0..:rand.uniform(10)
    |> Enum.map(fn _ ->
      %Lesson{
        student_id: student.id,
        number: 1,
        completed_at: Timex.now() |> Timex.shift(days: -Enum.random(0..365)) |> Timex.to_date()
      }
    end)
  end)
  |> List.flatten()
  |> Enum.map(&Repo.insert!/1)
