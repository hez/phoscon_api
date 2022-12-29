# PhosconAPI

A simple Elixir wrapper around some of the endpoints provided by the [Phoscon](http://dresden-elektronik.github.io/deconz-rest-doc/) software.

## Installation

Add the following dependancy to mix.exs

`{:phoscon_api, github: "hez/phoscon-api", tag: "v0.3.6"}`

Add some config

```
config :phoscon_api, :connection,
  host: "http://<phoscon_host>",
  api_key: "<phoscon_api_key>"
```

Add the following to your Application to start polling.

```
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # ...
      PhosconAPI.Telemetry.child_config()
    ]
    Supervisor.start_link(children, opts)
  end
end

```

Write something to capture the telemetry events.

```
defmodule MyApp.TemperatureLogger do
  require Logger

  def log_usage([:phoscon, :sensor, :read], measurements, metadata, _conf) do
    Logger.info("Temperatures: #{inspect(measurements)} with #{inspect(metadata)}")
  end

  def attach do
    :telemetry.attach(
      "temperatures",
      [:phoscon, :sensor, :read],
      &__MODULE__.log_usage/4,
      nil
    )
  end
end
```
