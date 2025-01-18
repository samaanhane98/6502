----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 10:21:05 AM
-- Design Name: 
-- Module Name: top_tb - behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY top_tb IS
  --  Port ( );
END top_tb;

ARCHITECTURE behavioral OF top_tb IS
  CONSTANT CLK_PERIOD : TIME := 1000 ns;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC := '1';

BEGIN

  DUT : ENTITY work.top
    PORT MAP(
      clk => clk,
      rst => rst
    );

  clk <= NOT clk AFTER CLK_PERIOD / 2;
  rst <= '0' AFTER 5000 ns;

END behavioral;