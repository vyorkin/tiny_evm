defmodule TinyEVM.Memory do
  @moduledoc """
  This module defines functions to work with TinyEVM memory.
  """

  alias TinyEVM.{Config, Hex, Binary}

  @type t :: binary()

  @doc """
  Reads a word out of `memory` from the given `offset`.
  """
  @spec read(t(), integer()) :: binary()
  def read(memory, offset, bytes \\ Config.word_size(:bytes)),
    do: Binary.read(memory, offset, bytes)

  @doc """
  Writes `data` to `memory` at the given `offset`.
  """
  @spec write(t(), integer(), binary() | integer()) :: t()
  def write(memory, offset, data), do: Binary.write(memory, offset, data)

  @doc """
  Serializes memory contents to a hex string.
  """
  @spec serialize(t()) :: String.t()
  def serialize(memory), do: Hex.from_bin(memory)
end
