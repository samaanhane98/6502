----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2025 09:03:21 PM
-- Design Name: 
-- Module Name: clock_buffer - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clock_buffer is
  Port (
  clk_in: in std_logic;
  clk_out: out std_logic;
  enable: in std_logic
   );
end clock_buffer;

architecture Behavioral of clock_buffer is
begin

BUFGCE_inst : BUFGCE
generic map (
   CE_TYPE => "SYNC",               -- ASYNC, HARDSYNC, SYNC
   IS_CE_INVERTED => '0',           -- Programmable inversion on CE
   IS_I_INVERTED => '0',            -- Programmable inversion on I
   SIM_DEVICE => "ULTRASCALE"  -- ULTRASCALE, ULTRASCALE_PLUS
)
port map (
   O => clk_out,   -- 1-bit output: Buffer
   CE => enable, -- 1-bit input: Buffer enable
   I => clk_in    -- 1-bit input: Buffer
);

end Behavioral;
