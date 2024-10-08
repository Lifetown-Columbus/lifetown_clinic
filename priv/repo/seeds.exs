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
Code.require_file("test/support/factory.ex")

{:ok, _} = Application.ensure_all_started(:ex_machina)
Faker.start()

schools = LifetownClinic.Factory.insert_list(20, :school)

students =
  LifetownClinic.Factory.insert_list(350, :student, %{school: fn -> Enum.random(schools) end})

# create a random amount of lessons for each student between 0 and 10. 
# All should have the lesson number set to 1.
# All dates should be within the same year.
Enum.each(students, fn student ->
  LifetownClinic.Factory.insert_list(:rand.uniform(10), :lesson, %{
    student: student,
    completed_at: fn ->
      Timex.now()
      |> Timex.shift(days: -Enum.random(0..365))
      |> Timex.to_date()
    end
  })
end)

# generate some "new" students without lessons
schools
|> Enum.each(fn school ->
  LifetownClinic.Factory.insert(:student, %{school: school})
end)
