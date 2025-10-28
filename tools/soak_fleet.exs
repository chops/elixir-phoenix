# Soak test for process fleet management
# Run with: mix run tools/soak_fleet.exs

defmodule SoakFleet do
  @moduledoc """
  Soak test that spawns many processes to test supervision,
  registry, and memory management over time.
  """

  def run(opts \\ []) do
    num_processes = Keyword.get(opts, :num_processes, 1000)
    duration_mins = Keyword.get(opts, :duration_mins, 10)
    spawn_rate = Keyword.get(opts, :spawn_rate, 100) # processes per second

    IO.puts("Starting soak test...")
    IO.puts("  Processes: #{num_processes}")
    IO.puts("  Duration: #{duration_mins} minutes")
    IO.puts("  Spawn rate: #{spawn_rate}/sec")

    start_time = System.monotonic_time(:second)
    end_time = start_time + (duration_mins * 60)

    spawn_processes(num_processes, spawn_rate)
    monitor_health(end_time)
  end

  defp spawn_processes(count, rate) do
    delay = div(1000, rate)

    for i <- 1..count do
      spawn_worker(i)
      if rem(i, rate) == 0 do
        Process.sleep(delay)
      end
    end
  end

  defp spawn_worker(id) do
    Task.start(fn ->
      # Simulate some work
      Process.sleep(:rand.uniform(5000))
      do_work(id)
    end)
  end

  defp do_work(id) do
    # Simulate memory allocation
    _data = for _ <- 1..100, do: :rand.uniform(1000)

    # Random sleep
    Process.sleep(:rand.uniform(2000))

    # Maybe crash (10% chance)
    if :rand.uniform(10) == 1 do
      raise "Random crash for worker #{id}"
    end
  end

  defp monitor_health(end_time) do
    if System.monotonic_time(:second) < end_time do
      stats = %{
        process_count: :erlang.system_info(:process_count),
        memory_mb: div(:erlang.memory(:total), 1_024_000),
        run_queue: :erlang.statistics(:run_queue)
      }

      IO.puts("Health: #{inspect(stats)}")
      Process.sleep(10_000) # Log every 10 seconds
      monitor_health(end_time)
    else
      IO.puts("Soak test complete!")
    end
  end
end

# Run the test
# Customize these values as needed
SoakFleet.run(
  num_processes: 1000,
  duration_mins: 2,
  spawn_rate: 50
)
