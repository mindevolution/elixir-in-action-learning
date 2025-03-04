defmodule LargeLines do
  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.filter(&(String.length(&1) > 80))
  end

  def lines_length(path) do
    File.stream!(path)
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.with_index()
    |> Enum.each(fn {line, index} ->
      IO.puts("#{index + 1}: #{String.length(line)}")
    end)
  end

  def longest_line_length!(path) do
    File.stream!(path)
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&String.length/1)
    |> Enum.with_index()
    |> Enum.max()
  end

  def longest_line!(path) do
    {length, index} = longest_line_length!(path)
    File.stream!(path)
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.at(index)
  end

  def words_per_line!(path) do
    File.stream!(path)
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(fn line ->
      length(String.split(line, ~r/\s+/))
    end)
    |> Enum.with_index() # Enum.with_index/1 is a function that takes a collection and returns a collection of tuples where the first element of each tuple is an element from the original collection and the second element is the index of that element in the original collection.
  end
end
