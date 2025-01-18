----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 10:42:15 AM
-- Design Name: 
-- Module Name: control_path - behavioral
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
USE IEEE.NUMERIC_STD.ALL;

USE work.cpu_pkg.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY control_path IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    u_operation : OUT MICRO_OPERATION;
    instruction : IN INSTRUCTION
  );

END control_path;

ARCHITECTURE behavioral OF control_path IS
  SIGNAL state, next_state : CPU_STATE := T0;

  SIGNAL decInstruction : DECODED_INSTRUCTION;

BEGIN

  decInstruction <= decode(instruction);

  PROCESS (clk, rst) BEGIN
    IF rising_edge(clk) THEN
      state <= next_state;
    END IF;

    IF rst = '1' THEN
      state <= T0;
    END IF;
  END PROCESS;

  STATE_MACHINE : PROCESS (state, decInstruction)
    VARIABLE u_op : MICRO_OPERATION;

  BEGIN
    CASE state IS
      WHEN T0 =>
        u_op.wr_mem := READ_ENABLE;
        u_op.mux_abl := "00";
        u_op.mux_abh := "00";
        u_op.mux_pc := '0';
        u_op.en_pc_incr := '1';
        next_state <= T1;
      WHEN T1 =>
        u_op.wr_mem := READ_ENABLE;
        u_op.mux_abl := "00";
        u_op.mux_abh := "00";
        u_op.mux_pc := '0';
        u_op.en_pc_incr := '0';

        REPORT to_string(decInstruction);

      WHEN T2 =>
        -- IF decInstrucion.instruction_type
      WHEN OTHERS =>
    END CASE;

    u_operation <= u_op;
  END PROCESS;
END behavioral;