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
end

todo_list = TodoList.new() |>
  TodoList.add_entry(%{date: ~D[2021-01-01], title: "New Year's Day"}) |>
  TodoList.add_entry(%{date: ~D[2021-01-01], title: "Buy champagne"}) |>
  TodoList.add_entry(%{date: ~D[2021-01-02], title: "Buy aspirin"})

TodoList.entries(todo_list, ~D[2021-01-01])
TodoList.update_entry(todo_list, 2, &Map.put(&1, :date, ~D[2021-01-02]))
todo_list_new = TodoList.delete_entry(todo_list, 1)
