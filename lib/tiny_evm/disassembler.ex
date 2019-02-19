defmodule TinyEVM.Disassembler do
  @moduledoc """
  This module is responsible for disassembling the bytecode.
  """

  alias TinyEVM.Instruction

  @type assembly :: [Instruction.expr()]
  @type options :: [{:strict, true | false}]

  @defaults [strict: true]

  @doc """
  Disassembles the given binary code.

  ## Options

  * `:strict` (boolean) - if `true`, will raise a `TinyEVM.Instruction.Invalid` exception when
    unknown opcode is encountered. Defaults to `true`.

  ## Examples

      iex> TinyEVM.Disassembler.run(<<96, 5, 96, 4, 1>>)
      [:push1, 5, :push1, 4, :add]

      iex> TinyEVM.Disassembler.run(<<96, 3, 96, 1, 96, 6, 96, 0, 3, 96, 0, 85>>)
      [:push1, 3, :push1, 1, :push1, 6, :push1, 0, :sub, :push1, 0, :sstore]
  """
  @spec run(binary(), options()) :: assembly()
  def run(bytecode, opts \\ @defaults), do: disassemble([], bytecode, opts)

  @spec disassemble(assembly(), binary(), options()) :: assembly()
  defp disassemble(acc, <<>>, _), do: Enum.reverse(acc)

  defp disassemble(acc, <<opcode::8, bytecode::binary()>>, opts) do
    {assembly, rest} = Instruction.decode(opcode, bytecode, opts[:strict])
    disassemble(assembly ++ acc, rest, opts)
  end
end
