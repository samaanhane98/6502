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
  SIGNAL memory : MEMORY(0 TO 65534) := (0 => x"69", 1 => x"01", OTHERS => (OTHERS => '0'));

  SIGNAL data_in : DB;
  SIGNAL data_out : DB;
  SIGNAL address : AD;
  SIGNAL rw : RW;

BEGIN
  -- n_clk <= NOT clk;

  RW_OPERATION : PROCESS (clk) BEGIN
    IF rising_edge(clk) THEN
      CASE (rw) IS
        WHEN READ_ENABLE =>
          data_in <= memory(to_integer(unsigned(address)));
        WHEN WRITE_ENABLE =>
          memory(to_integer(unsigned(address))) <= data_out;
      END CASE;
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