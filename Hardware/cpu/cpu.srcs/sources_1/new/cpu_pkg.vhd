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

  TYPE CPU_STATE IS (T0, T1, T2, T3, T4, T5, T6, T7);

  -- Instruction types
  TYPE ADDRESSING_MODE IS (IMPL, IMM, ZERO_PAGE, ZERO_PAGE_X, ZERO_PAGE_Y, ABSOLUTE, ABSOLUTE_X, ABSOLUTE_Y, INDEXED_INDIRECT, INDIRECT_INDEXED);
  TYPE INSTRUCTION_GROUP IS (NONE, LOAD_REG, STORE_REG, SET_STATUS, CLEAR_STATUS);
  TYPE INSTRUCTION_TYPE IS (
    NOP, ADC, LDA, LDX, LDY, SC, CLC, CLV, JMP, STA
  );

  SUBTYPE INSTRUCTION IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  TYPE DECODED_INSTRUCTION IS RECORD
    instruction_type : INSTRUCTION_TYPE;
    instruction_group : INSTRUCTION_GROUP;
    addressing_mode : ADDRESSING_MODE;
    instruction_length : INTEGER;
  END RECORD DECODED_INSTRUCTION;

  FUNCTION decode (
    i_instr : INSTRUCTION
  ) RETURN DECODED_INSTRUCTION;

  -- Function to format DECODED_INSTRUCTION as a string
  FUNCTION to_string(di : DECODED_INSTRUCTION) RETURN STRING;

  -- Micro operations
  TYPE ALU_OPERATION IS (ADC, AD, AD_INC);

  TYPE mux_db_t IS (s_DATA, s_ACC, s_PCL, s_PCH, s_SB);
  TYPE mux_sb_t IS (s_RGX, s_RGY, s_ACC, s_ALU, s_ADH, s_DATA);
  TYPE mux_dout_t IS (s_DB);

  TYPE mux_pc_t IS (s_INCR, s_JMP);
  TYPE mux_addr_t IS (s_MA, s_AB);
  TYPE mux_ma_t IS (s_PC, s_ALU, s_DATA);
  TYPE mux_adl_t IS (s_PC, s_ALU, s_DATA);
  TYPE mux_adh_t IS (s_PC, s_DATA, s_ALU, s_ZERO);
  TYPE mux_ai_t IS (s_SB, s_ZERO);
  TYPE mux_bi_t IS (s_DB);
  TYPE mux_acc_t IS (s_SB, s_DB);
  TYPE mux_status_t IS (s_ALU, s_DATA, s_IMPL);
  TYPE MICRO_OPERATION IS RECORD
    wr_mem : STD_LOGIC; -- WRITE/READ operation
    alu_op : ALU_OPERATION;
    status_val : STD_LOGIC;

    -- Enables
    pcl_en : STD_LOGIC;
    pch_en : STD_LOGIC;
    ma_en : STD_LOGIC;
    abl_en : STD_LOGIC;
    abh_en : STD_LOGIC;
    ai_en : STD_LOGIC;
    bi_en : STD_LOGIC;
    acc_en : STD_LOGIC;
    rgx_en : STD_LOGIC;
    rgy_en : STD_LOGIC;
    status_en : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- MUX
    mux_db : mux_db_t;
    mux_sb : mux_sb_t;
    mux_dout : mux_dout_t;
    mux_pc : mux_pc_t;
    mux_ma : mux_ma_t;
    mux_addr : mux_addr_t;
    mux_adl : mux_adl_t;
    mux_adh : mux_adh_t;
    mux_ai : mux_ai_t;
    mux_bi : mux_bi_t;
    mux_acc : mux_acc_t;
    mux_status : mux_status_t;
  END RECORD MICRO_OPERATION;

  CONSTANT initial_op : MICRO_OPERATION := (
    wr_mem => '0',
    alu_op => ADC,
    status_val => '0',
    pcl_en => '0',
    pch_en => '0',
    ma_en => '0',
    abl_en => '0',
    abh_en => '0',
    ai_en => '0',
    bi_en => '0',
    acc_en => '0',
    rgx_en => '0',
    rgy_en => '0',
    status_en => (OTHERS => '0'),
    mux_db => s_DATA,
    mux_sb => s_ALU,
    mux_dout => s_DB,
    mux_pc => S_INCR,
    mux_ma => s_PC,
    mux_addr => s_MA,
    mux_adl => s_PC,
    mux_adh => s_PC,
    mux_ai => s_SB,
    mux_bi => s_DB,
    mux_acc => s_SB,
    mux_status => s_ALU
  );

  PROCEDURE reset(VARIABLE u_op : INOUT MICRO_OPERATION);
  PROCEDURE increment_pc(VARIABLE u_op : INOUT MICRO_OPERATION);
  PROCEDURE address_pc(VARIABLE u_op : INOUT MICRO_OPERATION);
  PROCEDURE store_in_reg(VARIABLE u_op : INOUT MICRO_OPERATION; SIGNAL instr : IN DECODED_INSTRUCTION);

  PROCEDURE store_adc(VARIABLE u_op : INOUT MICRO_OPERATION);
END PACKAGE;

PACKAGE BODY cpu_pkg IS
  PROCEDURE reset (VARIABLE u_op : INOUT MICRO_OPERATION) IS
  BEGIN
    u_op := initial_op;
  END PROCEDURE;

  PROCEDURE increment_pc(VARIABLE u_op : INOUT MICRO_OPERATION) IS
  BEGIN
    u_op.pcl_en := '1';
    u_op.pch_en := '1';
    u_op.mux_pc := S_INCR;
  END PROCEDURE;

  PROCEDURE address_pc(VARIABLE u_op : INOUT MICRO_OPERATION) IS
  BEGIN
    u_op.mux_addr := s_MA;
    u_op.mux_ma := s_PC;
    u_op.ma_en := '1';
  END PROCEDURE;

  PROCEDURE store_adc(VARIABLE u_op : INOUT MICRO_OPERATION) IS
  BEGIN
    u_op.mux_acc := s_SB;
    u_op.mux_sb := s_ALU;
    u_op.acc_en := '1';
    u_op.status_en(CARRY) := '1';
    u_op.status_en(ZERO) := '1';
    u_op.status_en(NEGATIVE) := '1';
    u_op.status_en(OVERFLOW) := '1';
  END PROCEDURE;

  PROCEDURE store_in_reg(VARIABLE u_op : INOUT MICRO_OPERATION; SIGNAL instr : IN DECODED_INSTRUCTION) IS
  BEGIN
    u_op.mux_SB := s_DATA;
    u_op.mux_acc := s_SB;

    u_op.acc_en := '1' WHEN instr.instruction_type = LDA ELSE
    '0';
    u_op.rgx_en := '1' WHEN instr.instruction_type = LDX ELSE
    '0';
    u_op.rgy_en := '1' WHEN instr.instruction_type = LDY ELSE
    '0';
  END PROCEDURE;

  FUNCTION decode (
    i_instr : INSTRUCTION
  ) RETURN DECODED_INSTRUCTION IS
    VARIABLE o_instr : DECODED_INSTRUCTION;
  BEGIN
    CASE (i_instr) IS
      WHEN x"69" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := IMM;
        o_instr.instruction_length := 2;
      WHEN x"65" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := ZERO_PAGE;
        o_instr.instruction_length := 2;
      WHEN x"75" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := ZERO_PAGE_X;
        o_instr.instruction_length := 2;
      WHEN x"6D" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;
      WHEN x"7D" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := ABSOLUTE_X;
        o_instr.instruction_length := 3;
      WHEN x"79" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := ABSOLUTE_Y;
        o_instr.instruction_length := 3;
      WHEN x"61" =>
        o_instr.instruction_type := ADC;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := INDEXED_INDIRECT;
        o_instr.instruction_length := 2;

      WHEN x"71" =>
        o_instr.instruction_group := NONE;
        o_instr.instruction_type := ADC;
        o_instr.addressing_mode := INDIRECT_INDEXED;
        o_instr.instruction_length := 2;

      WHEN x"A9" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := IMM;
        o_instr.instruction_length := 2;

      WHEN x"A5" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ZERO_PAGE;
        o_instr.instruction_length := 2;

      WHEN x"B5" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ZERO_PAGE_X;
        o_instr.instruction_length := 2;

      WHEN x"AD" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;

      WHEN x"BD" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE_X;
        o_instr.instruction_length := 3;

      WHEN x"B9" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE_Y;
        o_instr.instruction_length := 3;

      WHEN x"A1" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := INDEXED_INDIRECT;
        o_instr.instruction_length := 2;

      WHEN x"B1" =>
        o_instr.instruction_type := LDA;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := INDIRECT_INDEXED;
        o_instr.instruction_length := 2;

      WHEN x"A2" =>
        o_instr.instruction_type := LDX;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := IMM;
        o_instr.instruction_length := 2;

      WHEN x"A6" =>
        o_instr.instruction_type := LDX;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ZERO_PAGE;
        o_instr.instruction_length := 2;

      WHEN x"B6" =>
        o_instr.instruction_type := LDX;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ZERO_PAGE_Y;
        o_instr.instruction_length := 2;

      WHEN x"AE" =>
        o_instr.instruction_type := LDX;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;

      WHEN x"BE" =>
        o_instr.instruction_type := LDX;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE_Y;
        o_instr.instruction_length := 3;

      WHEN x"A0" =>
        o_instr.instruction_type := LDY;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := IMM;
        o_instr.instruction_length := 2;

      WHEN x"A4" =>
        o_instr.instruction_type := LDY;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ZERO_PAGE;
        o_instr.instruction_length := 2;

      WHEN x"B4" =>
        o_instr.instruction_type := LDY;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ZERO_PAGE_X;
        o_instr.instruction_length := 2;

      WHEN x"AC" =>
        o_instr.instruction_type := LDY;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;

      WHEN x"BC" =>
        o_instr.instruction_type := LDY;
        o_instr.instruction_group := LOAD_REG;
        o_instr.addressing_mode := ABSOLUTE_X;
        o_instr.instruction_length := 3;

      WHEN x"18" =>
        o_instr.instruction_type := CLC;
        o_instr.instruction_group := CLEAR_STATUS;
        o_instr.addressing_mode := IMPL;
        o_instr.instruction_length := 1;

      WHEN x"38" =>
        o_instr.instruction_type := SC;
        o_instr.instruction_group := SET_STATUS;
        o_instr.addressing_mode := IMPL;
        o_instr.instruction_length := 1;

      WHEN x"B8" =>
        o_instr.instruction_type := CLV;
        o_instr.instruction_group := CLEAR_STATUS;
        o_instr.addressing_mode := IMPL;
        o_instr.instruction_length := 1;

      WHEN x"4C" =>
        o_instr.instruction_type := JMP;
        o_instr.instruction_group := NONE;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;

      WHEN x"8D" =>
        o_instr.instruction_type := STA;
        o_instr.instruction_group := STORE_REG;
        o_instr.addressing_mode := ABSOLUTE;
        o_instr.instruction_length := 3;

      WHEN OTHERS =>
        o_instr.instruction_type := NOP;
        o_instr.instruction_group := NONE;
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
      WHEN ZERO_PAGE_Y => RETURN "Zero Page Y";
      WHEN ABSOLUTE => RETURN "Absolute";
      WHEN ABSOLUTE_X => RETURN "Absolute,X";
      WHEN ABSOLUTE_Y => RETURN "Absolute,Y";
      WHEN INDEXED_INDIRECT => RETURN "Indexed Indirect";
      WHEN INDEXED_INDIRECT => RETURN "Indirect Indexed";
      WHEN OTHERS => RETURN "UNKNOWN";
    END CASE;
  END FUNCTION;

  -- Function to convert INSTRUCTION_TYPE to a string
  FUNCTION to_string(it : INSTRUCTION_TYPE) RETURN STRING IS
  BEGIN
    CASE it IS
      WHEN ADC => RETURN "Add with Carry";
      WHEN LDA => RETURN "Load Accumulator";
      WHEN LDX => RETURN "Load X Register";
      WHEN LDY => RETURN "Load Y Register";
      WHEN SC => RETURN "Set Carry Flag";
      WHEN CLC => RETURN "Cear Carry Flag";
      WHEN CLV => RETURN "Cear Overflow Flag";
      WHEN JMP => RETURN "Jump";
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