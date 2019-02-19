defmodule TinyEVMTest.Helpers.Harness do
  @moduledoc """
  Harness for running tests for our toy Ethereum VM.
  """

  defmacro __using__(_opts) do
    quote do
      import TinyEVMTest.Helpers.Harness, only: [define_test_set: 1]
    end
  end

  defmacro define_test_set(fun) do
    test_set = TinyEVMTest.Helpers.TestSet.read()

    for {name, data} <- test_set do
      json = Poison.encode!(data)

      quote do
        @tag :evm
        test "#{unquote(name)}" do
          data = Poison.decode!(unquote(json))

          unquote(fun).(
            data["input"],
            data["output"]
          )
        end
      end
    end
  end
end
