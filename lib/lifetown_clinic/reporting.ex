defmodule LifetownClinic.Reporting do
  import Ecto.Query

  alias LifetownClinic.Schema.{Lesson, School, Student}

  def student_count(nil, nil) do
    from s in Student, select: count()
  end

  def student_count(start_date, nil) do
    today = Timex.now() |> Timex.to_datetime()
    student_count(start_date, today)
  end

  def student_count(nil, end_date) do
    epoch = Timex.zero() |> Timex.to_datetime()
    student_count(epoch, end_date)
  end

  def student_count(start_date, end_date) do
    from s in Student,
      join: l in Lesson,
      on: l.student_id == s.id,
      where:
        l.inserted_at >= ^start_date and
          l.inserted_at <= ^end_date,
      select: count()
  end

  def school_count do
    from s in School, select: count()
  end
end
