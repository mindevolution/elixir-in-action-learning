defmodule Polymorphic do
    def double(x) when is_number(x), do: 2 * x
    def doulbe(x) when is_binary(x), do: x <> x
end