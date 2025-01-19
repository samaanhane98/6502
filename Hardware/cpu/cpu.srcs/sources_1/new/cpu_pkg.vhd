----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 09:00:25 PM
-- Design Name: 
-- Module Name: cpu_pkg - 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

PACKAGE cpu_pkg IS
  -- Memory 
  TYPE MEMORY IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Address Registers
  SUBTYPE ABL IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE ABH IS STD_LOGIC_VECTOR(15 DOWNTO 8);

  -- Program Counter Registers
  SUBTYPE PC IS STD_LOGIC_VECTOR(15 DOWNTO 0);
  SUBTYPE PCH IS STD_LOGIC_VECTOR(15 DOWNTO 8);
  SUBTYPE PCL IS STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Internal Registers
  SUBTYPE SP IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE ACC IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE RGX IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE RGY IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  -- Busses
  SUBTYPE DB IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data bus
  SUBTYPE SB IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- Status bus
  SUBTYPE ADH IS STD_LOGIC_VECTOR(15 DOWNTO 8); -- Address Data High bus
  SUBTYPE ADL IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- Address Data Low bus

  -- Status type and indices
  TYPE STATUS IS ARRAY(6 DOWNTO 0) OF STD_LOGIC;
  CONSTANT CARRY : INTEGER := 0;
  CONSTANT ZERO : INTEGER := 1;
  CONSTANT INTERRUPT : INTEGER := 2;
  CONSTANT DECIMAL : INTEGER := 3;
  CONSTANT BREAKF : INTEGER := 4;
  CONSTANT UNUSED : INTEGER := 5;
  CONSTANT OVERFLOW : INTEGER := 6;
  CONSTANT NEGATIVE : INTEGER := 7;

  TYPE CPU_STATE IS (T0, T1, T2, T3, T4);

  -- Instruction types
  TYPE ADDRESSING_MODE IS (IMPL, IMM);
  TYPE INSTRUCTION_TYPE IS (
    NOP, ADC
  );

  SUBTYPE INSTRUCTION IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  TYPE DECODED_INSTRUCTION IS RECORD
    instruction_type : INSTRUCTION_TYPE;
    addressing_mode : ADDRESSING_MODE;
    instruction_length : INTEGER;
  END RECORD DECODED_INSTRUCTION;

  FUNCTION decode (
    i_instr : INSTRUCTION
  ) RETURN DECODED_INSTRUCTION;

  -- Function to format DECODED_INSTRUCTION as a string
  FUNCTION to_string(di : DECODED_INSTRUCTION) RETURN STRING;

  -- Micro operations
  TYPE RW IS (READ_ENABLE, WRITE_ENABLE);
  TYPE ALU_OPERATION IS (ADC);
  TYPE MICRO_OPERATION IS RECORD
    -- ENABLES
    ir_en : STD_LOGIC; -- Instruction register enable
    pcl_en : STD_LOGIC; -- PC Low register enable
    pch_en : STD_LOGIC; -- PC Low register enable
    ai_en : STD_LOGIC; -- A Input register enable
    bi_en : STD_LOGIC; -- B Input register enable
    wr_mem : RW; -- WRITE/READ operation

    -- MUX
    mux_abl : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for address bus low
    mux_abh : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for address bus high
    mux_ai : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for A input register
    mux_bi : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for B input register
    mux_pc : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for program counter

    -- Accumulator
    acc_en : STD_LOGIC;
    mux_acc : STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- ALU
    alu_op : ALU_OPERATION;
  END RECORD MICRO_OPERATION;

  PROCEDURE reset(VARIABLE u_op : INOUT MICRO_OPERATION);
END PACKAGE;

PACKAGE BODY cpu_pkg IS
  PROCEDURE reset (VARIABLE u_op : INOUT MICRO_OPERATION) IS
  BEGIN
    u_op.ir_en := '0';
    u_op.pcl_en := '0';
    u_op.pch_en := '0';
    u_op.ai_en := '0';
    u_op.bi_en := '0';
    u_op.wr_mem := READ_ENABLE;
    u_op.mux_abl := "00"; -- MUX for address bus low
    u_op.mux_abh := "00"; -- MUX for address bus high
    u_op.mux_ai := "00"; -- MUX for A input register
    u_op.mux_bi := "00"; -- MUX for B input register
    u_op.mux_pc := "00"; -- MUX for program counter
    u_op.alu_op := ADC;
  END PROCEDURE;

  FUNCTION decode (
    i_instr : INSTRUCTION
  ) RETURN DECODED_INSTRUCTION IS
    VARIABLE o_instr : DECODED_INSTRUCTION;
  BEGIN
    CASE (i_instr) IS
      WHEN x"69" =>
        o_instr.instruction_type := ADC;
        o_instr.addressing_mode := IMM;
        o_instr.instruction_length := 2;
        RETURN o_instr;
      WHEN OTHERS =>
        o_instr.instruction_type := NOP;
        o_instr.addressing_mode := IMPL;
        o_instr.instruction_length := 1;
        RETURN o_instr;
    END CASE;
  END;

  -- Function to convert ADDRESSING_MODE to a string
  FUNCTION to_string(am : ADDRESSING_MODE) RETURN STRING IS
  BEGIN
    CASE am IS
      WHEN IMM => RETURN "Immediate";
      WHEN IMPL => RETURN "Implied";
      WHEN OTHERS => RETURN "UNKNOWN";
    END CASE;
  END FUNCTION;

  -- Function to convert INSTRUCTION_TYPE to a string
  FUNCTION to_string(it : INSTRUCTION_TYPE) RETURN STRING IS
  BEGIN
    CASE it IS
      WHEN ADC => RETURN "Add with Carry";
      WHEN NOP => RETURN "No Operation";
      WHEN OTHERS => RETURN "UNKNOWN";
    END CASE;
  END FUNCTION;

  -- Function to format DECODED_INSTRUCTION as a string
  FUNCTION to_string(di : DECODED_INSTRUCTION) RETURN STRING IS
  BEGIN
    RETURN "Instruction Type: " & to_string(di.instruction_type) &
    ", Addressing Mode: " & to_string(di.addressing_mode) &
    ", Instruction Length: " & INTEGER'IMAGE(di.instruction_length);
  END FUNCTION;

END PACKAGE BODY cpu_pkg;