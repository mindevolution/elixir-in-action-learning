defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "Bob's list")

    assert bob_pid != Todo.Cache.server_process(cache, "Alice's list")
    assert bob_pid == Todo.Cache.server_process(cache, "Bob's list")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()

    alice = Todo.Cache.server_process(cache, "Alice's list")
    Todo.Server.add_entry(
      alice,
      %{date: ~D[2023-12-19], title: "Dentist"}
    )

    entries = Todo.Server.entries(alice, ~D[2023-12-19])
    assert entries == [%{date: ~D[2023-12-19], title: "Dentist", id: 1}, ]

  end
end
