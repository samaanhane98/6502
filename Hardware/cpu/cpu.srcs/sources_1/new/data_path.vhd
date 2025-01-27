----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 10:37:33 PM
-- Design Name: 
-- Module Name: data_path - behavioral
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

ENTITY data_path IS
  GENERIC (
    PC_INIT : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0') -- First instruction address
  );
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    u_operation : IN MICRO_OPERATION;
    data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END data_path;

ARCHITECTURE behavioral OF data_path IS
  SIGNAL PC_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL PCL_q, PCH_q : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- BUSSES
  SIGNAL ADL, ADH, DB, SB : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- REGISTERS
  SIGNAL AI_q, AI_d, BI_q, BI_d, ACC_q, ACC_d, RGX_q, RGX_d, RGY_q, RGY_d, ABL_q, ABH_q : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL MA_q, MA_d : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL carry_in : INTEGER;
  SIGNAL alu_res : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL status_q, status_d : STATUS;

  SIGNAL status_alu : STATUS;
  SIGNAL status_data_in : STATUS;
BEGIN
  -- Addressing
  ADDRESS_MUX : address <= MA_q WHEN u_operation.mux_addr = s_MA ELSE
  ABH_q & ABL_q WHEN u_operation.mux_addr = s_AB;

  -- Buses
  MUX_DB : DB <= data_in WHEN u_operation.mux_db = s_DATA ELSE
  ACC_q WHEN u_operation.mux_db = s_ACC ELSE
  PCL_q WHEN u_operation.mux_db = s_PCL ELSE
  PCH_q WHEN u_operation.mux_db = s_PCH ELSE
  SB WHEN u_operation.mux_db = s_SB;

  MUX_SB : SB <= alu_res WHEN u_operation.mux_sb = s_ALU ELSE
  RGX_q WHEN u_operation.mux_sb = s_RGX ELSE
  RGY_q WHEN u_operation.mux_sb = s_RGY ELSE
  ACC_q WHEN u_operation.mux_sb = s_ACC ELSE
  ADH WHEN u_operation.mux_sb = s_ADH ELSE
  DB WHEN u_operation.mux_sb = s_DB;

  ADL_MUX : ADL <= PCL_q WHEN u_operation.mux_adl = s_PC ELSE
  alu_res WHEN u_operation.mux_adl = s_ALU ELSE
  data_in WHEN u_operation.mux_adl = s_DATA ELSE
  (OTHERS => '0');

  ADH_MUX : ADH <= PCH_q WHEN u_operation.mux_adh = s_PC ELSE
  alu_res WHEN u_operation.mux_adh = s_ALU ELSE
  data_in WHEN u_operation.mux_adh = s_DATA ELSE
  (OTHERS => '0');
  -- ALU
  carry_in <= 1 WHEN status_q(CARRY) = '1' ELSE
    0;
  ALU_inst : ENTITY work.alu PORT MAP (
    clk => clk,
    rst => rst,
    operation => u_operation.alu_op,
    op_ai => AI_q,
    op_bi => BI_q,
    carry => carry_in,
    alu_res => alu_res,
    carry_out => status_alu(CARRY),
    neg_out => status_alu(NEGATIVE),
    zero_out => status_alu(ZERO),
    overflow_out => status_alu(OVERFLOW)
    );

  -- REGISTERS
  MA_MUX : MA_d <= PCH_q & PCL_q WHEN u_operation.mux_ma = s_PC ELSE
  x"00" & alu_res WHEN u_operation.mux_ma = s_ALU ELSE
  x"00" & data_in WHEN u_operation.mux_ma = s_DATA;

  MA_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 16
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => MA_d,
      q => MA_q,
      ce => u_operation.ma_en
    );

  PC_MUX : PC_in <= STD_LOGIC_VECTOR(unsigned(pch_q) & unsigned(pcl_q) + 1) WHEN u_operation.mux_pc = s_INCR ELSE
  (OTHERS => '0');
  PCL_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8,
      INIT_VALUE => to_integer(PC_INIT(7 DOWNTO 0))
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => pc_in(7 DOWNTO 0),
      q => PCL_q,
      ce => u_operation.pcl_en
    );

  PCH_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8,
      INIT_VALUE => to_integer(PC_INIT(15 DOWNTO 8))
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => pc_in(15 DOWNTO 8),
      q => PCH_q,
      ce => u_operation.pch_en
    );

  ABL_REGISTER : ENTITY work.bits_register GENERIC MAP (
    WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => ADL,
      q => ABL_q,
      ce => u_operation.abl_en
    );

  ABH_REGISTER : ENTITY work.bits_register GENERIC MAP (
    WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => ADH,
      q => ABH_q,
      ce => u_operation.abh_en
    );

  AI_MUX : AI_d <= SB WHEN u_operation.mux_ai = s_SB ELSE
  (OTHERS => '0') WHEN u_operation.mux_ai = s_ZERO;

  AI_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => AI_d,
      q => AI_q,
      ce => u_operation.ai_en
    );

  BI_MUX : BI_d <= DB WHEN u_operation.mux_bi = s_DB ELSE
  (OTHERS => '0');

  BI_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => BI_d,
      q => BI_q,
      ce => u_operation.bi_en
    );

  RGX_MUX : RGX_d <= x"00";

  RGX_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => RGX_d,
      q => RGX_q,
      ce => '1'
    );

  RGY_MUX : RGY_d <= x"00";

  RGY_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => RGY_d,
      q => RGY_q,
      ce => '1'
    );

  ACC_MUX : ACC_d <= SB WHEN u_operation.mux_acc = s_SB ELSE
  DB WHEN u_operation.mux_acc = s_DB;

  ACC_REGISTER : ENTITY work.bits_register GENERIC MAP (
    WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => ACC_d,
      q => ACC_q,
      ce => u_operation.acc_en
    );

  status_data_in(ZERO) <= '1' WHEN data_in = x"00" ELSE
  '0';
  status_data_in(NEGATIVE) <= '1' WHEN data_in(7) = '1' ELSE
  '0';

  status_d(CARRY) <= status_alu(CARRY);
  status_d(ZERO) <= status_alu(ZERO) WHEN u_operation.mux_status = s_ALU ELSE
  status_data_in(ZERO);
  status_d(INTERRUPT) <= '0';
  status_d(DECIMAL) <= '0';
  status_d(BREAKF) <= '0';
  status_d(UNUSED) <= '1';
  status_d(OVERFLOW) <= status_alu(OVERFLOW);
  status_d(NEGATIVE) <= status_alu(NEGATIVE) WHEN u_operation.mux_status = s_ALU ELSE
  status_data_in(NEGATIVE);

  STATUS_REGISTER : ENTITY work.status_register PORT MAP (
    clk => clk,
    rst => rst,
    d => status_d,
    q => status_q,
    ce => u_operation.status_en
    );
END behavioral;