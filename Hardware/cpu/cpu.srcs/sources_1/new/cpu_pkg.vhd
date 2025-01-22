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
  SUBTYPE SB IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- Status bus
  SUBTYPE ADH IS STD_LOGIC_VECTOR(15 DOWNTO 8); -- Address Data High bus
  SUBTYPE ADL IS STD_LOGIC_VECTOR(7 DOWNTO 0); -- Address Data Low bus

  -- Status type and indices
  TYPE STATUS IS ARRAY(7 DOWNTO 0) OF STD_LOGIC;
  CONSTANT CARRY : INTEGER := 0;
  CONSTANT ZERO : INTEGER := 1;
  CONSTANT INTERRUPT : INTEGER := 2;
  CONSTANT DECIMAL : INTEGER := 3;
  CONSTANT BREAKF : INTEGER := 4;
  CONSTANT UNUSED : INTEGER := 5;
  CONSTANT OVERFLOW : INTEGER := 6;
  CONSTANT NEGATIVE : INTEGER := 7;

  TYPE CPU_STATE IS (T0, T1, T2, T3, T4, T5);

  -- Instruction types
  TYPE ADDRESSING_MODE IS (IMPL, IMM, ZERO_PAGE, ZERO_PAGE_X, ABSOLUTE);
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
  TYPE ALU_OPERATION IS (ADC, AD);

  TYPE mux_addr_t IS (s_PC, s_AB);
  TYPE mux_abl_t IS (s_ALU, s_DATA);
  TYPE mux_abh_t IS (s_ZERO, s_DATA);
  TYPE mux_ai_t IS (s_ACC, s_RGX);
  TYPE mux_bi_t IS (s_DATA); -- Is this the proper name?
  TYPE mux_pc_t IS (s_INCR);
  TYPE mux_rgx_t IS (s_ALU);
  TYPE mux_acc_t IS (s_ALU);

  TYPE MICRO_OPERATION IS RECORD
    wr_mem : RW; -- WRITE/READ operation

    -- ENABLES
    pcl_en : STD_LOGIC; -- PC Low register enable
    pch_en : STD_LOGIC; -- PC Low register enable
    abl_en : STD_LOGIC; -- Address bus low register enable
    abh_en : STD_LOGIC; -- Address bus low register enable
    ai_en : STD_LOGIC; -- A Input register enable
    bi_en : STD_LOGIC; -- B Input register enable
    rgx_en : STD_LOGIC; -- X index register enable
    rgy_en : STD_LOGIC; -- X index register enable

    status_en : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- MUX
    mux_addr : mux_addr_t;
    mux_abl : mux_abl_t; -- MUX for address bus low
    mux_abh : mux_abh_t; -- MUX for address bus high
    mux_ai : mux_ai_t; -- MUX for A input register
    mux_bi : mux_bi_t; -- MUX for B input register
    mux_pc : mux_pc_t; -- MUX for program counter
    mux_dl : STD_LOGIC;
    mux_rgx : mux_rgx_t;

    -- Accumulator
    acc_en : STD_LOGIC;
    mux_acc : mux_acc_t;

    -- ALU
    alu_op : ALU_OPERATION;

  END RECORD MICRO_OPERATION;

  PROCEDURE reset(VARIABLE u_op : INOUT MICRO_OPERATION);
END PACKAGE;

PACKAGE BODY cpu_pkg IS
  PROCEDURE reset (VARIABLE u_op : INOUT MICRO_OPERATION) IS
  BEGIN
    u_op.pcl_en := '0';
    u_op.pch_en := '0';
    u_op.abl_en := '0';
    u_op.abh_en := '0';
    u_op.ai_en := '0';
    u_op.bi_en := '0';
    u_op.rgx_en := '0';
    u_op.rgy_en := '0';
    u_op.status_en := (OTHERS => '0');
    u_op.wr_mem := READ_ENABLE;

    u_op.mux_addr := s_PC; -- MUX for address 
    u_op.mux_abl := s_ALU; -- MUX for address bus low
    u_op.mux_abh := s_ZERO; -- MUX for address bus high
    u_op.mux_ai := s_ACC; -- MUX for A input register
    u_op.mux_bi := s_DATA; -- MUX for B input register
    u_op.mux_pc := s_INCR; -- MUX for program counter
    u_op.mux_dl := '0';
    u_op.acc_en := '0';
    u_op.mux_rgx := s_ALU;
    u_op.mux_acc := s_ALU;
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
      WHEN x"65" =>
        o_instr.instruction_type := ADC;
        o_instr.addressing_mode := ZERO_PAGE;
        o_instr.instruction_length := 2;
      WHEN x"75" =>
        o_instr.instruction_type := ADC;
        o_instr.addressing_mode := ZERO_PAGE_X;
        o_instr.instruction_length := 2;

      WHEN x"6D" =>
        o_instr.instruction_type := ADC;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;

      WHEN OTHERS =>

        o_instr.instruction_type := NOP;
        o_instr.addressing_mode := IMPL;
        o_instr.instruction_length := 1;
    END CASE;
    RETURN o_instr;
  END;

  -- Function to convert ADDRESSING_MODE to a string
  FUNCTION to_string(am : ADDRESSING_MODE) RETURN STRING IS
  BEGIN
    CASE am IS
      WHEN IMM => RETURN "Immediate";
      WHEN IMPL => RETURN "Implied";
      WHEN ZERO_PAGE => RETURN "Zero Page";
      WHEN ZERO_PAGE_X => RETURN "Zero Page X";
      WHEN ABSOLUTE => RETURN "Absolute";
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