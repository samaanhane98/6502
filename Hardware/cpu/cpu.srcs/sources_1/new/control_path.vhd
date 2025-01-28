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

  SIGNAL adc_u_op : MICRO_OPERATION;
  SIGNAL ld_u_op : MICRO_OPERATION;

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

  STATE_MACHINE : PROCESS (state) BEGIN
    CASE STATE IS
      WHEN T0 =>
        next_state <= T1;
      WHEN T1 =>
        next_state <= T2;

      WHEN T2 =>
        IF decInstruction.instruction_type = ADC THEN
          next_state <= T3;
        ELSIF decInstruction.instruction_group = SET_REG THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              next_state <= T0;
            WHEN OTHERS =>
              next_state <= T3;
          END CASE;
        ELSE
          next_state <= T0;
        END IF;

      WHEN T3 =>
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              next_state <= T0;
            WHEN OTHERS =>
              next_state <= T4;
          END CASE;
        ELSIF decInstruction.instruction_group = SET_REG THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE =>
              next_state <= T0;
            WHEN OTHERS =>
              next_state <= T4;
          END CASE;
        END IF;

      WHEN T4 =>
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE =>
              next_state <= T0;
            WHEN OTHERS =>
              next_state <= T5;
          END CASE;
        ELSIF decInstruction.instruction_group = SET_REG THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE_X | ABSOLUTE =>
              next_state <= T0;
            WHEN OTHERS =>
              next_state <= T5;
          END CASE;
        END IF;

      WHEN T5 =>
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN ABSOLUTE_X | ABSOLUTE_Y | INDEXED_INDIRECT | INDIRECT_INDEXED =>
              next_state <= T6;
            WHEN OTHERS =>
              next_state <= T0;
          END CASE;
        ELSIF decInstruction.instruction_group = SET_REG THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN INDEXED_INDIRECT | INDIRECT_INDEXED =>
              next_state <= T6;
            WHEN OTHERS =>
              next_state <= T0;
          END CASE;

        END IF;

      WHEN T6 =>
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              next_state <= T0;

            WHEN OTHERS =>
              next_state <= T7;
          END CASE;
        ELSIF decInstruction.instruction_group = SET_REG THEN
          next_state <= T0;
        END IF;

      WHEN T7 =>
        IF decInstruction.instruction_type = ADC THEN
          CASE (decInstruction.addressing_mode) IS
            WHEN INDEXED_INDIRECT | INDIRECT_INDEXED =>
              next_state <= T0;

            WHEN OTHERS =>
          END CASE;
        END IF;
      WHEN OTHERS =>
    END CASE;
  END PROCESS;

  CONTROL_SIGNALS : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
    IF state = T0 THEN
      ------- Addressing ------- 
      address_pc(u_op);
      -------------------------- 

      increment_pc(u_op);
      u_operation <= u_op;
    ELSIF state = T1 THEN
      ------- Addressing ------- 
      address_pc(u_op);
      -------------------------- 

      increment_pc(u_op);
      u_operation <= u_op;
    ELSE
      CASE decInstruction.instruction_type IS
        WHEN ADC =>
          u_operation <= adc_u_op;
        WHEN LDA | LDX | LDY =>
          u_operation <= ld_u_op;
        WHEN OTHERS =>
      END CASE;
    END IF;
    IF rst = '1' THEN
      reset(u_op);
      u_operation <= u_op;
    END IF;
  END PROCESS;

  ADC_instr : PROCESS (state)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
    IF decInstruction.instruction_type = ADC THEN
      CASE state IS
        WHEN T2 =>
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              u_op.mux_sb := s_ACC;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';
            WHEN ZERO_PAGE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              u_op.mux_ma := s_DATA;
              u_op.ma_en := '1';

            WHEN ZERO_PAGE_X =>
              u_op.mux_sb := s_RGX;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN ABSOLUTE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              increment_pc(u_op);
              u_op.mux_ma := s_PC;
              u_op.ma_en := '1';

              u_op.mux_adl := s_DATA;
              u_op.abl_en := '1';

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              increment_pc(u_op);
              u_op.mux_ma := s_PC;
              u_op.ma_en := '1';

              u_op.mux_sb := s_RGX WHEN decInstruction.addressing_mode = ABSOLUTE_X ELSE
              s_RGY;
              u_op.mux_ai := s_sb;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_db;
              u_op.bi_en := '1';

            WHEN INDEXED_INDIRECT =>
              u_op.mux_sb := s_RGX;
              u_op.mux_ai := s_sb;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_db;
              u_op.bi_en := '1';

            WHEN INDIRECT_INDEXED =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              u_op.mux_ma := s_DATA;
              u_op.ma_en := '1';

              u_op.mux_ai := s_ZERO;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_db;
              u_op.bi_en := '1';

            WHEN OTHERS =>
          END CASE;

        WHEN T3 =>
          u_op.alu_op := ADC;
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              store_adc(u_op);
            WHEN ZERO_PAGE =>
              u_op.mux_sb := s_ACC;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN ZERO_PAGE_X =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
            WHEN ABSOLUTE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.mux_adh := s_DATA;
              u_op.abh_en := '1';

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              increment_pc(u_op);
              u_op.mux_ma := s_PC;
              u_op.ma_en := '1';

              u_op.mux_ai := s_ZERO;
              u_op.ai_en := '1';
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';

            WHEN INDEXED_INDIRECT =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_ZERO;
              u_op.abh_en := '1';

            WHEN INDIRECT_INDEXED =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              u_op.alu_op := AD_INC;
              u_op.mux_ma := s_ALU;
              u_op.ma_en := '1';

              u_op.mux_sb := s_RGY;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';
            WHEN OTHERS =>
          END CASE;

        WHEN T4 =>
          u_op.alu_op := ADC;
          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE =>
              store_adc(u_op);

            WHEN ZERO_PAGE_X =>
              u_op.mux_sb := s_ACC;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN ABSOLUTE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.mux_sb := s_ACC;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.mux_adh := s_ALU;
              u_op.abh_en := '1';

            WHEN INDEXED_INDIRECT =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.alu_op := AD_INC;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_ZERO;
              u_op.abh_en := '1';

              u_op.mux_ai := s_ZERO;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN INDIRECT_INDEXED =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_ZERO;
              u_op.abh_en := '1';

              u_op.alu_op := AD;
              u_op.mux_ai := s_ZERO;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN OTHERS =>
          END CASE;
        WHEN T5 =>
          u_op.alu_op := ADC;
          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE_X =>
              store_adc(u_op);

            WHEN ABSOLUTE =>
              store_adc(u_op);

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              u_op.mux_sb := s_ACC;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN INDEXED_INDIRECT =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_DATA;
              u_op.abh_en := '1';

            WHEN INDIRECT_INDEXED =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.mux_adh := s_ALU;
              u_op.abh_en := '1';

            WHEN OTHERS =>
          END CASE;

        WHEN T6 =>
          u_op.alu_op := ADC;
          CASE (decInstruction.addressing_mode) IS
            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              store_adc(u_op);
            WHEN INDEXED_INDIRECT | INDIRECT_INDEXED =>
              u_op.mux_sb := s_ACC;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN OTHERS =>
          END CASE;

        WHEN T7 =>
          u_op.alu_op := ADC;
          CASE (decInstruction.addressing_mode) IS
            WHEN INDEXED_INDIRECT | INDIRECT_INDEXED =>
              store_adc(u_op);
            WHEN OTHERS =>
          END CASE;
        WHEN OTHERS =>
      END CASE;
    END IF;
    adc_u_op <= u_op;
  END PROCESS;

  -- ! LDA, LDX, LDY
  LD_instr : PROCESS (state, rst)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
    IF decInstruction.instruction_group = SET_REG THEN
      CASE state IS
        WHEN T2 =>
          CASE (decInstruction.addressing_mode) IS
            WHEN IMM =>
              store_in_reg(u_op, decInstruction);

              u_op.mux_status := s_DATA;
              u_op.status_en(ZERO) := '1';
              u_op.status_en(NEGATIVE) := '1';

            WHEN ZERO_PAGE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              u_op.mux_ma := s_DATA;
              u_op.ma_en := '1';

            WHEN ZERO_PAGE_X =>
              u_op.mux_sb := s_RGX;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN ABSOLUTE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              increment_pc(u_op);
              u_op.mux_ma := s_PC;
              u_op.ma_en := '1';

              u_op.mux_adl := s_DATA;
              u_op.abl_en := '1';

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              increment_pc(u_op);
              u_op.mux_ma := s_PC;
              u_op.ma_en := '1';

              u_op.mux_sb := s_RGX WHEN decInstruction.addressing_mode = ABSOLUTE_X ELSE
              s_RGY;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN INDEXED_INDIRECT =>
              u_op.mux_sb := s_RGX;
              u_op.mux_ai := s_SB;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

            WHEN OTHERS =>
          END CASE;
        WHEN T3 =>

          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE =>
              store_in_reg(u_op, decInstruction);

              u_op.mux_status := s_DATA;
              u_op.status_en(ZERO) := '1';
              u_op.status_en(NEGATIVE) := '1';
            WHEN ZERO_PAGE_X =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';

            WHEN ABSOLUTE =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.mux_adh := s_DATA;
              u_op.abh_en := '1';

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              ------- Addressing ------- 
              u_op.mux_addr := s_MA;
              -------------------------- 

              increment_pc(u_op);
              u_op.mux_ma := s_PC;
              u_op.ma_en := '1';

              u_op.mux_ai := s_ZERO;
              u_op.ai_en := '1';
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';

              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';

            WHEN INDEXED_INDIRECT =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_ZERO;
              u_op.abh_en := '1';
            WHEN OTHERS =>
          END CASE;
        WHEN T4 =>
          CASE (decInstruction.addressing_mode) IS
            WHEN ZERO_PAGE_X =>
              store_in_reg(u_op, decInstruction);

              u_op.mux_status := s_DATA;
              u_op.status_en(ZERO) := '1';
              u_op.status_en(NEGATIVE) := '1';

            WHEN ABSOLUTE =>
              store_in_reg(u_op, decInstruction);

              u_op.mux_status := s_DATA;
              u_op.status_en(ZERO) := '1';
              u_op.status_en(NEGATIVE) := '1';

            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 

              u_op.mux_adh := s_ALU;
              u_op.abh_en := '1';

            WHEN INDEXED_INDIRECT =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_ZERO;
              u_op.abh_en := '1';

              u_op.alu_op := AD_INC;
              u_op.mux_ai := s_ZERO;
              u_op.ai_en := '1';

              u_op.mux_db := s_DATA;
              u_op.mux_bi := s_DB;
              u_op.bi_en := '1';
            WHEN OTHERS =>
          END CASE;
        WHEN T5 =>
          CASE (decInstruction.addressing_mode) IS
            WHEN ABSOLUTE_X | ABSOLUTE_Y =>
              store_in_reg(u_op, decInstruction);

              u_op.mux_status := s_DATA;
              u_op.status_en(ZERO) := '1';
              u_op.status_en(NEGATIVE) := '1';
            WHEN INDEXED_INDIRECT =>
              ------- Addressing ------- 
              u_op.mux_addr := s_AB;
              -------------------------- 
              u_op.alu_op := AD;
              u_op.mux_adl := s_ALU;
              u_op.abl_en := '1';
              u_op.mux_adh := s_DATA;
              u_op.abh_en := '1';

            WHEN OTHERS =>

          END CASE;

        WHEN T6 =>
          store_in_reg(u_op, decInstruction);

          u_op.mux_status := s_DATA;
          u_op.status_en(ZERO) := '1';
          u_op.status_en(NEGATIVE) := '1';

        WHEN OTHERS =>
      END CASE;
    END IF;

    ld_u_op <= u_op;
  END PROCESS;
END behavioral;