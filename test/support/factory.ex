defmodule LifetownClinic.Factory do
  use ExMachina.Ecto, repo: LifetownClinic.Repo
  alias LifetownClinic.Schema.School

  def school_factory do
    %School{
      name:
        "#{Faker.Address.city()} #{Enum.random(["High School", "Middle School", "Elementary"])}"
    }
  end
end
