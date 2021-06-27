defmodule PhosconAPI.Telemetry do
  require Logger

  def fetch_all do
    case PhosconAPI.TemperatureSensor.all() do
      {:ok, response} ->
        values =
          response
          |> PhosconAPI.TemperatureSensor.convert()
          |> Enum.each(fn {host, v} ->
            Enum.each(v, fn {key, reading} ->
              :telemetry.execute([:phoscon, :sensor, :read], %{key => reading}, %{host: host})
            end)
          end)

        {:ok, values}

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
end
