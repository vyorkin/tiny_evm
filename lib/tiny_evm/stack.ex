defmodule TinyEVM.Stack do
  @moduledoc """
  Operations to read / write to the EVM's stack.
  """

  defmodule Overflow do
    @moduledoc """
    Exception that is raised when the stack overflows
    because it contains too many items.
    """
    defexception [:message]
  end

  alias TinyEVM.Hex

  @type val :: integer()
  @type t :: [val()]

  # Stack has a maximum size of 1024 elements.
  @max_size 1024

  defguardp is_overflow(stack)
            when Kernel.length(stack) > @max_size

  @doc """
  Pushes value to the stack.

  ## Examples

      iex> TinyEVM.Stack.push([], 1)
      [1]

      iex> TinyEVM.Stack.push([2, 3], 1)
      [1, 2, 3]

      iex> TinyEVM.Stack.push([], [1, 2])
      [1, 2]

      iex> TinyEVM.Stack.push([3, 4], [1, 2])
      [1, 2, 3, 4]
  """
  @spec push(t(), val() | [val()]) :: t()
  def push(stack, val) when is_overflow(stack) do
    raise Overflow, "Stack overflow when attempting to push value: #{val}"
  end

  def push(stack, val) when is_list(val), do: val ++ stack
  def push(stack, val), do: [val | stack]

  @doc """
  Pops value from the stack, returning a new
  stack with value popped.

  ## Examples

      iex> TinyEVM.Stack.pop([])
      {nil, []}

      iex> TinyEVM.Stack.pop([1])
      {1, []}

      iex> TinyEVM.Stack.pop([2, 3, 4])
      {2, [3, 4]}
  """
  @spec pop(t()) :: {val(), t()}
  def pop([]), do: {nil, []}
  def pop([val | stack]), do: {val, stack}

  @doc """
  Pops multiple values off of stack, returning a new sack
  ess that many elements.

  Raises if stack contains insufficient elements.

  ## Examples

      iex> TinyEVM.Stack.pop_n([1, 2, 3], 0)
      {[], [1, 2, 3]}

      iex> TinyEVM.Stack.pop_n([1, 2, 3], 1)
      {[1], [2, 3]}

      iex> TinyEVM.Stack.pop_n([1, 2, 3], 2)
      {[1, 2], [3]}

      iex> TinyEVM.Stack.pop_n([1, 2, 3], 4)
      {[1, 2, 3], []}
  """
  @spec pop_n(t(), integer()) :: {[val()], t()}
  def pop_n([], _), do: {[], []}
  def pop_n(stack, 0), do: {[], stack}

  def pop_n([val | stack], n) do
    {values, rest} = pop_n(stack, n - 1)
    {[val | values], rest}
  end

  @doc """
  Returns the length of the stack.

  ## Examples

      iex> TinyEVM.Stack.length([])
      0

      iex> TinyEVM.Stack.length([1, 2, 3])
      3
  """
  @spec length(t) :: integer()
  def length(stack), do: Kernel.length(stack)

  @doc """
  Serializes the given `stack` to
  an array of hex-encoded values.
  """
  @spec serialize(t()) :: [String.t()]
  def serialize(stack) do
    Enum.map(stack, &Hex.from_int/1)
  end

  @doc """
  Returns the maximum stack size.
  """
  @spec max_size() :: integer()
  def max_size(), do: @max_size
end
