defmodule Todo.Server do
  use GenServer
  def start do
    GenServer.start(__MODULE__, Todo.List.new(), name: __MODULE__)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def update_entry(entry_id, update_func) do
    GenServer.cast(__MODULE__, {:update_entry, entry_id, update_func})
  end

  def delete_entry(entry) do
    GenServer.cast(__MODULE__, {:delete, entry})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_func}, todo_list) do
    new_state = Todo.List.update_entry(todo_list, entry_id, update_func)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:delete, entry}, todo_list) do
    new_state = Todo.List.delete_entry(todo_list, entry)
    {:noreply, new_state}
  end
end
