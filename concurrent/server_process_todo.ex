defmodule TodoServer do
  def start do
    ServerProcess.start(TodoServer)
  end

  def init do
    TodoList.new()
  end

  def add_entry(todo_sever, new_entry) do
    ServerProcess.cast(todo_sever, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    ServerProcess.call(todo_server, {:entries, date})
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end

end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      init_state = callback_module.init()
      loop(callback_module, init_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})
    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  def loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(
          request,
          current_state
        )
        send(caller, {:response, response})

        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
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
