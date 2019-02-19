defmodule TinyEVMTest do
  use ExUnit.Case
  use TinyEVMTest.Helpers.Harness

  doctest TinyEVM

  alias TinyEVM.{State, Memory, Storage}

  define_test_set(&run_ethereum_test/2)

  defp run_ethereum_test(input, output) do
    assert TinyEVM.run(input) == output
  end

  describe "execute/1" do
    test "executes a trivial program" do
      code = [:push1, 1, :push1, 2, :add]
      state = %State{code: code, pc: 0, gas: 10}
      expected = %{state | pc: length(code), gas: 1, stack: [3]}

      assert TinyEVM.execute(state) == expected
    end

    test "executes a simple arithmetic program" do
      # :binary.encode_unsigned(<<1, 1>>) = 257
      # :binary.encode_unsigned(<<3, 2>>) = 770
      # :binary.encode_unsigned(<<1, 2, 1, 3>>) = 16908547
      # :binary.encode_unsigned(<<3, 9>>) = 777

      code = [
        :push2,
        3,
        2,
        # [770]
        :push1,
        10,
        # [10, 770]
        :push2,
        1,
        1,
        # [257, 10, 770]
        :push1,
        2,
        # [2, 257, 10, 770]
        :mul,
        # [514, 10, 770]
        :sub,
        # [504, 770]
        :push1,
        5,
        # [5, 504, 770]
        :mul,
        # [2520, 770]
        :div,
        # [3]
        :push4,
        1,
        2,
        1,
        3,
        # [16908547, 3]
        :mod,
        # [1]
        :push2,
        3,
        9,
        # [777, 1]
        :pop
        # [1]
      ]

      state = %State{code: code, pc: 0, gas: 100}
      expected = %{state | pc: length(code), gas: 54, stack: [1]}

      assert TinyEVM.execute(state) == expected
    end

    test "executes a program that performs memory I/O" do
      code = [
        :push1,
        42,
        :push1,
        32,
        :mstore,
        :push1,
        2,
        :push1,
        3,
        :push1,
        32,
        # [12, 3, 2]
        :mload,
        # [42, 3, 2]
        :mul,
        # [84, 2]
        :add
        # [86]
      ]

      state = %State{code: code, pc: 0, gas: 100}
      expected = %{
        state |
        pc: length(code),
        gas: 71,
        stack: [128],
        memory: Memory.write(state.memory, 32, 42)
      }

      assert TinyEVM.execute(state) == expected
    end

    test "executes a program that modifies storage" do
      code = [:push1, 0, :push1, 1, :push1, 4, :addmod, :push1, 0, :sstore]
      state = %State{code: code, pc: 0, gas: 100000}
      expected = %{
        state |
        gas: 94980,
        pc: length(code),
        storage: %{}
      }

      assert TinyEVM.execute(state) == expected
    end

    test "executes a complex program" do
      code = [:push1, 23, :push1, 0, :mstore, :push1, 0, :mload, :push1, 1, :sstore]
      state = %State{code: code, pc: 0, gas: 100000}
      expected = %{
        state |
        gas: 79982,
        pc: length(code),
        memory: Memory.write(state.memory, 0, 23),
        storage: Storage.put(state.storage, 1, 23),
      }

      assert TinyEVM.execute(state) == expected
    end
  end
end
