defmodule Fraction do
  defstruct a: nil, b: nil

  def new(a, b) do
    %Fraction{a: a, b: b}
  end

  def value(%Fraction{a: a, b: b}) do
    a / b
  end

  def add(%Fraction{a: a, b: b}, %Fraction{a: c, b: d}) do
    new(
      a * d + c * b,
      b * d)
  end
end


Fraction.new(1, 2)
|> Fraction.add(Fraction.new(1, 4))
|> Fraction.value()
|> IO.puts
