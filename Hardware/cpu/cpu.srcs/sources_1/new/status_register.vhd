----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2025 11:20:48 PM
-- Design Name: 
-- Module Name: status_register - behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY status_register IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ce : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    d : IN STATUS;
    q : OUT STATUS
  );
END status_register;

ARCHITECTURE behavioral OF status_register IS

BEGIN

  PROCESS (clk, rst)
  BEGIN
    IF rising_edge(clk) THEN
      FOR i IN 0 TO 7 LOOP
        IF ce(i) = '1' THEN
          q(i) <= d(i);
        END IF;
      END LOOP;
    END IF;

    IF rst = '1' THEN
      q <= (OTHERS => '0');
    END IF;
  END PROCESS;
END behavioral;