defmodule TinyEVM.StackTest do
  use ExUnit.Case

  doctest TinyEVM.Stack

  alias TinyEVM.Stack

  describe "push/2" do
    test "throws an exception on stack overfow" do
      assert_raise Stack.Overflow, fn ->
        stack = Enum.into(1..1025, [])
        Stack.push(stack, 1)
      end
    end
  end
end
