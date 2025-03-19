defmodule Todo.ListTest do
  use ExUnit.Case

  test "new list" do
    assert Todo.List.new().entries == %{}
  end

  test "add entry" do
    entry = %{date: ~D[2021-01-01], title: "New Year's Day", id: 1}
    entries = Todo.List.new() |>
      Todo.List.add_entry(entry) |>
      Todo.List.entries(~D[2021-01-01])

    assert entries == [entry]
  end
end
