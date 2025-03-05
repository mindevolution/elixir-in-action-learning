defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new()) end)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry_id, update_func) do
    send(todo_server, {:update_entry, entry_id, update_func})
  end

  def delete_entry(todo_server, entry) do
    send(todo_server, {:delete, entry})
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, entry_id, update_func}) do
    TodoList.update_entry(todo_list, entry_id, update_func)
  end

  defp process_message(todo_list, {:delete, entry}) do
    TodoList.delete_entry(todo_list, entry)
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})
    receive do
      {:entries, entries} -> entries
    after 5000 -> {:error, :timeout}
    end
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
TodoServer.add_entry(todo_server, %{date: ~D[2021-01-01], title: "New Year's Day"})
TodoServer.add_entry(todo_server, %{date: ~D[2021-01-01], title: "Buy champagne"})
TodoServer.add_entry(todo_server, %{date: ~D[2021-01-02], title: "Buy book"})
TodoServer.add_entry(todo_server, %{date: ~D[2021-01-02], title: "Go shopping"})
TodoServer.add_entry(todo_server, %{date: ~D[2021-01-03], title: "Buy food"})
TodoServer.add_entry(todo_server, %{date: ~D[2021-01-03], title: "Buy food again"})

TodoServer.entries(todo_server, ~D[2021-01-03]) |> IO.inspect()
TodoServer.update_entry(todo_server, 5, fn entry -> Map.put(entry, :title, "Buy more food") end)
TodoServer.entries(todo_server, ~D[2021-01-03]) |> IO.inspect()
TodoServer.delete_entry(todo_server, 5)
TodoServer.entries(todo_server, ~D[2021-01-03]) |> IO.inspect()
