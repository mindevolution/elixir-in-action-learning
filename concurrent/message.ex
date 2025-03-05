send(self(), "a message")

receive do
  msg -> IO.puts("Received: #{msg}")
end

send(self(), {:message, 1})

receive do
  {:message, msg} -> IO.puts("Received: #{msg}")
end

receive_result = receive do
  {:message, x} ->
    x + 1
end

# after clause for not receiving a message
receive do
  {:message, msg} -> IO.puts("Received: #{msg}")
  after
    5000 -> IO.puts("No message received")
end


# Sending a message to a process and send back to parent
send(self(), {self(), 1})

receive do
  {caller_pid, x} -> send(caller_pid, {:response, x + 1})
end

receive do
  {:response, x} -> "Received from child #{x}"
end
