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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY ram IS
  PORT (
    clk : IN STD_LOGIC;
    rw : IN STD_LOGIC;
    address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_w : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    debug_acc : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END ram;

ARCHITECTURE Behavioral OF ram IS
  SIGNAL memory : MEMORY(0 TO 63) := (0 => x"69", 1 => x"01", 2 => x"8D", 3 => x"10", 4 => x"00", 5 => x"4C", 6 => x"00", 7 => x"00", 16 => x"00", OTHERS => (OTHERS => '0'));

BEGIN

  RAM_WR : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      IF rw = '1' THEN
        memory(to_integer(unsigned(address))) <= data_w;
      END IF;
      data_r <= memory(to_integer(unsigned(address)));
    END IF;
  END PROCESS;

  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      debug_acc <= memory(16)(3 DOWNTO 0);
    END IF;

  END PROCESS;
END Behavioral;