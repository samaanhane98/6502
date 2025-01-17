----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 10:07:51 PM
-- Design Name: 
-- Module Name: cpu_tb - behavioral
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

USE work.cpu_pkg.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY cpu_tb IS
END cpu_tb;

ARCHITECTURE behavioral OF cpu_tb IS
  CONSTANT CLK_PERIOD : TIME := 1000 ns;
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC := '1';

BEGIN
  DUT : ENTITY work.cpu
    PORT MAP(
      clk => clk,
      rst => rst
    );

  CLK_GEN : PROCESS BEGIN
    WAIT FOR CLK_PERIOD / 2;
    clk <= NOT clk;
  END PROCESS;

  RST_GEN : PROCESS BEGIN
    WAIT FOR 5000 ns;
    rst <= '0';
  END PROCESS;

END behavioral;