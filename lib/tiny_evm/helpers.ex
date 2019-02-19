defmodule TinyEVM.Helpers do
  @doc """
  Inverts a map so each key becomes a value,
  and vice versa.

  ## Examples

      iex> TinyEVM.Helpers.invert(%{a: 5, b: 10})
      %{5 => :a, 10 => :b}

      iex> TinyEVM.Helpers.invert(%{dog: "cat"})
      %{"cat" => :dog}

      iex> TinyEVM.Helpers.invert(%{cow: :moo})
      %{moo: :cow}

      iex> TinyEVM.Helpers.invert(%{"name" => "bob"})
      %{"bob" => "name"}

      iex> TinyEVM.Helpers.invert(%{})
      %{}
  """
  @spec invert(map()) :: map()
  def invert(map) do
    map
    |> Enum.into([])
    |> Enum.map(fn {x, y} -> {y, x} end)
    |> Enum.into(%{})
  end
end
