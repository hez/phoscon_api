defmodule PhosconAPI.TemperatureSensor do
  @known_models ["lumi.weather"]
  @divisor 100.0

  @spec all :: {:ok, any()} | {:error, String.t()}
  def all do
    case PhosconAPI.sensors() do
      {:ok, resp} ->
        resp
        |> Enum.filter(&Enum.member?(@known_models, elem(&1, 1)["modelid"]))
        |> Enum.map(&elem(&1, 1))

      {:error, _} = err ->
        err
    end
  end

  def convert(sensors) do
    sensors
    |> Enum.group_by(& &1["name"])
    |> Enum.map(fn {k, v} -> {k, to_struct(v)} end)
  end

  def to_struct(vals) do
    vals
    |> Enum.map(fn %{"state" => state} -> Map.delete(state, "lastupdated") end)
    |> Enum.reduce(fn x, acc -> Map.merge(acc, x) end)
    |> Enum.map(&convert_vals/1)
    |> Enum.into(%{})
  end

  defp convert_vals({"temperature", v}), do: {:temperature, v / @divisor}
  defp convert_vals({"humidity", v}), do: {:humidity, v / @divisor}
  defp convert_vals({"pressure", v}), do: {:pressure, v}
end
