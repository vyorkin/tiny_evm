defmodule TinyEVM.InterpreterTest do
  use ExUnit.Case

  doctest TinyEVM.Interpreter

  alias TinyEVM.{State, Instruction, Memory, Storage, Interpreter}

  setup do
    state = %State{code: [], gas: 0}
    {:ok, %{state: state}}
  end

  describe "execute/2" do
    test "push1", %{state: state} do
      push1 = Instruction.new(:push1, [1])
      assert Interpreter.execute(push1, state) == %{state | stack: [1]}
    end

    test "push2..32", %{state: state} do
      for n <- 2..32 do
        symbol = :"push#{n}"
        args = Enum.into(1..n, [])
        push = Instruction.new(symbol, args)

        expected_value =
          args
          |> :binary.list_to_bin()
          |> :binary.decode_unsigned()

        expected = %{state | stack: [expected_value]}

        assert Interpreter.execute(push, state) == expected
      end
    end

    test "pop", %{state: state} do
      pop = Instruction.new(:pop, [1])
      assert Interpreter.execute(pop, state) == %{state | stack: []}
    end

    test "add", %{state: state} do
      add = Instruction.new(:add, [2, 3])
      assert Interpreter.execute(add, state) == %{state | stack: [5]}
    end

    test "mul", %{state: state} do
      mul = Instruction.new(:mul, [3, 4])
      assert Interpreter.execute(mul, state) == %{state | stack: [12]}
    end

    test "sub", %{state: state} do
      sub = Instruction.new(:sub, [42, 40])
      assert Interpreter.execute(sub, state) == %{state | stack: [2]}
    end

    test "div by zero", %{state: state} do
      div = Instruction.new(:div, [42, 0])
      assert Interpreter.execute(div, state) == %{state | stack: [0]}
    end

    test "div by non-zero", %{state: state} do
      div = Instruction.new(:div, [42, 2])
      assert Interpreter.execute(div, state) == %{state | stack: [21]}
    end

    test "mload", %{state: state} do
      memory =
        state.memory
        |> Memory.write(0, <<0::248, 1>>)
        |> Memory.write(32, <<0::248, 42>>)
        |> Memory.write(64, <<0::248, 88>>)

      state = %{state | memory: memory}

      mload0 = Instruction.new(:mload, [0])
      mload32 = Instruction.new(:mload, [32])
      mload64 = Instruction.new(:mload, [64])

      assert Interpreter.execute(mload0, state) == %{state | stack: [1]}
      assert Interpreter.execute(mload32, state) == %{state | stack: [42]}
      assert Interpreter.execute(mload64, state) == %{state | stack: [88]}
    end

    test "mstore", %{state: state} do
      mstore42 = Instruction.new(:mstore, [32, 42])
      expected = %{state | memory: Memory.write(state.memory, 32, 42)}
      assert Interpreter.execute(mstore42, state) == expected
    end

    test "sload", %{state: state} do
      state = %{state | storage: Storage.put(state.storage, 12, 42)}
      sload12 = Instruction.new(:sload, [12])
      expected = %{state | stack: [42]}

      assert Interpreter.execute(sload12, state) == expected
    end

    test "sstore", %{state: state} do
      sstore42 = Instruction.new(:sstore, [12, 42])
      expected = %{state | storage: %{12 => 42}}

      assert Interpreter.execute(sstore42, state) == expected
    end
  end
end
