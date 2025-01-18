----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 09:59:19 PM
-- Design Name: 
-- Module Name: alu - behavioral
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

ENTITY alu IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    operation : IN ALU_OPERATION;
    op_ai : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    op_bi : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    alu_en : IN STD_LOGIC;
    carry : IN STD_LOGIC;
    alu_res : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END alu;

ARCHITECTURE behavioral OF alu IS
  SIGNAL add_d, add_q : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
  alu_res <= add_q;

  ADD_REGISTER : ENTITY work.bits_register
    GENERIC MAP(
      WIDTH => 8
    )
    PORT MAP(
      clk => clk,
      rst => rst,
      ce => alu_en,
      d => add_d,
      q => add_q
    );

  PROCESS (operation, op_ai, op_bi, carry) BEGIN
    CASE (operation) IS
      WHEN ADC =>
        add_d <= STD_LOGIC_VECTOR(unsigned(op_ai) + unsigned(op_bi)); -- TODO: fix carry
    END CASE;

  END PROCESS;
END behavioral;