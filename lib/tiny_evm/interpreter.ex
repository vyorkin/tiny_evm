defmodule TinyEVM.Interpreter do
  @moduledoc """
  Module for instruction execution.
  """

  alias TinyEVM.{State, Instruction, Stack, Memory, Storage}

  @doc """
  Executes a single instruction, returning the new state.
  """
  @spec execute(Instruction.t(), State.t()) :: State.t()
  def execute(%Instruction{symbol: symbol, args: args}, state) do
    if Instruction.push?(symbol) do
      exec_push(args, state)
    else
      exec(symbol, args, state)
    end
  end

  @spec exec_push([integer()], State.t()) :: State.t()
  defp exec_push(args, state) do
    value =
      args
      |> :binary.list_to_bin()
      |> :binary.decode_unsigned()

    %{state | stack: Stack.push(state.stack, value)}
  end

  @spec exec(atom(), [integer()], State.t()) :: State.t()
  defp exec(:pop, [_], state), do: state

  defp exec(:mload, [offset], state) do
    value =
      state.memory
      |> Memory.read(offset)
      |> :binary.decode_unsigned()

    %{state | stack: Stack.push(state.stack, value)}
  end

  defp exec(:mstore, [offset, value], state) do
    memory = Memory.write(state.memory, offset, value)
    %{state | memory: memory}
  end

  defp exec(:sload, [key], state) do
    value = Storage.get(state.storage, key)
    %{state | stack: Stack.push(state.stack, value)}
  end

  defp exec(:sstore, [key, value], state) do
    storage = Storage.put(state.storage, key, value)
    %{state | storage: storage}
  end

  defp exec(symbol, args, state) do
    output = exec_pure(symbol, args)
    %{state | stack: Stack.push(state.stack, output)}
  end

  defp exec_pure(:add, [x, y]), do: x + y
  defp exec_pure(:mul, [x, y]), do: x * y
  defp exec_pure(:sub, [x, y]), do: x - y

  defp exec_pure(:div, [_, 0]), do: 0
  defp exec_pure(:div, [x, y]), do: Integer.floor_div(x, y)

  defp exec_pure(:addmod, [_, _, 0]), do: 0
  defp exec_pure(:addmod, [x, y, z]), do: rem(x + y, z)

  defp exec_pure(:mulmod, [_, _, 0]), do: 0
  defp exec_pure(:mulmod, [x, y, z]), do: rem(x * y, z)

  defp exec_pure(:mod, [_, 0]), do: 0
  defp exec_pure(:mod, [x, y]), do: rem(x, y)
end
