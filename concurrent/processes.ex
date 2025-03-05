run_query =
  fn query_def ->
    Process.sleep(2000)
    "#{query_def} result" |> IO.inspect
  end

async_query =
  fn query_def ->
    spawn(fn ->
      run_query.(query_def)
      end)
  end


# Enum.map(
#   1..5,
#   &run_query.("query #{&1}")
# )

spawn(fn -> run_query.("query 1") end)

Enum.map(
  1..5,
  &async_query.("query #{&1}")
)
