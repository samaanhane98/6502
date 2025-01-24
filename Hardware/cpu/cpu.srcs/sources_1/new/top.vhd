----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 11:03:06 PM
-- Design Name: 
-- Module Name: top - behavioral
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

ENTITY top IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC
  );
END top;

ARCHITECTURE behavioral OF top IS
  SIGNAL memory : MEMORY(0 TO 65534) := (0 => x"69", 1 => x"05", OTHERS => (OTHERS => '0'));
  -- SIGNAL memory : MEMORY(0 TO 65534) := (0 => x"65", 1 => x"05", 5 => x"AB", OTHERS => (OTHERS => '0'));
  -- SIGNAL memory : MEMORY(0 TO 65534) := (0 => x"75", 1 => x"04", 5 => x"AB", OTHERS => (OTHERS => '0'));
  -- SIGNAL memory : MEMORY(0 TO 65534) := (0 => x"6D", 1 => x"01", 2 => x"01", 257 => x"AA", OTHERS => (OTHERS => '0'));
  SIGNAL data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL address : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL rw : RW;

BEGIN
  PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      data_in <= memory(to_integer(unsigned(address)));
    END IF;
  END PROCESS;

  cpu_inst : ENTITY work.cpu
    GENERIC MAP(
      PC_INIT => x"0000"
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      data_in => data_in,
      data_out => data_out,
      address => address,
      RW_out => rw
    );
END behavioral;