defmodule TinyEVMTest.Helpers.TestSet do
  @file_path "./test/support/tests.json"

  def read() do
    @file_path
    |> File.open!()
    |> IO.read(:all)
    |> Poison.decode!()
  end
end
