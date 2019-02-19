defmodule TinyEVM.Binary do
  @moduledoc """
  This module defines functions for working with binary data.
  """

  alias TinyEVM.Config

  @doc """
  Reads a given number of `bytes` out of `bin` starting from the given `offset`.
  The `bin` could be a potentially "infinite" binary data.

  ## Examples

      iex> TinyEVM.Binary.read(<<>>, 10, 32)
      <<0::256>>

      iex> TinyEVM.Binary.read(<<1::256>>, 0, 0)
      <<>>

      iex> TinyEVM.Binary.read(<<1::256>>, 0, 30)
      <<0::240>>

      iex> TinyEVM.Binary.read(<<1::256>>, 0, 35)
      <<1::256, 0::24>>

      iex> TinyEVM.Binary.read(<<1::256, 2::256, 3::256>>, 32, 35)
      <<2::256, 0::24>>

      iex> TinyEVM.Binary.read(<<1::256, 2::256>>, 0, 32)
      <<1::256>>

      iex> TinyEVM.Binary.read(<<1::256, 2::256>>, 32, 32)
      <<2::256>>

      iex> TinyEVM.Binary.read(<<1::256, 2::256>>, 64, 32)
      <<0::256>>
  """
  @spec read(binary(), integer(), integer()) :: binary()
  def read(<<>>, _offset, bytes), do: zeros(bytes)
  def read(bin, offset, bytes) when offset > byte_size(bin), do: zeros(bytes)

  def read(bin, offset, bytes) do
    abs_pos = offset + bytes
    mem_pos = min(abs_pos, byte_size(bin))
    padding = (abs_pos - mem_pos) * Config.byte_size()
    chunk = :binary.part(bin, offset, mem_pos - offset)
    chunk <> <<0::size(padding)>>
  end

  @doc """
  Writes `data` to `bin` at the given `offset`.
  The `bin` could be a potentially "infinite" binary data.

  ## Examples

      iex> TinyEVM.Binary.write(<<1, 2>>, 4, <<3, 4>>)
      <<1, 2, 0, 0, 3, 4>>

      iex> TinyEVM.Binary.write(<<1, 2, 3, 4>>, 2, <<5, 6>>)
      <<1, 2, 5, 6>>

      iex> TinyEVM.Binary.write(<<1, 2, 3, 4>>, 1, <<5>>)
      <<1, 5, 3, 4>>

      iex> TinyEVM.Binary.write(<<>>, 0, 1)
      <<0::248, 1>>

      iex> TinyEVM.Binary.write(<<>>, 10, 100)
      <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0::248, 100>>
  """
  @spec write(binary(), integer(), binary() | integer()) :: binary()
  def write(bin, offset, data) when is_integer(data),
    do: write(bin, offset, pad_left(data))

  def write(bin, offset, data) do
    {bin, remaining} = fit(bin, offset, data)
    head = :binary.part(bin, 0, offset)
    tail = :binary.part(bin, offset + byte_size(data), remaining)
    head <> data <> tail
  end

  @spec fit(binary(), integer(), binary()) :: {binary(), integer()}
  defp fit(bin, offset, data) do
    needed = offset + byte_size(data)
    remaining = max(byte_size(bin) - needed, 0)
    result = pad_right(bin, needed)
    {result, remaining}
  end

  @doc """
  Left pad binary with bytes.

  ## Examples

      iex> TinyEVM.Binary.pad_left(1, 3)
      <<0, 0, 1>>
      iex> TinyEVM.Binary.pad_left(<<1>>, 3)
      <<0, 0, 1>>
      iex> TinyEVM.Binary.pad_left(<<1, 2, 3>>, 2)
      <<1, 2, 3>>
  """
  @spec pad_left(binary() | integer(), integer()) :: binary()
  def pad_left(n, size \\ Config.word_size(:bytes))
  def pad_left(n, size) when is_integer(n), do: pad_left(:binary.encode_unsigned(n), size)
  def pad_left(n, size) when size < byte_size(n), do: n
  def pad_left(n, size), do: zeros(size - byte_size(n)) <> n

  @doc """
  Right pad binary with bytes.

  ## Examples

      iex> TinyEVM.Binary.pad_right(1, 3)
      <<1, 0, 0>>
      iex> TinyEVM.Binary.pad_right(<<1>>, 3)
      <<1, 0, 0>>
      iex> TinyEVM.Binary.pad_right(<<1, 2, 3>>, 2)
      <<1, 2, 3>>
  """
  @spec pad_right(binary() | integer(), integer()) :: binary()
  def pad_right(n, size \\ Config.word_size(:bytes))
  def pad_right(n, size) when is_integer(n), do: pad_right(:binary.encode_unsigned(n), size)
  def pad_right(n, size) when size < byte_size(n), do: n
  def pad_right(n, size), do: n <> zeros(size - byte_size(n))

  @doc """
  Given a desired size in `bytes`
  generates a binary filled with zeros.
  """
  @spec zeros(integer()) :: binary()
  def zeros(bytes) do
    size = bytes * Config.byte_size()
    <<0::size(size)>>
  end
end
