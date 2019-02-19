defmodule TinyEVM.Gas do
  @moduledoc """
  Module responsible for calculating the gas price.
  """

  alias TinyEVM.Instruction

  @groups %{
    zero: [:stop],
    base: [:pop],
    verylow: [:add, :sub, :mload, :mstore],
    low: [
      :mul,
      :div,
      # :sdiv,
      :mod
      # :smod,
      # :signextend
    ],
    mid: [:addmod, :mulmod]
  }

  # Nothing paid for operations of the set W_zero.
  @g_zero 0
  # Amount of gas to pay for operations of the set W_base.
  @g_base 2
  # Amount of gas to pay for operations of the set W_verylow.
  @g_verylow 3
  # Amount of gas to pay for operations of the set W_low.
  @g_low 5
  # Amount of gas to pay for operations of the set W_mid.
  @g_mid 8

  @doc """
  Returns the cost for the given instruction `symbol`.
  This is defined in Appendix H of the Yellow Paper, Eq.(294) and is denoted `C`.

  ## Examples

      iex> TinyEVM.Gas.cost(TinyEVM.Instruction.new(:pop, [1]))
      2

      iex> TinyEVM.Gas.cost(TinyEVM.Instruction.new(:sstore, [0, 1]))
      20_000

      iex> TinyEVM.Gas.cost(TinyEVM.Instruction.new(:sstore, [1, 0]))
      5_000
  """
  def cost(%Instruction{symbol: symbol, args: args}), do: cost(symbol, args)

  @spec cost(atom(), [integer()]) :: integer()
  defp cost(:sload, _args), do: 50
  defp cost(:sstore, [_key, 0]), do: 5_000
  defp cost(:sstore, [_key, _]), do: 20_000

  # NOTE: We don't estimate the real cost of :mstore for simplicity.
  # In our implementation it always costs 3 gas.

  defp cost(symbol, _args) do
    cond do
      Instruction.push?(symbol) -> @g_verylow
      symbol in @groups[:zero] -> @g_zero
      symbol in @groups[:base] -> @g_base
      symbol in @groups[:verylow] -> @g_verylow
      symbol in @groups[:low] -> @g_low
      symbol in @groups[:mid] -> @g_mid
      true -> Instruction.invalid!(symbol)
    end
  end
end
