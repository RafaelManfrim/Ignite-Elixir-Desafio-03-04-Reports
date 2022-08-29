defmodule GenReport do
  alias GenReport.Parser

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> calculate_hours(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please provide a list of strings"}
  end

  def build_from_many(filenames) do
    result =
      Task.async_stream(filenames, fn file -> build(file) end)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
  end

  defp report_acc(all_hours \\ %{}, hours_per_month \\ %{}, hours_per_year \\ %{}) do
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

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)

    hours_per_month =
      Map.merge(hours_per_month1, hours_per_month2, fn _key, map1, map2 ->
        merge_maps(map1, map2)
      end)

    hours_per_year =
      Map.merge(hours_per_year1, hours_per_year2, fn _key, map1, map2 ->
        merge_maps(map1, map2)
      end)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end
end
