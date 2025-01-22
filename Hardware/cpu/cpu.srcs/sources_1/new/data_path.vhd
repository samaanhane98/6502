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
  -- -- Data register
  -- SIGNAL DATA_d, DATA_q : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

  SIGNAL status_d, status_q : STATUS := (OTHERS => '0');

  -- Program counter registers
  SIGNAL pcl_q : PCL := (OTHERS => '0');
  SIGNAL pch_q : PCH := (OTHERS => '0');
  SIGNAL pc_in : PC := (OTHERS => '0');

  -- ALU registers
  SIGNAL AI_d, BI_d, AI_q, BI_q : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Accumulator
  SIGNAL ACC_d, ACC_q : ACC := (OTHERS => '0');

  -- Adder hold register
  SIGNAL alu_res : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- X & Y registers
  SIGNAL RGX_d, RGX_q : RGX := (OTHERS => '0');

  -- Address registers
  SIGNAL ABL_d, ABL_q : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ABH_d, ABH_q : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN
  -- -- Program Counter
  PC_MUX : pc_in <= STD_LOGIC_VECTOR(unsigned(pch_q) & unsigned(pcl_q) + 1) WHEN u_operation.mux_pc = s_INCR ELSE
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

  ADDR_MUX : address <= pch_q & pcl_q WHEN u_operation.mux_addr = s_PC ELSE
  ABH_q & ABL_q WHEN u_operation.mux_addr = s_AB ELSE
  (OTHERS => '0');

  ABL_MUX : ABL_d <= data_in WHEN u_operation.mux_abl = s_DATA ELSE
  alu_res WHEN u_operation.mux_abl = s_ALU ELSE
  (OTHERS => '0');

  ABL_REGISTER : ENTITY work.bits_register GENERIC MAP (
    WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => ABL_d,
      q => ABL_q,
      ce => u_operation.abl_en
    );

  ABH_MUX : ABH_d <= data_in WHEN u_operation.mux_abh = s_DATA ELSE
  (OTHERS => '0');

  ABH_REGISTER : ENTITY work.bits_register GENERIC MAP (
    WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => ABH_d,
      q => ABH_q,
      ce => u_operation.abl_en
    );

  -- ALU Operand registers
  AI_MUX : AI_d <= ACC_q WHEN u_operation.mux_ai = s_ACC ELSE
  RGX_q WHEN u_operation.mux_ai = s_RGX ELSE
  (OTHERS => '0');

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

  BI_MUX : BI_d <= data_in WHEN u_operation.mux_bi = s_DATA ELSE
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

  -- -- X & Y registers
  -- RGX_MUX : RGX_d <= alu_res WHEN u_operation.mux_rgx = s_ALU ELSE
  -- (OTHERS => '0');

  -- X_REGISTER : ENTITY work.bits_register GENERIC MAP (
  --   WIDTH => 8,
  --   INIT_VALUE => 1
  --   )
  --   PORT MAP(
  --     clk => clk,
  --     rst => rst,
  --     d => RGX_d,
  --     q => RGX_q,
  --     ce => u_operation.rgx_en
  --   );

  -- Accumulator
  ACC_MUX : ACC_d <= alu_res WHEN u_operation.mux_acc = s_ALU ELSE
  (OTHERS => '0');

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

  -- ALU
  ALU_inst : ENTITY work.alu PORT MAP (
    clk => clk,
    rst => rst,
    operation => u_operation.alu_op,
    op_ai => AI_q,
    op_bi => BI_q,
    carry => status_q(CARRY),
    alu_res => alu_res,
    carry_out => status_d(CARRY),
    neg_out => status_d(NEGATIVE),
    zero_out => status_d(ZERO),
    overflow_out => status_d(OVERFLOW)
    );

  STATUS_REGISTER : ENTITY work.status_register PORT MAP (
    clk => clk,
    rst => rst,
    d => status_d,
    q => status_q,
    ce => u_operation.status_en
    );
END behavioral;