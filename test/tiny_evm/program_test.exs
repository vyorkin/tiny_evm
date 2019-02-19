defmodule TinyEVM.ProgramTest do
  use ExUnit.Case

  doctest TinyEVM.Program

  alias TinyEVM.Program

  describe "decode/1" do
    test "decodes a program" do
      map = %{
        "code" => "0x6005600401",
        "gas" => "0x0186a0",
        "storage" => %{}
      }

      expected = %Program{
        code: [:push1, 5, :push1, 4, :add],
        gas: 100_000,
        storage: %{}
      }

      assert Program.new(map) == expected
    end
  end
end
