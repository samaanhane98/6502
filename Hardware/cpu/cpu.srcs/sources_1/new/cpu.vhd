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
    PC_INIT : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0')
  );
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    rw_out : OUT STD_LOGIC;
    debug_acc_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END cpu;

ARCHITECTURE behavioral OF cpu IS
  SIGNAL u_operation : MICRO_OPERATION;

  SIGNAL n_clk : STD_LOGIC;
BEGIN
  rw_out <= u_operation.wr_mem;
  n_clk <= NOT clk;

  data_path_inst : ENTITY work.data_path
    GENERIC MAP(

      PC_INIT => PC_INIT
    )
    PORT MAP(
      clk => n_clk,
      rst => rst,
      u_operation => u_operation,
      data_in => data_in,
      data_out => data_out,
      address => address,
      debug_acc_out => debug_acc_out
    );

  control_path_inst : ENTITY work.control_path PORT MAP (
    clk => clk,
    rst => rst,
    u_operation => u_operation,
    instruction => data_in
    );
END behavioral;