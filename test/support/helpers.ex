defmodule LifetownClinic.Helpers do
  def contains_all?(enumerable, expected) do
    Enum.count(enumerable) == Enum.count(expected) and
      Enum.all?(enumerable, fn e -> Enum.member?(expected, e) end)
  end

  def days_ago(count) do
    Timex.today() |> Timex.shift(days: -count)
  end

  def last_week, do: days_ago(7)
  def last_month, do: days_ago(30)
  def yesterday, do: days_ago(1)
  def today, do: Timex.today()
end
