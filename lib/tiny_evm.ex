defmodule TinyEVM do
  @moduledoc """
  A tiny Ethereum VM.
  """

  alias TinyEVM.{Program, State, Gas, Interpreter}

  @doc """
  Runs the TinyEVM on the given `input` and returns the
  serialized resulting `TinyEVM.State`.

  This function is similar to the Ξ function Eq.(123) of
  the Section 9.4 of the Yellow Paper.
  """
  @spec run(map()) :: map()
  def run(input) do
    input
    |> Program.new()
    |> State.new()
    |> execute()
    |> State.serialize()
  end

  @spec execute(State.t()) :: State.t()
  def execute(state) do
    case State.check(state) do
      {:error, reason} ->
        # Exceptional halting
        report_error(state, reason)
        state

      :ok ->
        cycle(state)
    end
  end

  # Runs a single execution cycle returning the new state,
  # defined as `O` in the Yellow Paper, Eq.(143).
  @spec cycle(State.t()) :: State.t()
  defp cycle(state), do: cycle(state, State.halt?(state))

  @spec cycle(State.t(), boolean()) :: State.t()
  # Normal halting
  defp cycle(state, true), do: state

  defp cycle(state, false) do
    {instruction, state} = State.read_instruction(state)
    gas = state.gas - Gas.cost(instruction)

    instruction
    |> Interpreter.execute(%{state | gas: gas})
    |> execute()
  end

  @spec report_error(State.t(), atom()) :: no_return()
  defp report_error(state, reason) do
    IO.puts("\nExecution error: #{reason}\n")
    IO.puts("\nState:\n")
    IO.inspect(state)
  end
end
