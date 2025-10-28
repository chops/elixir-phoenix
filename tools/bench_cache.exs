# Benchmark ETS cache performance
# Run with: mix run tools/bench_cache.exs

Mix.install([
  {:benchee, "~> 1.0"}
])

defmodule BenchCache do
  @table :bench_cache

  def setup do
    :ets.new(@table, [:set, :public, :named_table])
    # Pre-populate with some data
    for i <- 1..10_000 do
      :ets.insert(@table, {i, "value_#{i}"})
    end
  end

  def read(key) do
    case :ets.lookup(@table, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :error
    end
  end

  def write(key, value) do
    :ets.insert(@table, {key, value})
    :ok
  end

  def update(key, fun) do
    case :ets.lookup(@table, key) do
      [{^key, value}] ->
        new_value = fun.(value)
        :ets.insert(@table, {key, new_value})
        {:ok, new_value}
      [] ->
        :error
    end
  end
end

BenchCache.setup()

Benchee.run(
  %{
    "cache read (hit)" => fn -> BenchCache.read(5000) end,
    "cache read (miss)" => fn -> BenchCache.read(99_999) end,
    "cache write" => fn -> BenchCache.write(:test_key, "test_value") end,
    "cache update" => fn -> BenchCache.update(5000, &(&1 <> "_updated")) end
  },
  time: 5,
  memory_time: 2,
  formatters: [
    Benchee.Formatters.Console
  ]
)
