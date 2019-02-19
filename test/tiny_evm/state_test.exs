defmodule TinyEVM.StateTest do
  use ExUnit.Case

  doctest TinyEVM.State

  alias TinyEVM.{State, Instruction}

  describe "read_instruction/1" do
    test "returns :stop when out of bounds" do
      code = [:push2, 1, 2]
      state = %State{code: code, pc: length(code), gas: 0}
      expected_instr = Instruction.new(:stop)
      expected = {expected_instr, state}

      assert State.read_instruction(state) == expected
    end

    test "returns :mul with no operands" do
      code = [:push1, 1, :push1, 2, :mul]
      state = %State{code: code, pc: 4, gas: 0, stack: [1, 2]}

      expected_instr = Instruction.new(:mul, [1, 2])
      expected_state = %{state | stack: [], pc: 5}
      expected = {expected_instr, expected_state}

      assert State.read_instruction(state) == expected
    end

    test "returns :push1 with a single operand" do
      code = [:push1, 1, :push1, 2, :add]
      state = %State{code: code, pc: 0, gas: 0}
      expected_instr = Instruction.new(:push1, [1])
      expected_state = %{state | pc: 2}
      expected = {expected_instr, expected_state}

      assert State.read_instruction(state) == expected
    end

    test "returns :push5 with 5 operands" do
      code = [:push5, 1, 2, 3, 4, 5]
      state = %State{code: code, pc: 0, gas: 0}
      expected_instr = Instruction.new(:push5, [1, 2, 3, 4, 5])
      expected_state = %{state | pc: 6}
      expected = {expected_instr, expected_state}

      assert State.read_instruction(state) == expected
    end
  end

  describe "check/1" do
    test "invalid instruction" do
      code = [:push1, 1, {:invalid, 0x99}]
      state = %State{code: code, pc: 2, gas: 0}

      assert State.check(state) == {:error, :invalid_instruction}
    end

    test "stack underflow" do
      code = [:push2, 1, 2, :add, :push1, 1]
      state = %State{code: code, pc: 3, gas: 0, stack: [1]}

      assert State.check(state) == {:error, :stack_underflow}
    end

    test "stack overflow" do
      code = [:mload, :add, 1, 2, 3]
      # in our TinyEVM we don't have instructions
      # that place more than a one value to a stack,
      # thats why we have to starts with initially overflowed stack here
      stack = Enum.into(1..1026, [])
      state = %State{code: code, pc: 1, gas: 0, stack: stack}

      assert State.check(state) == {:error, :stack_overflow}
    end
  end

  describe "serialize/1" do
    test "serializes state to a map" do
      state = %State{
        code: [:push1, 5, :push1, 4, :add],
        pc: 4,
        gas: 665,
        stack: [4, 5],
        memory: <<>>,
        storage: %{
          0 => 10
        }
      }

      expected = %{
        "pc" => "0x04",
        "gas" => "0x0299",
        "stack" => [
          "0x04",
          "0x05"
        ],
        "memory" => "0x",
        "storage" => %{
          "0x00" => "0x0a"
        }
      }

      assert State.serialize(state) == expected
    end
  end
end
