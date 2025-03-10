defmodule Server do
  def start do
    spawn(fn -> loop() end)
  end

  def send_msg(server_pid, msg) do
    send(server_pid, {self(), msg})

    receive do
      {:response, response} -> response
    end
  end

  defp loop() do
    receive do
      {caller, msg} ->
        Process.sleep(1000)
        send(caller, {:response, "Received: #{msg}"})
    end
    loop()
  end
end

server = Server.start()
Enum.each(1..5, fn i ->
  spawn(fn ->
    IO.puts("Sending message ##{i}")
    IO.inspect(Server.send_msg(server, i))
  end)
end)
