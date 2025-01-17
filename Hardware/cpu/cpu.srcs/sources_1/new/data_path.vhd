----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/17/2025 10:37:33 PM
-- Design Name: 
-- Module Name: data_path - behavioral
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

ENTITY data_path IS
  PORT (
    n_clk : IN STD_LOGIC;
    data_in : IN DB;
    data_out : OUT DB;
    RW_out : OUT RW;
    address : OUT AB
    -- abl : IN ABL;
    -- abh : IN ABH;
    -- data_bus : OUT DB
  );
END data_path;

ARCHITECTURE behavioral OF data_path IS

BEGIN
  -- DATA_FETCH : PROCESS (n_clk)
  --   VARIABLE address : AB;
  -- BEGIN
  --   IF rising_edge(n_clk) THEN
  --     address := abh & abl;
  --     data_bus <= memory(to_integer(unsigned(address)));
  --   END IF;
  -- END PROCESS;
END behavioral;