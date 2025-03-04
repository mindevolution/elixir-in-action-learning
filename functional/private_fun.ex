defmodule TestPrivate do
  alias IO, as: MyIO

  def double(a) do
    sum(a, a)
    MyIO.puts "The sum of #{a} and #{a} is #{sum(a, a)}"
  end

  defp sum(a, b) do
    a + b
  end
end
