defmodule Todo.Cache do
  @moduledoc """
  Cache module
  """
  use GenServer

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start()
        {
          :reply,
          new_server,
          Map.put(todo_servers, todo_list_name, new_server)
        }
        {:error, {_, pid}} ->
          {:reply, pid, todo_servers}
    end
  end

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

end

# {:ok, cache} = Todo.Cache.start()

# Todo.Cache.server_process(cache, "Bob's list") |> IO.inspect
# Todo.Cache.server_process(cache, "Bob's list") |> IO.inspect
# Todo.Cache.server_process(cache, "Bob's list") |> IO.inspect
# Todo.Cache.server_process(cache, "Alice's list") |> IO.inspect
