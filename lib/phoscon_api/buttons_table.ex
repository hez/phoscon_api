defmodule PhosconAPI.ButtonsTable do
  @table_name __MODULE__

  def create!(buttons) do
    create_table!()

    Enum.each(buttons, &set/1)
  end

  defp create_table!,
    do: :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])

  def all do
    @table_name
    |> :ets.tab2list()
    |> Map.new()
  end

  @spec get(integer()) :: {:ok, map()} | :error
  def get(id) do
    case :ets.lookup(@table_name, id) do
      [{^id, button}] -> {:ok, button}
      [] -> :error
    end
  end

  @spec set(map()) :: :ok
  def set(%{id: id} = button) do
    :ets.insert(@table_name, {id, button})
    :ok
  end
end
