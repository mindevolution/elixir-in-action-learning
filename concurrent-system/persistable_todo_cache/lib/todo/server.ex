defmodule Todo.Server do
  use GenServer
  def start(list_name) do
    GenServer.start(__MODULE__, {list_name, Todo.List.new()})
  end

  def init(todo_list) do
    {:ok, todo_list}
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def update_entry(todo_server, entry_id, update_func) do
    GenServer.cast(todo_server, {:update_entry, entry_id, update_func})
  end

  def delete_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:delete, entry})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_func}, {name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry_id, update_func)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete, entry}, {name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, entry)
    {:noreply, {name, new_list}}
  end
end
