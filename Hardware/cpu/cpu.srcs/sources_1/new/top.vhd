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
    rst : IN STD_LOGIC;
    address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_w : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_r : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    rw : OUT STD_LOGIC;
    debug_acc_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END top;

ARCHITECTURE behavioral OF top IS
  SIGNAL tmp_clk : STD_LOGIC_VECTOR(20 DOWNTO 0);

  SIGNAL cpu_dbg : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
  debug_acc_out <= cpu_dbg(3 DOWNTO 0);

  cpu_inst : ENTITY work.cpu
    GENERIC MAP(
      PC_INIT => x"00C8"
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      data_in => data_r,
      data_out => data_w,
      address => address,
      RW_out => rw,
      debug_acc_out => cpu_dbg
    );
END behavioral;