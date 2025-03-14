defmodule KeyValueGenServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, %{}, name: __MODULE__)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  def handle_info(:cleanup, state) do
    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

end

KeyValueGenServer.start()
KeyValueGenServer.put(:name, "Elixir")
KeyValueGenServer.get(:name) |> IO.inspect()

# c("key_value_gen_server.ex")
