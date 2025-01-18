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
  PROCESS (clk, rst) BEGIN
    IF rising_edge(clk) THEN
      state <= next_state;
    END IF;

    IF rst = '1' THEN
      state <= T0;
    END IF;
  END PROCESS;

  STATE_MACHINE : PROCESS (state)
    VARIABLE u_op : MICRO_OPERATION;

  BEGIN
    reset(u_op); -- Reset Micro Operations to ensure correct control signals

    CASE state IS
      WHEN T0 =>
        -- Setup Instruction Fetch
        u_op.mux_abl := "00";
        u_op.mux_abh := "00";
        u_op.wr_mem := READ_ENABLE;

        -- Update Program Counter
        u_op.pcl_en := '1';
        u_op.pch_en := '1';
        u_op.mux_pc := "00";

        next_state <= T1;
      WHEN T1 =>
        decInstruction <= decode(instruction);

        -- Store operand in instruction register
        u_op.ir_en := '1';

        -- Update program counter
        u_op.pcl_en := '1';
        u_op.pch_en := '1';

        next_state <= T2;
      WHEN T2 =>
        REPORT to_string(decInstruction);
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              u_op.ai_en := '1';
              u_op.bi_en := '1';
            WHEN OTHERS =>
          END CASE;
        END IF;

        --   u_op.pcl_en := '0';
        --   u_op.pch_en := '0';
        --   -- IF decInstrucion.instruction_type
      WHEN OTHERS =>
    END CASE;

    u_operation <= u_op;
  END PROCESS;
END behavioral;