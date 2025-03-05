run_query =
  fn query_def ->
    Process.sleep(2000)
    "#{query_def} result"
  end

async_query =
  fn query_def ->
    caller = self()
    spawn(fn ->
      query_result = run_query.(query_def)
      send(caller, {:query_result, query_result})
      end)
  end

Enum.each(1..5, &async_query.("query #{&1}"))

get_result =
  fn ->
    receive do
      {:query_result, query_result} -> query_result
    end
  end

 results = Enum.map(1..5, fn _ -> get_result.() end)

1..5
|> Enum.map(&async_query.("query #{&1}"))
|> Enum.map(fn _ -> get_result.() end)
