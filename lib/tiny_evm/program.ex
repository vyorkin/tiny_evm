defmodule TinyEVM.Program do
  @moduledoc """
  Represents a TinyEVM program.
  Basically, this is the code, initial gas and a storage.
  """

  alias TinyEVM.{Hex, Disassembler, Instruction, Storage}

  @type t :: %__MODULE__{
          code: [Instruction.expr()],
          gas: integer(),
          storage: map()
        }

  @enforce_keys [:code, :gas]
  defstruct code: [], gas: 0, storage: %{}

  @doc """
  Given a map with a raw input program specification,
  decodes it into an `TinyEVM.Program` struct.
  """
  @spec new(map()) :: t()
  def new(raw) do
    code =
      raw["code"]
      |> Hex.to_bin()
      |> Disassembler.run()

    gas = Hex.to_int(raw["gas"])
    storage = Storage.deserialize(raw["storage"])

    %__MODULE__{code: code, gas: gas, storage: storage}
  end
end
