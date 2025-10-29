# Phase 15 — AI/ML Integration

Integrate numerical computing and machine learning models into Elixir applications.

## Books
- **Genetic Algorithms in Elixir** (Sean Moriarity)
- **Machine Learning in Elixir** (José Valim et al. - follow the development)

## Docs
- **Nx (Numerical Elixir)**
  https://hexdocs.pm/nx/Nx.html

- **Axon (Deep Learning)**
  https://hexdocs.pm/axon/Axon.html

- **Bumblebee (Pre-trained Models)**
  https://hexdocs.pm/bumblebee/Bumblebee.html

- **Explorer (Dataframes)**
  https://hexdocs.pm/explorer/Explorer.html

## Supplements
- **Livebook as a tool for ML experimentation**
  https://livebook.dev/

- **DockYard Blog on Elixir AI**
  https://dockyard.com/blog/categories/elixir-and-ai

- **ElixirConf talks on Nx, Axon, and Bumblebee**
---

================================================================================

NO PHASE 15 CONTENT IN TRANSCRIPT - NEEDS MANUAL CREATION.    

Phase 15 — AI/ML Integration

Scope

Nx basics, Axon, Bumblebee, Explorer, NIF safety, Port-based serving, batching and backpressure, Livebook workflows. The transcript only hints at “Advanced numerics and ML” targets: Nx/Axon, NIF safety, Ports, batching/backpressure.      

Reading guide
	•	Books: “Genetic Algorithms in Elixir” (Moriarity); “Machine Learning in Elixir” (Valim et al.).
	•	Docs: Nx, Axon, Bumblebee, Explorer, Livebook.
	•	Safety: NIF vs Port integration patterns.  

Key patterns

Nx essentials
	•	Tensors, shapes, dtypes. Pure numerical functions with Nx.Defn.
	•	Compile with EXLA when available for CPU/GPU acceleration.

Mix.install([:nx, :exla])

import Nx.Defn

defn normalize(x, mean, std), do: (x - mean) / std

x = Nx.tensor([[1.0, 2.0], [3.0, 4.0]])
y = normalize(x, Nx.mean(x), Nx.standard_deviation(x))
IO.inspect(y)

Axon quickstart
	•	Define and train small MLPs for tabular data.

Mix.install([:nx, :axon, :exla])

x = Nx.random_uniform({1024, 8})
y = Nx.greater(Nx.sum(x, axes: [1]), 4.0) |> Nx.as_type(:u8)

model =
  Axon.input("x", shape: {nil, 8})
  |> Axon.dense(16, activation: :relu)
  |> Axon.dense(1, activation: :sigmoid)

state = Axon.Loop.trainer(model, :binary_cross_entropy, Axon.Optimizers.adam(1.0e-3))
|> Axon.Loop.run(%{"x" => x, "label" => y}, epochs: 5, compiler: EXLA)

Bumblebee with Nx.Serving
	•	Load a pre-trained text classifier and expose Nx.Serving.

Mix.install([:nx, :exla, :bumblebee])

{:ok, model_info} =
  Bumblebee.load_model({:hf, "distilbert-base-uncased-finetuned-sst-2-english"})

{:ok, tokenizer} =
  Bumblebee.load_tokenizer({:hf, "distilbert-base-uncased-finetuned-sst-2-english"})

serving =
  Bumblebee.Text.text_classification(model_info, tokenizer, compile: [batch_size: 8], defn_options: [compiler: EXLA])

Nx.Serving.run(serving, "Elixir makes this easy.")

Explorer data prep
	•	DataFrames for CSV and feature engineering.

Mix.install([:explorer])

alias Explorer.DataFrame, as: DF
df = DF.from_csv!("data/train.csv")
df = DF.mutate(df, z = (df.score - DF.mean(df, :score)) / DF.sd(df, :score))
DF.head(df, 5)

NIF safety vs Ports
	•	Prefer Ports or external services for isolation. Keep NIFs short; use dirty schedulers if unavoidable.  

# Port-based Python model runner with a length-prefixed binary protocol
defmodule PyPort do
  use GenServer
  @opts [:binary, packet: 2, :nouse_stdio, :exit_status]
  def start_link(cmd \\ "python model.py"), do: GenServer.start_link(__MODULE__, cmd, name: __MODULE__)
  def predict(input, timeout \\ 1_000), do: GenServer.call(__MODULE__, {:predict, input}, timeout)

  def init(cmd), do: {:ok, Port.open({:spawn, cmd}, @opts)}
  def handle_call({:predict, payload}, from, port) do
    ref = make_ref()
    bin = :erlang.term_to_binary({ref, payload})
    true = Port.command(port, bin)
    {:noreply, {port, %{ref => from}}}
  end
  def handle_info({port, {:data, bin}}, {port, inflight}) do
    {ref, result} = :erlang.binary_to_term(bin)
    GenServer.reply(inflight[ref], {:ok, result})
    {:noreply, {port, Map.delete(inflight, ref)}}
  end
  def handle_info({port, {:exit_status, _}}, _), do: {:stop, :port_crashed, port}
end

Batching + backpressure for inference
	•	Batch by size N or timeout T. Reject or shed load above queue threshold.  

defmodule BatchServer do
  use GenServer
  @max 64
  @flush_ms 50
  @queue_limit 200

  def start_link(serving), do: GenServer.start_link(__MODULE__, serving, name: __MODULE__)
  def infer(item), do: GenServer.call(__MODULE__, {:infer, item})

  def init(serving), do: {:ok, %{srv: serving, q: [], refs: %{}}, {:continue, :tick}}
  def handle_continue(:tick, st), do: (Process.send_after(self(), :flush, @flush_ms); {:noreply, st})

  def handle_call({:infer, item}, from, %{q: q} = st) when length(q) >= @queue_limit,
    do: {:reply, {:error, :busy}, st}

  def handle_call({:infer, item}, from, st) do
    ref = make_ref()
    {:noreply, put_in(enqueue(st, {ref, from, item})), {:continue, :maybe}}
  end

  def handle_continue(:maybe, st) do
    if length(st.q) >= @max, do: send(self(), :flush)
    {:noreply, st}
  end

  def handle_info(:flush, %{srv: srv, q: q, refs: refs} = st) when q != [] do
    {refs2, batch} =
      Enum.reduce(q, {refs, []}, fn {ref, from, item}, {r, b} -> {Map.put(r, ref, from), [item | b]} end)

    results = Nx.Serving.run(srv, Enum.reverse(batch))
    Enum.zip(Map.keys(refs2), List.wrap(results))
    |> Enum.each(fn {ref, res} -> GenServer.reply(refs2[ref], {:ok, res}) end)

    {:noreply, %{st | q: [], refs: %{}}, {:continue, :tick}}
  end

  def handle_info(:flush, st), do: {:noreply, st, {:continue, :tick}}

  defp enqueue(st, tuple), do: update_in(st.q, &([tuple | &1]))
end

Livebook workflow
	•	Use .livemd to iterate: load data with Explorer, prototype Nx.Defn, wrap with Nx.Serving, then export to app code.

Minimal service wiring

# apps/pulse_ai/lib/pulse_ai/serving.ex
defmodule PulseAI.Serving do
  def child_spec(_) do
    {:ok, model} = Bumblebee.load_model({:hf, "distilbert-base-uncased-finetuned-sst-2-english"})
    {:ok, tok}   = Bumblebee.load_tokenizer({:hf, "distilbert-base-uncased-finetuned-sst-2-english"})
    srv = Bumblebee.Text.text_classification(model, tok, compile: [batch_size: 16])
    %{id: __MODULE__, start: {BatchServer, :start_link, [srv]}}
  end
end

# apps/pulse_web/lib/pulse_web/controllers/ai_controller.ex
defmodule PulseWeb.AIController do
  use PulseWeb, :controller
  def classify(conn, %{"q" => q}) do
    case BatchServer.infer(q) do
      {:ok, res} -> json(conn, res)
      {:error, :busy} -> send_resp(conn, 429, "busy")
    end
  end
end

Operational guidance
	•	Keep ML loads out of GenServer init/1. Use handle_continue/2.  
	•	Prefer Ports over NIFs for non-trivial native code or external runtimes. Version the wire protocol.  
	•	Integrate load shedding and bounded queues at service edges.  

⸻

Phase 15 Drills

Core Skills to Practice
	•	Build and run Nx.Defn functions and compile with EXLA.
	•	Define and train a small Axon model on tabular data.
	•	Load a Bumblebee text model and expose Nx.Serving.
	•	Implement GenServer-based batching with timeout and size triggers.
	•	Wrap a Python model behind a Port with a binary protocol.
	•	Use Explorer to ingest CSV and normalize features.

Exercises
	1.	Sentiment API
Load DistilBERT via Bumblebee. Expose POST /api/sentiment.
Requirements: batch size 16 or 50 ms timeout, queue limit 200, 429 on overflow, p99 < 250 ms at 100 RPS on a dev box.
	2.	Nx acceleration
Implement matmul/2 with Nx.Defn. Benchmark CPU vs EXLA using Benchee.
Success: ≥10× speedup at 2048×2048.
	3.	Axon tabular classifier
Train a 2-layer MLP on a CSV dataset using Explorer for prep.
Success: ≥90% accuracy on held-out validation; training completes < 60 s on CPU.
	4.	Port-based model server
Serve a scikit-learn model from Python behind a Port with {ref, features} → {ref, prediction} protocol. Supervise and auto-restart.
Success: Elixir process survives Python crashes; 1 s request timeout honored.
	5.	Backpressure proof
Stress the API. Show queue saturation and 429 rate. Record p50/p95/p99 before and after batching.

Common Pitfalls
	•	Loading models in init/1 blocks startup; move to handle_continue/2.  
	•	No batching leads to high p99; add size/timeout coalescing.  
	•	Using NIFs for heavy work risks VM stability; prefer Ports.  
	•	Unbounded queues cause latency explosions; enforce limits and shed load.  

Success Criteria
	•	Bumblebee model served via Nx.Serving behind a batched GenServer.
	•	Stable Port integration with supervised restarts and timeouts.  
	•	Explorer-based data prep reproducible from script.
	•	Benchee report demonstrating acceleration with EXLA.
	•	p99 latency measured and reduced under load via batching.
	•	Documented NIF vs Port decision and safety notes.  

⸻

Quick reference crib

Nx.Defn:
  import Nx.Defn
  defn f(x), do: Nx.exp(x)

Bumblebee:
  {:ok, m} = Bumblebee.load_model({:hf, ".../sst-2-english"})
  {:ok, t} = Bumblebee.load_tokenizer({:hf, ".../sst-2-english"})
  serving = Bumblebee.Text.text_classification(m, t)
  Nx.Serving.run(serving, "text")

Batching:
  size N or timeout T → flush
  queue_limit → {:error, :busy}

Ports:
  Port.open({:spawn, "python model.py"}, [:binary, packet: 2])
  receive {^port, {:data, bin}} -> decode(bin) end

NIF vs Port guidance and batching/backpressure targets are from the transcript’s optional numerics/ML section and integration notes.      

