----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 06:59:57 PM
-- Design Name: 
-- Module Name: bits_register - behavioral
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
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- https://github.com/bernardo-andreeti/6502/blob/master/VHDL/P6502/RegisterNbits.vhd
ENTITY bits_register IS
  GENERIC (
    WIDTH : INTEGER := 32;
    INIT_VALUE : INTEGER := 0
  );
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    d : IN STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0);
    q : OUT STD_LOGIC_VECTOR (WIDTH - 1 DOWNTO 0)
  );
END bits_register;

ARCHITECTURE behavioral OF bits_register IS

BEGIN

  PROCESS (clk, rst)
  BEGIN
    IF rising_edge(clk) THEN
      IF ce = '1' THEN
        q <= d;
      END IF;
    END IF;
    IF rst = '1' THEN
      q <= STD_LOGIC_VECTOR(TO_UNSIGNED(INIT_VALUE, WIDTH));
    END IF;
  END PROCESS;
END behavioral;