defmodule PhosconAPI.Telemetry do
  require Logger

  def fetch_all do
    case PhosconAPI.TemperatureSensor.all() do
      {:ok, response} ->
        response
        |> PhosconAPI.TemperatureSensor.convert()
        |> Enum.each(&fire_sensors/1)

        :ok

      {:error, _} = err ->
        Logger.error("Error fetching all sensors, #{inspect(err)}")
    end
  end

  def child_config do
    {:telemetry_poller,
     measurements: [{__MODULE__, :fetch_all, []}],
     period: :timer.seconds(PhosconAPI.interval()),
     name: :phoscon_sensors}
  end

  @spec fire_event(String.t(), map()) :: any()
  def fire_event(id, event), do: :telemetry.execute([:phoscon, :event], %{id: id}, event)

  defp fire_sensors({host, values}) do
    Enum.each(values, fn {key, reading} ->
      :telemetry.execute([:phoscon, :sensor, :read], %{key => reading}, %{host: host})
    end)
  end
end
