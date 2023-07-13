defmodule LifetownClinic.Reporting do
  import Ecto.Query

  alias LifetownClinic.Schema.{Lesson, School, Student}

  def student_count(nil, nil) do
    epoch = Timex.zero() |> Timex.to_datetime()
    today = Timex.now() |> Timex.to_datetime()
    student_count(epoch, today)
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
      select: count(s.id, :distinct)
  end

  def school_count(nil, nil) do
    epoch = Timex.zero() |> Timex.to_datetime()
    today = Timex.now() |> Timex.to_datetime()
    school_count(epoch, today)
  end

  def school_count(start_date, nil) do
    today = Timex.now() |> Timex.to_datetime()
    school_count(start_date, today)
  end

  def school_count(nil, end_date) do
    epoch = Timex.zero() |> Timex.to_datetime()
    school_count(epoch, end_date)
  end

  def school_count(start_date, end_date) do
    from sc in School,
      join: st in Student,
      where: st.school_id == sc.id,
      join: l in Lesson,
      on: l.student_id == st.id,
      where:
        l.inserted_at >= ^start_date and
          l.inserted_at <= ^end_date,
      select: count(sc.id, :distinct)
  end
end
