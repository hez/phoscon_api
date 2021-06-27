defmodule PhosconAPI do
  @moduledoc """
  Elixir API implementation of http://dresden-elektronik.github.io/deconz-rest-doc/
  """

  @spec sensors :: {:ok, any()} | {:error, String.t()}
  def sensors do
    client()
    |> Tesla.get("/api/#{api_key()}/sensors")
    |> response_parse()
  end

  defp response_parse({:ok, %_{body: body}}), do: Jason.decode(body)
  defp response_parse({:error, msg}), do: {:error, inspect(msg)}

  defp client do
    middleware = [{Tesla.Middleware.BaseUrl, host()}]
    Tesla.client(middleware)
  end

  def host, do: config_fetch(:host)
  def api_key, do: config_fetch(:api_key)
  def interval, do: config_fetch(:refresh_interval) || 60

  defp config_fetch(key),
    do: :phoscon_api |> Application.get_env(:connection, []) |> Keyword.get(key)
end
