defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil,
      name: __MODULE__
    )
  end

  def store(key, value) do
    GenServer.cast(__MODULE__, {:store, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end

  def handle_cast({:store, key, value}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(value))

    {:noreply, state}
  end

  def handle_call({:get, key}, _from, state) do
    case File.read(file_name(key)) do
      {:ok, binary} -> {:reply, :erlang.binary_to_term(binary), state}
      {:error, :enoent} -> {:reply, :not_found, state}
    end
  end

  defp file_name(key) do
    Path.join(@db_folder, "#{key}.db")
  end
end
