----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2025 10:42:15 AM
-- Design Name: 
-- Module Name: control_path - behavioral
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

ENTITY control_path IS
  PORT (
    clk : IN STD_LOGIC;
    u_operation : OUT MICRO_OPERATION
  );

END control_path;

ARCHITECTURE behavioral OF control_path IS
  SIGNAL state, next_state : CPU_STATE := T0;

BEGIN
  STATE_MACHINE : PROCESS (clk)
    VARIABLE u_op : MICRO_OPERATION;
  BEGIN
    IF rising_edge(clk) THEN
      CASE state IS
        WHEN T0 =>
          u_op.wr_mem := READ_ENABLE;
          u_op.mux_abl := "00";
          u_op.mux_abh := "00";
          u_op.mux_pc := "01";
          next_state <= T1;
        WHEN OTHERS =>
      END CASE;

      state <= next_state;
      u_operation <= u_op;
    END IF;
  END PROCESS;
END behavioral;