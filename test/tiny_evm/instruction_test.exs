defmodule TinyEVM.InstructionTest do
  use ExUnit.Case

  doctest TinyEVM.Instruction

  alias TinyEVM.Instruction

  describe "decode/3" do
    test "decodes valid opcode" do
      # [:push2, 5, 2, :push1, 4, :add]
      assembly = Instruction.decode(97, <<5, 2, 96, 4, 1>>, true)
      expected = {[2, 5, :push2], <<96, 4, 1>>}

      assert assembly == expected
    end

    test "decodes invalid opcode (non-strict mode)" do
      assembly = Instruction.decode(0x99, <<1, 2>>, false)
      expected = {[{:invalid, 0x99}], <<1, 2>>}

      assert assembly == expected
    end

    test "throws an exception on invalid opcode (strict mode)" do
      assert_raise Instruction.Invalid, fn ->
        Instruction.decode(0x99, <<1, 2>>, true)
      end
    end
  end
end
