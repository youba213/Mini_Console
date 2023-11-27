----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.11.2022 23:43:17
-- Design Name: 
-- Module Name: MAE_mode - Behavioral
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Timer_Lost is
          Port ( clk,reset,load_timer_lost,update_timer_lost: in std_logic;
                Game_Lost: out std_logic;
                Timer_Lost: out std_logic_vector(5 downto 0));
end Timer_Lost;

architecture Behavioral of Timer_Lost is
signal count: std_logic_vector(5 downto 0);
begin
process(clk,reset)
	 begin
	 if reset='0' then count<=(others =>'0');
	 elsif rising_edge(clk) then
	 
		if Load_Timer_Lost='1' then count<="111111";
		elsif update_timer_lost='0' then count<=count;
		else count<=count-1;
		end if;
		
		end if;
		
end process; 

Game_Lost <= '0' when (count="000000") else '1';

Timer_Lost<=count;


end Behavioral;
