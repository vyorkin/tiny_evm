defmodule TinyEVM.Storage do
  @moduledoc """
  Represents a TinyEVM storage.

  In the real EVM we have a storage per contract account.
  But for our TinyEVM (to keep things simple) we'll have a
  storage per program, which is just an abstraction over `Map`.

  """

  alias TinyEVM.Hex

  @type t :: map()

  @doc """
  Gets value from the given `storage`.
  """
  @spec get(t(), integer()) :: integer() | nil
  def get(storage, key), do: Map.fetch!(storage, key)

  @doc """
  Puts value into the `storage` under the given `key`.
  """
  @spec put(t(), integer(), integer()) :: t()
  def put(storage, key, 0), do: Map.delete(storage, key)
  def put(storage, key, value), do: Map.put(storage, key, value)

  @doc """
  Deserializes storage from the given `raw` input map.
  """
  @spec deserialize(map()) :: t()
  def deserialize(raw) do
    raw
    |> Enum.map(&deserialize_item/1)
    |> Enum.into(%{})
  end

  @doc """
  Serializes the given `storage` to a map.
  """
  @spec serialize(t()) :: map()
  def serialize(storage) do
    storage
    |> Enum.map(&serialize_item/1)
    |> Enum.into(%{})
  end

  defp serialize_item({k, v}) do
    {
      Hex.from_int(k),
      Hex.from_int(v)
    }
  end

  defp deserialize_item({k, v}) do
    {
      Hex.to_int(k),
      Hex.to_int(v)
    }
  end
end
