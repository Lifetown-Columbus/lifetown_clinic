defmodule LifetownClinic.Reporting do
  import Ecto.Query

  alias LifetownClinic.Schema.{Lesson, School, Student}

  def student_count(nil, nil), do: student_count(epoch(), today())
  def student_count(start_date, nil), do: student_count(start_date, today())
  def student_count(nil, end_date), do: student_count(epoch(), end_date)

  def student_count(start_date, end_date) do
    from s in Student,
      join: l in Lesson,
      on: l.student_id == s.id,
      where:
        l.inserted_at >= ^start_date and
          l.inserted_at <= ^end_date,
      select: count(s.id, :distinct)
  end

  def school_count(nil, nil), do: school_count(epoch(), today())
  def school_count(start_date, nil), do: school_count(start_date, today())
  def school_count(nil, end_date), do: school_count(epoch(), end_date)

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

  def lesson_count(nil, nil), do: lesson_count(epoch(), today())
  def lesson_count(start_date, nil), do: lesson_count(start_date, today())
  def lesson_count(nil, end_date), do: lesson_count(epoch(), end_date)

  def lesson_count(start_date, end_date) do
    from l in Lesson,
      where:
        l.inserted_at >= ^start_date and
          l.inserted_at <= ^end_date,
      select: count(l.id, :distinct)
  end

  defp epoch, do: Timex.zero() |> Timex.to_datetime()
  defp today, do: Timex.now() |> Timex.to_datetime()
end
