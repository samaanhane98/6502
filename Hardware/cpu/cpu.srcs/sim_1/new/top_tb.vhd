----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 10:21:05 AM
-- Design Name: 
-- Module Name: top_tb - behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY top_tb IS
  --  Port ( );
END top_tb;

ARCHITECTURE behavioral OF top_tb IS
  CONSTANT CLK_PERIOD : TIME := 1000 ns;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC := '1';
  SIGNAL debug_led : STD_LOGIC := '1';

  SIGNAL rw : STD_LOGIC;
  SIGNAL address : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL data_w, data_r : STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL debug_acc : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

  ram_inst : ENTITY work.ram
    PORT MAP(
      clk => clk,
      rw => rw,
      address => address,
      data_w => data_w,
      data_r => data_r,
      debug_acc => debug_acc
    );

  top_inst : ENTITY work.top
    PORT MAP(
      clk => clk,
      rst => rst,
      address => address,
      data_w => data_w,
      data_r => data_r,
      rw => rw
    );

  clk <= NOT clk AFTER CLK_PERIOD / 2;
  rst <= '0' AFTER 2000 ns;

END behavioral;