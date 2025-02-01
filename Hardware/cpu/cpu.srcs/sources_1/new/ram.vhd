----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2025 08:33:02 PM
-- Design Name: 
-- Module Name: ram - Behavioral
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
USE IEEE.NUMERIC_STD.ALL;

ENTITY ram IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    rw : IN STD_LOGIC;
    address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_w : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END ram;

ARCHITECTURE Behavioral OF ram IS
  SIGNAL memory : MEMORY(0 TO 511) := (0 => x"02", 200 => x"38", 201 => x"69", 202 => x"01", 203 => x"4C", 204 => x"C8", 205 => x"00", OTHERS => (OTHERS => '0'));

BEGIN

  RAM_WR : PROCESS (clk, rst)
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        data_r <= (OTHERS => '0');
      ELSE
        IF rw = '1' THEN
          memory(to_integer(unsigned(address))) <= data_w;
        ELSE
          data_r <= memory(to_integer(unsigned(address)));
        END IF;

      END IF;
    END IF;
  END PROCESS;

END Behavioral;