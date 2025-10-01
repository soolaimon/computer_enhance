defmodule CPU do
  @opcodes %{0b100010 => "mov"}

  def decode(<<one::binary-size(1), two::binary-size(1), _rest::binary>>) do
    decode_first_byte(one)
  end

  def decode(_), do: dbg("nope")

  defp decode_first_byte(<<opcode::6, d::size(1), w::size(1)>>) do
    op = @opcodes[opcode]
    dbg(op)
    dbg(d)
    dbg(w)
  end
end

# First Byte:
# 6 bits opcode
# then 1 bit `D` field - direction
# 1  = REG field in second byte identifies the destination operand
# 0  = REG field in secod byte identifies the source operand
# W field - distinguishes between `byte` and `word` operations
# 0 = byte
# 1 = word

# Second Byte:
# Instruction's operands
# 2 bit `MOD` (mode) field - whether one of the operands is in memory or both are in registers
# 00 Memory mode, no displacement follows (except when R/M = 110, then 16 bit displacement follows)
# 01 Memory mode, 8 bit displacement follows
# 10 Memory ode, 26 -bit displacement follows
# 11 Register mode (no displacement)
# REG field - 3 bits - used as an extension of the opcode toidentify the type of operation.
### REG wW=0 W=1
# 000 AL AX
# 001 CL CX
# 010 DL DX
# 011 BL BX
# 100 AH SP
# 101 CH BP
# 110 DH Sl
# 111 BH DI

# R/M field - 3 bits - depends on how MOD field is set. If MOD = 11 (register-to-register), then R/M identifies the second register operan. If MOD selects memory mode, then R/M indicates how the effective address of the memory operand is to be calculated.

# Bytes 3 through 6 of an instruction are optional
# fields that usually contain the displacement value
# of a memory operand and/or the actual value of
# an immediate constant operand.

[file | _] = System.argv() |> dbg()

IO.puts("Reading #{file}")

bin = File.read!(file)

CPU.decode(bin)
