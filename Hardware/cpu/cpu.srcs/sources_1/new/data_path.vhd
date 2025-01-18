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
    address : OUT AD
  );
END data_path;

ARCHITECTURE behavioral OF data_path IS
  -- Busses
  SIGNAL adh : ADH;
  SIGNAL adl : ADL;

  -- Dedicated Registers
  SIGNAL rPCL : PCL := (OTHERS => '0');
  SIGNAL rPCH : PCH := (OTHERS => '0');
  SIGNAL rACC : ACC := (OTHERS => '0');
  SIGNAL rX : RGX := (OTHERS => '0');
  SIGNAL rY : RGY := (OTHERS => '0');

  SIGNAL status : STATUS := (OTHERS => '0');

BEGIN
  -- address <= ABH & ABL;

  -- ABL_MUX : rABL <= rPCL WHEN u_operation.mux_abl = "00" ELSE
  -- (OTHERS => '0');

  -- ABH_MUX : rABH <= rPCH WHEN u_operation.mux_abh = "00" ELSE
  -- (OTHERS => '0');
END behavioral;