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
  -- Program Counter
  SUBTYPE PC IS STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- Internal Registers
  SUBTYPE SP IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE ACC IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE RGX IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE RGY IS STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Memory signals
  TYPE MEMORY IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE AB IS STD_LOGIC_VECTOR(15 DOWNTO 0);
  SUBTYPE ABH IS STD_LOGIC_VECTOR(15 DOWNTO 8);
  SUBTYPE ABL IS STD_LOGIC_VECTOR(7 DOWNTO 0);

  SUBTYPE DB IS STD_LOGIC_VECTOR(7 DOWNTO 0);

  SUBTYPE ALU IS STD_LOGIC_VECTOR(15 DOWNTO 0);

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
  TYPE MICRO_OPERATION IS RECORD
    wr_mem : RW; -- WRITE/READ operation
    mux_abl : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for address bus low
    mux_abh : STD_LOGIC_VECTOR(1 DOWNTO 0); -- MUX for address bus high
    mux_pc : STD_LOGIC_VECTOR(1 DOWNTO 0);
  END RECORD MICRO_OPERATION;

END PACKAGE;

PACKAGE BODY cpu_pkg IS

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