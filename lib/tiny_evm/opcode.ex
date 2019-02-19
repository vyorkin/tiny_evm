defmodule TinyEVM.Opcode do
  @moduledoc """
  This module contains functions for encoding/decoding TinyEVM opcodes.
  """

  alias TinyEVM.Helpers

  @type t :: integer()

  @base_opcodes %{
    0x00 => :stop,
    0x01 => :add,
    0x02 => :mul,
    0x03 => :sub,
    0x04 => :div,
    # 0x05 => :sdiv,
    0x06 => :mod,
    # 0x07 => :smod,
    0x08 => :addmod,
    0x09 => :mulmod,
    # 0x0b => :signextend,
    0x50 => :pop,
    0x51 => :mload,
    0x52 => :mstore,
    0x54 => :sload,
    0x55 => :sstore
  }

  @push_opcodes 1..32
                |> Enum.map(fn n -> {0x5F + n, :"push#{n}"} end)
                |> Enum.into(%{})

  @opcodes Map.merge(@base_opcodes, @push_opcodes)
  @instructions Helpers.invert(@opcodes)

  @push1 Map.get(@instructions, :push1)
  @push32 Map.get(@instructions, :push32)

  defguard is_push(x) when x in @push1..@push32

  @doc """
  Decodes instruction by the given `opcode`.

  ## Examples

      iex> TinyEVM.Opcode.decode(0x60)
      {:ok, :push1}

      iex> TinyEVM.Opcode.decode(0x99)
      :error
  """
  @spec decode(t()) :: {:ok, atom()} | :error
  def decode(opcode), do: Map.fetch(@opcodes, opcode)

  @doc """
  Returns the opcode for the given instruction `symbol`.

  ## Examples

      iex> TinyEVM.Opcode.encode(:push1)
      0x60
  """
  @spec encode(atom()) :: t()
  def encode(symbol), do: Map.fetch!(@instructions, symbol)

  @doc """
  Returns the `opcode` arity.

  ## Examples
      iex> TinyEVM.Opcode.arity(0x60)
      1

      iex> TinyEVM.Opcode.arity(0x65)
      6

      iex> TinyEVM.Opcode.arity(0x99)
      0
  """
  @spec arity(t()) :: integer()
  def arity(opcode) when is_push(opcode), do: opcode - @push1 + 1
  def arity(_), do: 0
end
