defmodule PhosconAPI.WebSocket do
  @moduledoc """
  When started this module connects a websocket to a Phoscon server and listens for events.

  ## Example Events

  ### Button single press

    ```
    %{"e" => "changed", "id" => "26", "r" => "sensors", "state" => %{"buttonevent" => 1000, "lastupdated" => "2020-12-03T19:47:29.758"}, "t" => "event", "uniqueid" => "00:15:8d:00:04:08:11:d2-01-0006"}
    %{"e" => "changed", "id" => "26", "r" => "sensors", "state" => %{"buttonevent" => 1002, "lastupdated" => "2020-12-03T19:47:29.964"}, "t" => "event", "uniqueid" => "00:15:8d:00:04:08:11:d2-01-0006"}
    ```

  ### Button double press

  `%{"e" => "changed", "id" => "26", "r" => "sensors", "state" => %{"buttonevent" => 1004, "lastupdated" => "2020-12-03T19:46:45.179"}, "t" => "event", "uniqueid" => "00:15:8d:00:04:08:11:d2-01-0006"}`

  ### Button long press

    ```
    %{"e" => "changed", "id" => "26", "r" => "sensors", "state" => %{"buttonevent" => 1000, "lastupdated" => "2020-12-03T19:47:54.575"}, "t" => "event", "uniqueid" => "00:15:8d:00:04:08:11:d2-01-0006"}
    %{"e" => "changed", "id" => "26", "r" => "sensors", "state" => %{"buttonevent" => 1001, "lastupdated" => "2020-12-03T19:47:55.145"}, "t" => "event", "uniqueid" => "00:15:8d:00:04:08:11:d2-01-0006"}
    %{"e" => "changed", "id" => "26", "r" => "sensors", "state" => %{"buttonevent" => 1003, "lastupdated" => "2020-12-03T19:47:56.653"}, "t" => "event", "uniqueid" => "00:15:8d:00:04:08:11:d2-01-0006"}
    ```
  """

  use WebSockex

  require Logger

  def start_link(opts),
    do: opts |> Keyword.get(:url) |> WebSockex.start_link(__MODULE__, %{})

  @impl WebSockex
  def handle_frame({:text, msg}, state) do
    msg
    |> Jason.decode()
    |> handle_event()

    {:ok, state}
  end

  def handle_frame({type, msg}, state) do
    Logger.debug(
      "Received unhandled message - Type: #{inspect(type)} -- Message: #{inspect(msg)}"
    )

    {:ok, state}
  end

  @impl WebSockex
  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.debug("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  defp handle_event({:ok, %{"uniqueid" => event_id} = event}),
    do: PhosconAPI.Telemetry.fire_event(event_id, event)

  defp handle_event({:ok, msg}), do: Logger.info("Unhandled event #{inspect(msg)}")
  defp handle_event({:error, msg}), do: Logger.error("Error decoding event #{inspect(msg)}")
end
