defmodule GenReport do
  alias GenReport.Parser

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> calculate_hours(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  defp report_acc do
    all_hours = %{}
    hours_per_month = %{}
    hours_per_year = %{}

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp calculate_hours(
         [name, working_hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         } = report
       ) do
    worked_hours = if is_nil(all_hours[name]), do: 0, else: all_hours[name]

    all_hours = Map.put(all_hours, name, worked_hours + working_hours)

    hours_per_month =
      Map.put(
        hours_per_month,
        name,
        calculate_hours_per_month(hours_per_month[name], working_hours, month)
      )

    hours_per_year =
      Map.put(
        hours_per_year,
        name,
        calculate_hours_per_year(hours_per_year[name], working_hours, year)
      )

    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => hours_per_month,
        "hours_per_year" => hours_per_year
    }
  end

  defp calculate_hours_per_month(map, working_hours, month) do
    freelancer_hours_per_month_map = if is_nil(map), do: %{}, else: map
    freelancer_hours_per_month = if is_nil(map[month]), do: 0, else: map[month]

    Map.put(
      freelancer_hours_per_month_map,
      month,
      working_hours + freelancer_hours_per_month
    )
  end

  defp calculate_hours_per_year(map, working_hours, year) do
    freelancer_hours_per_year_map = if is_nil(map), do: %{}, else: map
    freelancer_hours_per_year = if is_nil(map[year]), do: 0, else: map[year]

    Map.put(
      freelancer_hours_per_year_map,
      year,
      working_hours + freelancer_hours_per_year
    )
  end
end
