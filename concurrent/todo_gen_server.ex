defmodule TodoServer do
  use GenServer
  def start do
    GenServer.start(__MODULE__, TodoList.new(), name: __MODULE__)
  end

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  def update_entry(entry_id, update_func) do
    GenServer.cast(__MODULE__, {:update_entry, entry_id, update_func})
  end

  def delete_entry(entry) do
    GenServer.cast(__MODULE__, {:delete, entry})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    new_state = TodoList.add_entry(todo_list, new_entry)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_func}, todo_list) do
    new_state = TodoList.update_entry(todo_list, entry_id, update_func)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_cast({:delete, entry}, todo_list) do
    new_state = TodoList.delete_entry(todo_list, entry)
    {:noreply, new_state}
  end

end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )

    %TodoList{todo_list |
      next_id: todo_list.next_id + 1,
      entries: new_entries
    }
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      new(),
      &add_entry(&2, &1)
    )
  end

  defimpl String.Chars do
    def to_string(todo_list) do
      Enum.map(todo_list.entries, fn {id, entry} ->
        "#{id}: #{entry.date} - #{entry.title}"
      end)
      |> Enum.join("\n")
    end
  end
end

todo_server = TodoServer.start()
TodoServer.add_entry(%{date: ~D[2021-01-01], title: "New Year's Day"})
TodoServer.add_entry(%{date: ~D[2021-01-01], title: "Buy champagne"})
TodoServer.add_entry(%{date: ~D[2021-01-02], title: "Buy book"})
TodoServer.add_entry(%{date: ~D[2021-01-02], title: "Go shopping"})
TodoServer.add_entry(%{date: ~D[2021-01-03], title: "Buy food"})
TodoServer.add_entry(%{date: ~D[2021-01-03], title: "Buy food again"})

TodoServer.entries(~D[2021-01-03]) |> IO.inspect()

TodoServer.update_entry(5, fn entry -> Map.put(entry, :title, "Buy more food updated to be deleted") end)
TodoServer.entries(~D[2021-01-03]) |> IO.inspect()

TodoServer.delete_entry(5)
TodoServer.entries(~D[2021-01-03]) |> IO.inspect()

# c("todo_gen_server.ex")
