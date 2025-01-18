----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 09:24:00 PM
-- Design Name: 
-- Module Name: cpu - behavioral
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

ENTITY cpu IS
  GENERIC (
    PC_INIT : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
  );
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    data_in : IN DB;
    data_out : OUT DB;
    address : OUT AB;
    rw_out : OUT RW
  );
END cpu;

ARCHITECTURE behavioral OF cpu IS
  SIGNAL n_clk : STD_LOGIC;
  SIGNAL u_operation : MICRO_OPERATION;

BEGIN
  n_clk <= NOT clk;
  rw_out <= u_operation.wr_mem;

  data_path_inst : ENTITY work.data_path
    PORT MAP(
      n_clk => n_clk,
      rst => rst,
      u_operation => u_operation,
      data_in => data_in,
      data_out => data_out,
      address => address
    );

  control_path_inst : ENTITY work.control_path PORT MAP (
    clk => clk,
    u_operation => u_operation
    );
END behavioral;