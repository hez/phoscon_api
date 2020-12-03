defmodule PhosconAPI.Button do
  @callback handle(integer(), integer(), map()) :: :ok

  defmacro __using__(_) do
    quote do
      @behaviour PhosconAPI.Button
      def handle(_id, _event, _config), do: :ok
      defoverridable handle: 3
    end
  end
end
