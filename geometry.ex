defmodule Geometry do
  def rectangle_area(a, b), do: a * b

  def square_area(a), do: rectangle_area(a, a)

  defmodule Circle do
    def area(r) do
      3.14 * r * r
    end
  end
end

defmodule Program do
  def run do
  end
end
