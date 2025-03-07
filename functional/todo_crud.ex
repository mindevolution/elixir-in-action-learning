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

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done) do
    todo_list
  end
  defp into_callback(_todo_list, :halt) do
    :ok
  end
end

defmodule TodoList.CsvImporter do
  def import(file) do
    File.stream!(file)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&parse_entry/1)
    |> TodoList.new()
  end

  def parse_entry(entry) do
    [date, title] = String.split(entry, ",")
    %{date: Date.from_iso8601!(date), title: title}
  end
end



todo_list = TodoList.new() |>
  TodoList.add_entry(%{date: ~D[2021-01-01], title: "New Year's Day"}) |>
  TodoList.add_entry(%{date: ~D[2021-01-01], title: "Buy champagne"}) |>
  TodoList.add_entry(%{date: ~D[2021-01-02], title: "Buy aspirin"})

TodoList.entries(todo_list, ~D[2021-01-01])
TodoList.update_entry(todo_list, 2, &Map.put(&1, :date, ~D[2021-01-02]))
todo_list_new = TodoList.delete_entry(todo_list, 1)
