defmodule CPU do
  def decode_file(file) do
    asm =
      file
      |> File.stream!(2)
      |> Enum.map_join("\n", &decode_bin/1)

    "bits 16\n\n" <> asm
  end

  defp decode_bin(<<opcode::6, _d::size(1), _w::size(1), _mod::2, _reg::3, _r_m::3>> = all) do
    {dest, source} = dest_source(all)
    op(opcode) <> " " <> dest <> ", " <> source
  end

  defp decode_bin(<<>>), do: ""

  # d is 0. reg is source, r_m is dest
  defp dest_source(<<_::6, 0::size(1), w::size(1), 0b11::2, reg::3, r_m::3>>),
    do: {reg(r_m, w), reg(reg, w)}

  defp dest_source(<<_::6, 1::size(1), w::size(1), 0b11::2, reg::3, r_m::3>>),
    do: {reg(reg, w), reg(r_m, w)}

  def decode(_), do: dbg("nope")

  defp reg(0b000, 0), do: "al"
  defp reg(0b000, 1), do: "ax"
  defp reg(0b001, 0), do: "cl"
  defp reg(0b001, 1), do: "cx"
  defp reg(0b010, 0), do: "dl"
  defp reg(0b010, 1), do: "dx"
  defp reg(0b011, 0), do: "bl"
  defp reg(0b011, 1), do: "bx"
  defp reg(0b100, 0), do: "ah"
  defp reg(0b100, 1), do: "sp"
  defp reg(0b101, 0), do: "ch"
  defp reg(0b101, 1), do: "bp"
  defp reg(0b110, 0), do: "dh"
  defp reg(0b110, 1), do: "si"
  defp reg(0b111, 0), do: "bh"
  defp reg(0b111, 1), do: "di"
  defp reg(_, _), do: "idk"

  defp op(0b100010), do: "mov"
  defp op(_), do: "idk man"

  defp bits(bits) when is_integer(bits) do
    Integer.to_string(bits, 2)
  end

  defp bits(bits) do
    byte_size(bits)
  end
end

# First Byte:
# 6 bits opcode
# then 1 bit `D` field - direction
# 1  = REG field in second byte identifies the dination operand
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

[file | _] = System.argv()

IO.puts("Reading #{file}")

CPU.decode_file(file)
|> then(&File.write("#{file}_dave.asm", &1))
