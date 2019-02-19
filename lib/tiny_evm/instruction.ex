defmodule TinyEVM.Instruction do
  @moduledoc """
  Module for decoding the TinyEVM instructions.
  """

  defmodule Invalid do
    @moduledoc """
    Exception that is raised when we encounter unknown/invalid instruction.
    For our TinyEVM we pick only a subset of very simple instructions.
    """
    defexception [:message]
  end

  import TinyEVM.Opcode, only: [is_push: 1]
  alias TinyEVM.{Opcode, Config}

  @type t :: %__MODULE__{
          symbol: atom(),
          args: [integer()],
          inputs: integer(),
          outputs: integer()
        }

  @type metadata :: {integer(), integer()}
  @type invalid :: {:invalid, Opcode.t()}
  @type expr :: atom() | integer() | invalid()
  @type decoded :: {[expr()], binary()}

  @metadata %{
    :stop => {0, 0},
    :add => {2, 1},
    :mul => {2, 1},
    :sub => {2, 1},
    :div => {2, 1},
    # :sdiv => {2, 1},
    :mod => {2, 1},
    # :smod => {2, 1},
    :addmod => {3, 1},
    :mulmod => {3, 1},
    # :signextend => {2, 1},
    :pop => {1, 0},
    :mload => {1, 1},
    :mstore => {2, 0},
    :sload => {1, 1},
    :sstore => {2, 0}
  }

  @enforce_keys [:symbol]
  defstruct symbol: :stop, args: [], inputs: 0, outputs: 0

  @doc """
  Given instruction `symbol` and `args` creates
  a new `TinyEVM.Instruction` struct.
  """
  @spec new(atom(), [integer()]) :: t()
  def new(symbol, args \\ []) do
    {inputs, outputs} = metadata(symbol)
    %__MODULE__{
      symbol: symbol,
      args: args,
      inputs: inputs,
      outputs: outputs
    }
  end

  @doc """
  Returns a metadata for the given instruction `symbol`.

  ## Examples

      iex> TinyEVM.Instruction.metadata(:add)
      {2, 1}

      iex> TinyEVM.Instruction.metadata(:pop)
      {1, 0}

      iex> TinyEVM.Instruction.metadata(:push1)
      {0, 1}

      iex> TinyEVM.Instruction.metadata(:push15)
      {0, 1}
  """
  @spec metadata(expr()) :: metadata()
  def metadata(symbol), do: metadata(symbol, push?(symbol))

  defp metadata(_, true), do: {0, 1}
  defp metadata(symbol, false), do: Map.fetch!(@metadata, symbol)

  @doc """
  Returns the arity (number of operands after instruction) for the given `symbol`.
  Arity make sense only for `pushN` instructions.

  ## Examples
      iex> TinyEVM.Instruction.arity(:push1)
      1

      iex> TinyEVM.Instruction.arity(:push6)
      6

      iex> TinyEVM.Instruction.arity(:mload)
      0
  """
  @spec arity(atom()) :: integer()
  def arity(symbol), do: symbol |> Opcode.encode() |> Opcode.arity()

  @doc """
  Returns `true` if the given instruction is
  one of the push1..push32.

  ## Examples

      iex> TinyEVM.Instruction.push?(:push12)
      true

      iex> TinyEVM.Instruction.push?(:mstore)
      false
  """
  @spec push?(atom()) :: boolean()
  def push?(symbol), do: symbol |> Opcode.encode() |> is_push()

  @doc """
  Decodes TinyEVM instruction and its arguments.
  """
  @spec decode(byte(), binary(), boolean()) :: decoded()
  def decode(opcode, bytecode, strict) do
    case Opcode.decode(opcode) do
      {:ok, symbol} ->
        arity = Opcode.arity(opcode)
        decode_valid({symbol, arity}, bytecode)

      :error ->
        decode_invalid(opcode, bytecode, strict)
    end
  end

  @spec decode_valid({atom(), integer()}, binary()) :: decoded()
  defp decode_valid({symbol, 0}, bytecode), do: {[symbol], bytecode}

  defp decode_valid({symbol, arity}, bytecode) do
    {operand_bytes, rest} = decode_operands(bytecode, arity)
    operands = :binary.bin_to_list(operand_bytes)
    {Enum.reverse([symbol | operands]), rest}
  end

  @spec decode_operands(binary(), integer()) :: {binary(), binary()}
  defp decode_operands(bytecode, arity) when arity > byte_size(bytecode) do
    missing = arity - byte_size(bytecode)
    padding = missing * Config.byte_size()
    argdata = bytecode <> <<0::size(padding)>>
    {argdata, <<>>}
  end

  defp decode_operands(bytecode, arity) do
    <<argdata::binary-size(arity), rest::binary()>> = bytecode
    {argdata, rest}
  end

  @spec decode_invalid(integer(), binary(), boolean()) :: decoded() | no_return()
  defp decode_invalid(opcode, _, true), do: invalid!(opcode)

  defp decode_invalid(opcode, bytecode, false) do
    {[invalid(opcode)], bytecode}
  end

  @doc """
  Returns a tuple that represents an invalid instruction.
  """
  @spec invalid(Opcode.t()) :: invalid()
  def invalid(opcode), do: {:invalid, opcode}

  @doc """
  Returns `true` if the given instruction expression is valid.
  """
  @spec valid?(expr()) :: boolean()
  def valid?({:invalid, _}), do: false
  def valid?(_symbol), do: true

  @doc """
  Raises the `TinyEVM.Instruction.Invalid` exception.
  """
  @spec invalid!(expr()) :: no_return()
  def invalid!(expr), do: raise(Invalid, "Invalid instruction: #{expr}")
end
