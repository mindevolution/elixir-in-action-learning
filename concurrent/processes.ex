run_query =
  fn query_def ->
    Process.sleep(2000)
    "#{query_def} result" |> IO.inspect
  end


Enum.map(
  1..5,
  &run_query.("query #{&1}")
)
