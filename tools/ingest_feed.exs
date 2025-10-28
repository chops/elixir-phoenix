# Simulate data feed ingestion for Broadway testing
# Run with: mix run tools/ingest_feed.exs

defmodule IngestFeed do
  @moduledoc """
  Generates test data for ingestion pipeline testing.
  Outputs JSON events to stdout or a file.
  """

  def generate_events(count, opts \\ []) do
    output = Keyword.get(opts, :output, :stdout)
    delay_ms = Keyword.get(opts, :delay_ms, 100)

    events = for i <- 1..count do
      event = create_event(i)
      write_event(event, output)

      if delay_ms > 0 do
        Process.sleep(delay_ms)
      end

      event
    end

    IO.puts("\nGenerated #{length(events)} events")
  end

  defp create_event(id) do
    event_types = [:order_created, :order_updated, :order_cancelled, :payment_received]
    event_type = Enum.random(event_types)

    %{
      id: id,
      type: event_type,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      payload: create_payload(event_type, id),
      metadata: %{
        source: "test_generator",
        version: "1.0"
      }
    }
  end

  defp create_payload(:order_created, id) do
    %{
      order_id: "ORD-#{id}",
      user_id: :rand.uniform(1000),
      total: :rand.uniform(1000) + 0.99,
      items: [
        %{product_id: :rand.uniform(100), quantity: :rand.uniform(5)}
      ]
    }
  end

  defp create_payload(:order_updated, id) do
    %{
      order_id: "ORD-#{id}",
      status: Enum.random([:processing, :shipped, :delivered])
    }
  end

  defp create_payload(:order_cancelled, id) do
    %{
      order_id: "ORD-#{id}",
      reason: Enum.random(["customer_request", "out_of_stock", "payment_failed"])
    }
  end

  defp create_payload(:payment_received, id) do
    %{
      order_id: "ORD-#{id}",
      amount: :rand.uniform(1000) + 0.99,
      payment_method: Enum.random(["card", "paypal", "crypto"])
    }
  end

  defp write_event(event, :stdout) do
    IO.puts(Jason.encode!(event))
  end

  defp write_event(event, {:file, path}) do
    File.write!(path, Jason.encode!(event) <> "\n", [:append])
  end
end

# Install Jason for JSON encoding
Mix.install([{:jason, "~> 1.4"}])

# Generate 100 events with 100ms delay between each
IngestFeed.generate_events(100, delay_ms: 100)
