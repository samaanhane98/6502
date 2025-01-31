----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2025 09:03:21 PM
-- Design Name: 
-- Module Name: clock_buffer - Behavioral
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
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY clock_buffer IS
   PORT (
      clk_in : IN STD_LOGIC;
      clk_out : OUT STD_LOGIC;
      enable : IN STD_LOGIC
   );
END clock_buffer;

ARCHITECTURE Behavioral OF clock_buffer IS
BEGIN

   BUFGCE_inst : BUFGCE

   PORT MAP(
      O => clk_out, -- 1-bit output: Clock output
      CE => enable, -- 1-bit input: Clock enable input for I0
      I => clk_in -- 1-bit input: Primary clock
   );

END Behavioral;