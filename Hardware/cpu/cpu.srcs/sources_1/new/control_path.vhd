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

  -- SIGNAL IR : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

  SIGNAL decInstruction : DECODED_INSTRUCTION;

BEGIN

  IR_FETCH : PROCESS (clk) BEGIN
    IF rising_edge(clk) THEN
      IF state = T1 THEN
        decInstruction <= decode(instruction);

      END IF;
    END IF;
  END PROCESS;

  PROCESS (clk, rst) BEGIN
    IF rising_edge(clk) THEN
      state <= next_state;
    END IF;

    IF rst = '1' THEN
      state <= T0;
    END IF;
  END PROCESS;

  STATE_MACHINE : PROCESS (state, rst)
    VARIABLE u_op : MICRO_OPERATION;

  BEGIN
    reset(u_op); -- Reset Micro Operations to ensure correct control signals

    CASE state IS
      WHEN T0 =>
        -- Setup Instruction Fetch
        u_op.mux_addr := s_MA;

        u_op.mux_adl := s_PC;
        u_op.mux_ma := s_PC;
        u_op.ma_en := '1';
        -- Update Program Counter
        u_op.mux_pc := s_INCR;
        u_op.pcl_en := '1';
        u_op.pch_en := '1';

        next_state <= T1;
      WHEN T1 =>
        u_op.mux_addr := s_MA;

        u_op.mux_adl := s_PC;
        u_op.mux_ma := s_PC;
        u_op.ma_en := '1';

        -- Update program counter
        u_op.mux_pc := s_INCR;
        u_op.pcl_en := '1';
        u_op.pch_en := '1';

        next_state <= T2;
      WHEN T2 =>
        REPORT to_string(decInstruction);
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              u_op.mux_ai := s_ACC;
              u_op.ai_en := '1';

              u_op.mux_bi := s_DATA;
              u_op.bi_en := '1';
            WHEN ZERO_PAGE =>

            WHEN ZERO_PAGE_X =>
            WHEN ABSOLUTE =>

            WHEN OTHERS =>
          END CASE;
          next_state <= T3;

        ELSE
          next_state <= T0;
        END IF;

      WHEN T3 =>
        IF decInstruction.instruction_type = ADC THEN
          u_op.alu_op := ADC;

          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              -- Enable status registers
              u_op.status_en(CARRY) := '1';
              u_op.status_en(ZERO) := '1';
              u_op.status_en(OVERFLOW) := '1';
              u_op.status_en(NEGATIVE) := '1';

              -- Store result in accumulator
              u_op.mux_acc := s_ALU;
              u_op.acc_en := '1';
              next_state <= T0;

            WHEN ZERO_PAGE =>
            WHEN ZERO_PAGE_X =>
            WHEN ABSOLUTE =>

            WHEN OTHERS =>
          END CASE;

        ELSE
          next_state <= T0;
        END IF;
      WHEN OTHERS =>

    END CASE;

    u_operation <= u_op;
  END PROCESS;
END behavioral;