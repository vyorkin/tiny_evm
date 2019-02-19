defmodule TinyEVM.Hex do
  @moduledoc """
  Hex encoding/decoding functions.
  """

  @doc """
  Converts a hex string to a binary.

  ## Examples

      iex> TinyEVM.Hex.to_bin("01020a0d")
      <<0x01, 0x02, 0x0a, 0x0d>>

      iex> TinyEVM.Hex.to_bin("01020a0D")
      <<0x01, 0x02, 0x0a, 0x0d>>

      iex> TinyEVM.Hex.to_bin("0x01020a0d")
      <<0x01, 0x02, 0x0a, 0x0d>>

      iex> TinyEVM.Hex.to_bin("0x01020A0d")
      <<0x01, 0x02, 0x0a, 0x0d>>
  """
  @spec to_bin(String.t()) :: binary()
  def to_bin("0x" <> hex), do: to_bin(hex)

  def to_bin(hex), do: Base.decode16!(hex, case: :mixed)

  @doc """
  Converts a hex string to an integer.

  ## Examples
      iex> TinyEVM.Hex.to_int("01020a0d")
      16910861

      iex> TinyEVM.Hex.to_int("01020a0D")
      16910861

      iex> TinyEVM.Hex.to_int("0x01020a0d")
      16910861

      iex> TinyEVM.Hex.to_int("0x01020A0d")
      16910861
  """
  @spec to_int(String.t()) :: integer()
  def to_int(hex) do
    hex
    |> to_bin()
    |> :binary.decode_unsigned()
  end

  @doc """
  Converts a binary to a hex string.

  ## Examples

      iex> TinyEVM.Hex.from_bin(<<0x01, 0x02, 0x0a, 0x0d>>)
      "0x01020a0d"
  """
  @spec from_bin(binary()) :: String.t()
  def from_bin(bin), do: "0x" <> Base.encode16(bin, case: :lower)

  @doc """
  Converts an integer to a hex string.
  ## Examples

      iex> TinyEVM.Hex.from_int(0)
      "0x00"

      iex> TinyEVM.Hex.from_int(16910861)
      "0x01020a0d"

      iex> TinyEVM.Hex.from_int(100000)
      "0x0186a0"
  """
  @spec from_int(integer()) :: String.t()
  def from_int(n) do
    encoded =
      n
      |> :binary.encode_unsigned()
      |> Base.encode16(case: :lower)

    "0x" <> encoded
  end
end
