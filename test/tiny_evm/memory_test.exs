defmodule TinyEVM.MemoryTest do
  use ExUnit.Case

  doctest TinyEVM.Memory

  alias TinyEVM.Memory

  test "memory I/O" do
    memory = <<>>
    |> Memory.write(0, 2)
    |> Memory.write(36, 40)
    |> Memory.write(400, 500)

    assert memory |> Memory.read(0) |> :binary.decode_unsigned() == 2
    assert memory |> Memory.read(36) |> :binary.decode_unsigned() == 40
    assert memory |> Memory.read(400) |> :binary.decode_unsigned() == 500
  end
end
