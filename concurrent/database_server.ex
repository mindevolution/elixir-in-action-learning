defmodule DatabaseServer do
  def start do
    spawn(&loop/0)
  end

  defp run_query(query_def) do
    Process.sleep(2000)
    "#{query_def} result"
  end

  defp loop do
    receive do
      {:run_query, caller, query_def} ->
        query_result = run_query(query_def)
        send(caller, {:query_result, query_result})
    end
    loop()
  end

  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self(), query_def})
  end

  def get_result do
    receive do
      {:query_result, query_result} -> query_result
    after
      5000 -> {:error, :timeout}
    end
  end
end

pool = Enum.map(1..10000, fn _ -> DatabaseServer.start end)
Enum.each(
  1..100,
  fn query_def ->
    server_pid = Enum.random(pool)
    DatabaseServer.run_async(server_pid, query_def)
  end
)

Enum.each(
  1..100,
  fn _ ->
    IO.inspect(DatabaseServer.get_result())
  end
)
