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
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    u_operation : IN MICRO_OPERATION;
    data_in : IN DB;
    data_out : OUT DB;
    address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END data_path;

ARCHITECTURE behavioral OF data_path IS
  -- Instruction register
  SIGNAL IR_q : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Program counter registers
  SIGNAL pcl_q : PCL := (OTHERS => '0');
  SIGNAL pch_q : PCH := (OTHERS => '0');
  SIGNAL pc_in : PC := (OTHERS => '0');

  -- ALU registers
  SIGNAL AI_d, BI_d, AI_q, BI_q : STD_LOGIC_VECTOR(7 DOWNTO 0);

  -- Address registers
  SIGNAL abl : ABL := (OTHERS => '0');
  SIGNAL abh : ABH := (OTHERS => '0');
BEGIN
  -- Instruction Register
  IR_REGISTER : ENTITY work.bits_register GENERIC MAP (
    WIDTH => 8
    ) PORT MAP (
    clk => clk,
    rst => rst,
    d => data_in,
    q => IR_q,
    ce => u_operation.ir_en
    );

  -- Program Counter
  PCL_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8
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
      WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      d => pc_in(15 DOWNTO 8),
      q => PCH_q,
      ce => u_operation.pch_en
    );

  PC_MUX : pc_in <= STD_LOGIC_VECTOR(unsigned(pch_q) & unsigned(pcl_q) + 1) WHEN u_operation.mux_pc = "00" ELSE
  (OTHERS => '0');

  -- Addressing
  address <= abh & abl;

  ABL_MUX : abl <= pcl_q WHEN u_operation.mux_abl = "00" ELSE
  (OTHERS => '0');

  ABH_MUX : abh <= pch_q WHEN u_operation.mux_abh = "00" ELSE
  (OTHERS => '0');

  -- ALU
  AI_MUX : AI_d <= x"05";
  BI_MUX : BI_d <= x"02";

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

  -- ALU_inst : ENTITY work.alu PORT MAP (
  --   clk => clk,
  --   rst => rst,
  --   operation

  --   -- operation : IN ALU_OPERATION;
  --   -- op_ai : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  --   -- op_bi : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  --   -- alu_en : IN STD_LOGIC;
  --   -- carry : IN STD_LOGIC;
  --   -- alu_res : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  --   );

END behavioral;