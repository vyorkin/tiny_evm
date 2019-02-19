defmodule TinyEVM.Config do
  @moduledoc """
  This module contains global TinyEVM configuration.
  """

  @word_size_in_bytes 32
  @byte_size 8

  @doc """
  Returns word size in bits.
  """
  @spec word_size(atom()) :: integer()
  def word_size(:bits), do: @word_size_in_bytes * @byte_size
  def word_size(:bytes), do: @word_size_in_bytes

  @doc """
  Returns TinyEVM byte size.
  """
  @spec byte_size() :: integer()
  def byte_size(), do: @byte_size
end
