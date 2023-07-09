defmodule PhosconAPI.EventHandler do
  require Logger

  # Button event
  def handle_event(
        [:phoscon, :event],
        measurements,
        %{
          "e" => "changed",
          "t" => "event",
          "id" => id,
          "state" => %{"buttonevent" => buttonevent}
        } = event,
        conf
      ) do
    Logger.debug(inspect(measurements))
    Logger.debug(inspect(event))
    Logger.debug(inspect(conf))

    id
    |> String.to_integer()
    |> handle_button_event(buttonevent)
  end

  def handle_event([:phoscon, :event], _, _, _), do: :ok

  def attach do
    :ok =
      :telemetry.attach(
        "homehub-phoscon-events",
        [:phoscon, :event],
        &__MODULE__.handle_event/4,
        nil
      )
  end

  defp handle_button_event(id, buttonevent) do
    case PhosconAPI.ButtonsTable.get(id) do
      {:ok, %{handler: {mod, fun, args}}} ->
        apply(mod, fun, [id, buttonevent, args])

      _ ->
        Logger.error("Unable to find button id: #{inspect(id)}")
    end
  end
end
