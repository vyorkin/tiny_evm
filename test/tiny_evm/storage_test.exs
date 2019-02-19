defmodule TinyEVM.StorageTest do
  use ExUnit.Case

  doctest TinyEVM.Storage

  alias TinyEVM.Storage

  describe "serialize/1" do
    test "serializes and deserializes storage" do
      storage = %{
        11 => 23,
        32 => 42
      }

      roundtrip =
        storage
        |> Storage.serialize()
        |> Storage.deserialize()

      assert roundtrip == storage
    end
  end
end
