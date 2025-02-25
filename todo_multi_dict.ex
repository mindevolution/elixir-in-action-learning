defmodule MultiDict do
  def new, do: %{}

  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule TodoList do
  def new, do: MultiDict.new()

  def add_entry(todo_list, entry) do
    MultiDict.add(todo_list, entry.date, entry)
  end

  def entries(todo_list, date) do
    MultiDict.get(todo_list, date)
  end
end

entry1 = %{date: ~D[2021-01-01], title: "New Year's Day"}
entry2 = %{date: ~D[2021-01-01], title: "Buy champagne"}
entry3 = %{date: ~D[2021-01-02], title: "Buy aspirin"}
todo_list = TodoList.new |>
  TodoList.add_entry(entry1) |>
  TodoList.add_entry(entry2) |>
  TodoList.add_entry(entry3)

IO.puts(TodoList.entries(todo_list, ~D[2021-01-01]))
IO.puts(TodoList.entries(todo_list, ~D[2021-01-02]))
