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
    n_clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    u_operation : IN MICRO_OPERATION;
    data_in : IN DB;
    data_out : OUT DB;
    address : OUT AB
  );
END data_path;

ARCHITECTURE behavioral OF data_path IS
  -- Registers
  SIGNAL rPC : PC := (OTHERS => '0');
  SIGNAL rACC : ACC := (OTHERS => '0');
  SIGNAL rX : RGX := (OTHERS => '0');
  SIGNAL rY : RGY := (OTHERS => '0');
  SIGNAL rABL : ABL := (OTHERS => '0');
  SIGNAL rABH : ABH := (OTHERS => '0');
  SIGNAL status : STATUS := (OTHERS => '0');

  -- Latches
  SIGNAL newPC : PC;
  SIGNAL alu : ALU;
BEGIN
  address <= rABH & rABL;
  rPC <= newPC;

  ABL_SELECT : WITH u_operation.mux_abl SELECT rABL <=
  rPC(7 DOWNTO 0) WHEN "00",
  "00000000" WHEN OTHERS;

  ABH_SELECT : WITH u_operation.mux_abh SELECT rABH <=
  rPC(15 DOWNTO 8) WHEN "00",
  (OTHERS => '0') WHEN OTHERS;

  NEWPC_SELECT : WITH u_operation.mux_pc SELECT newPC <=
  rPC WHEN "00",
  STD_LOGIC_VECTOR(unsigned(rPC) + 1) WHEN "01",
  (OTHERS => '0') WHEN OTHERS;

END behavioral;