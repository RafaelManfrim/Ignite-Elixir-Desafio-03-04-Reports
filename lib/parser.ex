defmodule GenReport.Parser do
  def parse_file(file) do
    file |> File.stream!() |> Stream.map(fn line -> parse_line(line) end)
  end

  defp parse_line(line) do
    [name, working_hours, day, month, year] =
      line
      |> String.trim()
      |> String.split(",")

    lowercase_name = String.downcase(name)
    integer_working_hours = String.to_integer(working_hours)
    integer_day = String.to_integer(day)

    interger_month = String.to_integer(month)

    monts_names = [
      "janeiro",
      "fevereiro",
      "março",
      "abril",
      "maio",
      "junho",
      "julho",
      "agosto",
      "setembro",
      "outubro",
      "novembro",
      "dezembro"
    ]

    {:ok, month_name} = Enum.fetch(monts_names, interger_month - 1)

    integer_year = String.to_integer(year)

    [lowercase_name, integer_working_hours, integer_day, month_name, integer_year]
  end
end
