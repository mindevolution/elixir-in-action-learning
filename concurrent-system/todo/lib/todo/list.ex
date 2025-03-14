defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new(), do: %Todo.List{}

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)

    new_entries = Map.put(
      todo_list.entries,
      todo_list.next_id,
      entry
    )

    %Todo.List{todo_list |
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
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %Todo.List{todo_list | entries: new_entries}
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
