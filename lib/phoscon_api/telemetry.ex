defmodule PhosconAPI.Telemetry do
  require Logger

  def fetch_all do
    PhosconAPI.TemperatureSensor.all()
    |> PhosconAPI.TemperatureSensor.convert()
    |> Enum.each(fn {host, v} ->
      Enum.each(v, fn {key, reading} ->
        :telemetry.execute([:phoscon, :sensor, :read], %{key => reading}, %{host: host})
      end)
    end)
  end

  def start_polling do
    :telemetry_poller.start_link(
      measurements: [{__MODULE__, :fetch_all, []}],
      period: :timer.seconds(PhosconAPI.interval()),
      name: :phoscon_sensors
    )
  end
end
