defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      init_state = callback_module.init()
      loop(callback_module, init_state)
    end)
  end

  def loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(
          request,
          current_state
        )
        send(caller, {:response, response})

        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {request, self()})
    receive do
      {:response, response} -> response
    end
  end
end

defmodule KeyValueStore do
  def init() do
    %{}
  end

  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end

  def handle_call({:put, key, value}, state) do
    {:ok, Map.put(state, key, value)}
  end
end

pid = ServerProcess.start(KeyValueStore)
ServerProcess.call(pid, {:put, :name, "Elixir in Action"})
ServerProcess.call(pid, {:get, :name}) |> IO.puts
