defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @customers %{
    "Cleiton" => 0,
    "Daniele" => 0,
    "Danilo" => 0,
    "Diego" => 0,
    "Giuliano" => 0,
    "Jakeliny" => 0,
    "Joseph" => 0,
    "Mayk" => 0,
    "Rafael" => 0,
    "Vinicius" => 0
  }

  @months %{
    "janeiro" => 0,
    "fevereiro" => 0,
    "março" => 0,
    "abril" => 0,
    "maio" => 0,
    "junho" => 0,
    "julho" => 0,
    "agosto" => 0,
    "setembro" => 0,
    "outubro" => 0,
    "novembro" => 0,
    "dezembro" => 0
  }

  @years %{
    2016 => 0,
    2017 => 0,
    2018 => 0,
    2019 => 0,
    2020 => 0
  }

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_list(), fn line, report -> sum_horas(line, report) end)
  end

  def build_for_many(file_names) do
    file_names
    |> Task.async_stream(fn file_name -> build(file_name) end)
    |> Enum.reduce(report_list(), fn {:ok, result}, report -> sum_for_many(report, result) end)
  end

  defp sum_horas(
         [id, hora, _dia, mes, ano],
         %{
           "all_hours" => horas_totais,
           "hours_per_month" => horas_meses,
           "hours_per_year" => horas_anos
         } = report
       ) do
    horas_totais = Map.put(horas_totais, id, horas_totais[id] + hora)
    horas_meses = put_in(horas_meses[id][mes], horas_meses[id][mes] + hora)
    horas_anos = put_in(horas_anos[id][ano], horas_anos[id][ano] + hora)

    report
    |> Map.put("all_hours", horas_totais)
    |> Map.put("hours_per_month", horas_meses)
    |> Map.put("hours_per_year", horas_anos)
  end

  defp sum_for_many(
         %{
           "all_hours" => horas_totais,
           "hours_per_month" => horas_meses,
           "hours_per_year" => horas_anos
         },
         %{
           "all_hours" => horas_totais2,
           "hours_per_month" => horas_mese2,
           "hours_per_year" => horas_anos2
         }
       ) do
    horas_totais = merge_map(horas_totais, horas_totais2)
    horas_meses = merge_map_in_map(horas_meses, horas_mese2)
    horas_anos = merge_map_in_map(horas_anos, horas_anos2)

    estruturas(horas_totais, horas_meses, horas_anos)
  end

  defp merge_map(map1, map2) do
    Map.merge(map1, map2, fn _k, v, v2 -> v + v2 end)
  end

  defp merge_map_in_map(map1, map2) do
    Map.merge(map1, map2, fn _k, v, v2 -> merge(v, v2) end)
  end

  defp merge(map1, map2) do
    Map.merge(map1, map2, fn _key, v, v2 -> v + v2 end)
  end

  defp report_list() do
    horas_totais = @customers
    horas_meses = estrutura_meses()
    horas_anos = estrutura_anos()

    estruturas(horas_totais, horas_meses, horas_anos)
  end

  defp estrutura_meses() do
    Enum.reduce(@customers, %{}, fn {name, _value}, acc -> Map.put(acc, name, @months) end)
  end

  defp estrutura_anos() do
    Enum.reduce(@customers, %{}, fn {name, _value}, acc -> Map.put(acc, name, @years) end)
  end

  defp estruturas(horas_totais, horas_meses, horas_anos) do
    %{
      "all_hours" => horas_totais,
      "hours_per_month" => horas_meses,
      "hours_per_year" => horas_anos
    }
  end
end
