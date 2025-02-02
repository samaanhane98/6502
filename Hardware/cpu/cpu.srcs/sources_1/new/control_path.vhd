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

  SIGNAL IR : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL decInstruction : DECODED_INSTRUCTION := (
    instruction_type => NOP,
    instruction_group => NONE,
    addressing_mode => IMPL,
    instruction_length => 1
  );

  SIGNAL adc_u_op : MICRO_OPERATION := initial_op;
  SIGNAL ld_u_op : MICRO_OPERATION := initial_op;
  SIGNAL st_u_op : MICRO_OPERATION := initial_op;
  SIGNAL stat_u_op : MICRO_OPERATION := initial_op;
  SIGNAL jmp_u_op : MICRO_OPERATION := initial_op;
  SIGNAL branch_u_op : MICRO_OPERATION := initial_op;

BEGIN
  PROCESS (clk, rst) BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        state <= T0;
      ELSE
        state <= next_state;
      END IF;
    END IF;

  END PROCESS;

  PROCESS (clk, state) BEGIN
    IF rising_edge(clk) AND state = T1 THEN
      IR <= instruction;
    END IF;
  END PROCESS;

  decInstruction <= decode(IR);

  STATE_MACHINE : PROCESS (ALL) BEGIN
    CASE state IS
      WHEN T0 =>
        next_state <= T1;
      WHEN T1 =>
        IF instruction = x"38" OR instruction = x"18" OR instruction = x"B8" THEN
          next_state <= T0;
        ELSE
          next_state <= T2;
        END IF;
      WHEN T2 =>
        IF decInstruction.instruction_group = LOAD_REG AND decInstruction.addressing_mode = IMM THEN
          next_state <= T0;
        ELSE
          next_state <= T3;
        END IF;
      WHEN T3 =>
        IF decInstruction.instruction_type = ADC AND decInstruction.addressing_mode = IMM THEN
          next_state <= T0;
        ELSIF decInstruction.instruction_type = JMP THEN
          next_state <= T0;
        ELSIF decInstruction.instruction_group = LOAD_REG AND decInstruction.addressing_mode = ZERO_PAGE THEN
          next_state <= T0;
        ELSE
          next_state <= T4;
        END IF;

      WHEN T4 =>
        IF decInstruction.instruction_type = ADC AND decInstruction.addressing_mode = ZERO_PAGE THEN
          next_state <= T0;

        ELSIF decInstruction.instruction_group = LOAD_REG AND (decInstruction.addressing_mode = ZERO_PAGE_X OR decInstruction.addressing_mode = ABSOLUTE) THEN
          next_state <= T0;
        ELSIF decInstruction.instruction_type = STA THEN
          next_state <= T0;
        ELSIF decInstruction.instruction_group = BRANCH THEN
          next_state <= T0;
        ELSE
          next_state <= T5;
        END IF;

      WHEN T5 =>
        IF decInstruction.instruction_type = ADC AND (decInstruction.addressing_mode = ZERO_PAGE_X OR decInstruction.addressing_mode = ABSOLUTE) THEN
          next_state <= T0;
        ELSE
          next_state <= T6;
        END IF;

      WHEN T6 =>
        IF decInstruction.instruction_type = ADC AND (decInstruction.addressing_mode = ABSOLUTE_X OR decInstruction.addressing_mode = ABSOLUTE_Y) THEN
          next_state <= T0;
        ELSIF decInstruction.instruction_group = LOAD_REG AND (decInstruction.addressing_mode = INDEXED_INDIRECT OR decInstruction.addressing_mode = INDIRECT_INDEXED) THEN
          next_state <= T0;
        ELSE
          next_state <= T7;
        END IF;

      WHEN T7 =>
        next_state <= T0;
      WHEN OTHERS =>
        next_state <= T0;
    END CASE;
  END PROCESS;

  CONTROL_SIGNALS : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION := initial_op;
  BEGIN
    reset(u_op);
    IF state = T0 THEN
      ------- Addressing ------- 
      address_pc(u_op);
      -------------------------- 

      increment_pc(u_op);
      u_operation <= u_op;
    ELSIF state = T1 THEN
      IF instruction = x"18" OR instruction = x"38" OR instruction = x"B8" THEN
        u_operation <= stat_u_op;
      ELSE
        ------- Addressing ------- 
        address_pc(u_op);
        -------------------------- 
        increment_pc(u_op);

        u_operation <= u_op;
      END IF;
    ELSE
      CASE decInstruction.instruction_type IS
        WHEN ADC =>
          u_operation <= adc_u_op;
        WHEN LDA | LDX | LDY =>
          u_operation <= ld_u_op;
        WHEN STA =>
          u_operation <= st_u_op;
        WHEN JMP =>
          u_operation <= jmp_u_op;
        WHEN BEQ =>
          u_operation <= branch_u_op;

        WHEN OTHERS =>
          u_operation <= initial_op;
      END CASE;
    END IF;
  END PROCESS;
  ADC_instr : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
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
            u_op := initial_op;
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
            u_op := initial_op;
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

            u_op.alu_op := ADC;
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
            u_op := initial_op;
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

            u_op.alu_op := ADC;
            u_op.mux_adh := s_ALU;
            u_op.abh_en := '1';

          WHEN OTHERS =>
            u_op := initial_op;
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
            u_op := initial_op;
        END CASE;

      WHEN T7 =>
        u_op.alu_op := ADC;
        CASE (decInstruction.addressing_mode) IS
          WHEN INDEXED_INDIRECT | INDIRECT_INDEXED =>
            store_adc(u_op);
          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;
      WHEN OTHERS =>
        u_op := initial_op;
    END CASE;
    adc_u_op <= u_op;
  END PROCESS;

  -- -- ! LDA, LDX, LDY
  LD_instr : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
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

          WHEN ZERO_PAGE_X | ZERO_PAGE_Y =>
            u_op.mux_sb := s_RGX WHEN decInstruction.addressing_mode = ZERO_PAGE_X ELSE
            s_RGY;
            u_op.mux_ai := s_SB;
            u_op.ai_en := '1';

            u_op.mux_db := s_DATA;
            u_op.mux_bi := s_DB;
            u_op.bi_en := '1';

          WHEN ABSOLUTE =>
            ------- Addressing ------- 
            address_pc(u_op);
            -------------------------- 

            increment_pc(u_op);

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

          WHEN INDIRECT_INDEXED =>
            ------- Addressing ------- 
            u_op.mux_addr := s_MA;
            -------------------------- 

            u_op.mux_ma := s_DATA;
            u_op.ma_en := '1';

            u_op.mux_ai := s_ZERO;
            u_op.ai_en := '1';

            u_op.mux_db := s_DATA;
            u_op.mux_bi := s_DB;
            u_op.bi_en := '1';

          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;
      WHEN T3 =>

        CASE (decInstruction.addressing_mode) IS
          WHEN ZERO_PAGE =>
            store_in_reg(u_op, decInstruction);

            u_op.mux_status := s_DATA;
            u_op.status_en(ZERO) := '1';
            u_op.status_en(NEGATIVE) := '1';
          WHEN ZERO_PAGE_X | ZERO_PAGE_Y =>
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
            u_op := initial_op;
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

            u_op.alu_op := ADC;
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
            u_op := initial_op;
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

          WHEN INDIRECT_INDEXED =>
            ------- Addressing ------- 
            u_op.mux_addr := s_AB;
            -------------------------- 

            u_op.alu_op := ADC;
            u_op.mux_adh := s_ALU;
            u_op.abh_en := '1';

          WHEN OTHERS =>
            u_op := initial_op;

        END CASE;

      WHEN T6 =>
        store_in_reg(u_op, decInstruction);

        u_op.mux_status := s_DATA;
        u_op.status_en(ZERO) := '1';
        u_op.status_en(NEGATIVE) := '1';

      WHEN OTHERS =>
        u_op := initial_op;
    END CASE;

    ld_u_op <= u_op;
  END PROCESS;

  ST_instr : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
    CASE state IS
      WHEN T2 =>
        CASE (decInstruction.addressing_mode) IS
          WHEN ABSOLUTE =>
            ------- Addressing ------- 
            address_pc(u_op);
            -------------------------- 

            increment_pc(u_op);

            u_op.mux_adl := s_DATA;
            u_op.abl_en := '1';
          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;
      WHEN T3 =>
        CASE (decInstruction.addressing_mode) IS
          WHEN ABSOLUTE =>
            u_op.mux_adh := s_DATA;
            u_op.abh_en := '1';
          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;
      WHEN T4 =>
        CASE (decInstruction.addressing_mode) IS
          WHEN ABSOLUTE =>
            u_op.mux_addr := s_AB;
            u_op.wr_mem := '1';
            u_op.mux_db := s_ACC;
            u_op.mux_dout := s_DB;
          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;

      WHEN OTHERS =>
        u_op := initial_op;
    END CASE;
    st_u_op <= u_op;
  END PROCESS;

  -- Mannually decode instruction since decInstruction is not available yet
  STAGUS_FLAG_instr : PROCESS (ALL) IS
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
    IF state = T1 THEN
      ------- Addressing ------- 
      address_pc(u_op);
      -------------------------- 
      u_op.mux_status := s_IMPL;

      u_op.status_val := '1' WHEN instruction = x"38" ELSE
      '0';

      u_op.status_en(CARRY) := '1' WHEN instruction = x"38" ELSE
      '1' WHEN instruction = x"18" ELSE
      '0';

      u_op.status_en(OVERFLOW) := '1' WHEN instruction = x"B8" ELSE
      '0';

    ELSE
      u_op := initial_op;
    END IF;

    stat_u_op <= u_op;
  END PROCESS;

  JMP_instr : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    reset(u_op);
    CASE state IS
      WHEN T2 =>
        CASE (decInstruction.addressing_mode) IS
          WHEN ABSOLUTE =>
            ------- Addressing ------- 
            address_pc(u_op);
            -------------------------- 

            increment_pc(u_op);

            u_op.alu_op := AD;
            u_op.mux_ai := s_ZERO;
            u_op.ai_en := '1';

            u_op.mux_db := s_DATA;
            u_op.mux_bi := s_DB;
            u_op.bi_en := '1';

          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;
      WHEN T3 =>
        CASE (decInstruction.addressing_mode) IS
          WHEN ABSOLUTE =>
            u_op.mux_pc := s_JMP;
            u_op.mux_db := s_DATA;
            u_op.mux_sb := s_ALU;
            u_op.pcl_en := '1';
            u_op.pch_en := '1';

          WHEN OTHERS =>
            u_op := initial_op;
        END CASE;
      WHEN OTHERS =>
        u_op := initial_op;
    END CASE;
    jmp_u_op <= u_op;
  END PROCESS;

  BRACNH_instr : PROCESS (ALL)
    VARIABLE u_op : MICRO_OPERATION := initial_op;
  BEGIN
    reset(u_op);
    CASE state IS
      WHEN T2 =>
        u_op.mux_sb := s_PCL;
        u_op.mux_ai := s_SB;
        u_op.ai_en := '1';

        u_op.mux_db := s_DATA;
        u_op.mux_bi := s_DB;
        u_op.bi_en := '1';
      WHEN T3 =>
        u_op.alu_op := AD;
        u_op.mux_sb := s_ALU;

        u_op.mux_pc := s_JMP;
        u_op.pcl_en := '1';

        u_op.mux_ai := s_ZERO;
        u_op.ai_en := '1';

        u_op.mux_db := s_PCH;
        u_op.mux_bi := s_DB;
        u_op.bi_en := '1';

        -- TODO: check if this should be added in other places
        u_op.mux_status := s_ALU;
        u_op.status_en(CARRY) := '1';
      WHEN T4 =>
        u_op.alu_op := ADC;
        u_op.mux_sb := s_ALU;
        u_op.mux_db := s_SB;
        u_op.mux_pc := s_JMP;
        u_op.pch_en := '1';

      WHEN OTHERS =>
        u_op := initial_op;
    END CASE;
    branch_u_op <= u_op;
  END PROCESS;
END behavioral;