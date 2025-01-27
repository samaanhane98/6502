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
    carry : IN INTEGER;
    alu_res : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Status signals
    carry_out : OUT STD_LOGIC;
    neg_out : OUT STD_LOGIC;
    zero_out : OUT STD_LOGIC;
    overflow_out : OUT STD_LOGIC
  );
END alu;

ARCHITECTURE behavioral OF alu IS
  SIGNAL tmp_result : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');
BEGIN

  alu_res <= tmp_result(7 DOWNTO 0);

  -- Status symbols
  overflow_out <= '0'; -- TODO
  carry_out <= tmp_result(8) WHEN operation = ADC ELSE
    '0';

  zero_out <= '1' WHEN tmp_result(7 DOWNTO 0) = "00000000" ELSE
    '0';
  neg_out <= '1' WHEN tmp_result(7) = '1' ELSE
    '0';

  PROCESS (ALL)
  BEGIN
    CASE (operation) IS
      WHEN ADC =>
        tmp_result <= "0" & STD_LOGIC_VECTOR(unsigned(op_ai) + unsigned(op_bi) + carry);
      WHEN AD =>
        tmp_result <= "0" & STD_LOGIC_VECTOR(unsigned(op_ai) + unsigned(op_bi));
      WHEN AD_INC =>
        tmp_result <= "0" & STD_LOGIC_VECTOR(unsigned(op_ai) + unsigned(op_bi) + 1);

      WHEN OTHERS =>
    END CASE;
  END PROCESS;
END behavioral;