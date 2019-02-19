defmodule TinyEVM.State do
  @moduledoc """
  Responsible for tracking TinyEVM state.

  This is equivalent to the µ in the Yellow Paper.
  """

  alias TinyEVM.{
    Program,
    Stack,
    Memory,
    Storage,
    Hex,
    Instruction
  }

  @type t :: %__MODULE__{
          code: [Instruction.expr()],
          pc: integer(),
          gas: integer(),
          stack: Stack.t(),
          memory: Memory.t(),
          storage: Storage.t()
        }

  @enforce_keys [:code, :gas]
  defstruct code: [],
            gas: 0,
            pc: 0,
            stack: [],
            memory: <<>>,
            storage: %{}

  alias TinyEVM.State

  @doc """
  Initializes an EVM state from the given `program`.

  ## Examples

      iex> program = %TinyEVM.Program{code: [:stop], gas: 100}
      iex> TinyEVM.State.new(program)
      %TinyEVM.State{
        code: [:stop],
        gas: 100,
        pc: 0,
        stack: [],
        memory: <<>>,
        storage: %{}
      }
  """
  @spec new(Program.t()) :: t()
  def new(program) do
    %__MODULE__{
      code: program.code,
      gas: program.gas,
      storage: program.storage
    }
  end

  @doc """
  Reads the current instruction, updates stack and program counter.
  Defined as `w`, Eq.(136) of the Yellow Paper.
  """
  @spec read_instruction(State.t()) :: {Instruction.t(), State.t()}
  def read_instruction(state = %State{code: code, pc: pc})
      when pc >= length(code),
      do: {Instruction.new(:stop), state}

  def read_instruction(state) do
    symbol = instruction(state)

    arity = Instruction.arity(symbol)

    operands =
      state.code
      |> Enum.drop(state.pc + 1)
      |> Enum.take(arity)

    {inputs, outputs} = Instruction.metadata(symbol)
    {args, stack} = Stack.pop_n(state.stack, inputs)

    pc = state.pc + arity + 1
    state = %{state | pc: pc, stack: stack}

    instruction = %Instruction{
      symbol: symbol,
      args: operands ++ args,
      inputs: inputs,
      outputs: outputs
    }

    {instruction, state}
  end

  @doc """
  Determines whether the given `state` is "exceptional halting".
  This is defined as `Z` in Eq.(137) of the Yellow Paper.
  """
  @spec check(t()) :: :ok | {:error, atom()}
  def check(state) do
    symbol = instruction(state)

    if Instruction.valid?(symbol) do
      check_stack(symbol, state.stack)
    else
      {:error, :invalid_instruction}
    end
  end

  @spec check_stack(atom(), Stack.t()) :: :ok | {:error, atom()}
  defp check_stack(symbol, stack) do
    {inputs, outputs} = Instruction.metadata(symbol)

    cond do
      Stack.length(stack) < inputs ->
        {:error, :stack_underflow}

      Stack.length(stack) - inputs + outputs > Stack.max_size() ->
        {:error, :stack_overflow}

      true ->
        :ok
    end
  end

  @doc """
  Returns `true` if the given state is "normal halting state".
  """
  @spec halt?(t()) :: boolean()
  def halt?(state), do: instruction(state) == :stop

  @spec instruction(t()) :: Instruction.expr()
  defp instruction(state), do: Enum.at(state.code, state.pc, :stop)

  @doc """
  Serializes the given `state` to a map.
  """
  @spec serialize(t()) :: map()
  def serialize(state) do
    %{
      "pc" => Hex.from_int(state.pc),
      "gas" => Hex.from_int(state.gas),
      "stack" => Stack.serialize(state.stack),
      "memory" => Memory.serialize(state.memory),
      "storage" => Storage.serialize(state.storage)
    }
  end
end
