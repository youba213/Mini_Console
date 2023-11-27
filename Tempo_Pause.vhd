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

entity Tempo_Pause is
  Port ( clk,reset,update_tempo_pause,raz_tempo_pause: in std_logic;
        fin_tempo_pause: out std_logic);
end Tempo_Pause;

architecture Behavioral of Tempo_Pause is
signal compteur : std_logic_vector(9 downto 0);
begin
process(clk,reset)
	 begin
	 if reset='0' then compteur<=(others =>'0'); Fin_Tempo_Pause<='0';
	 elsif rising_edge(clk) then
	 
		if RAZ_Tempo_Pause='1' then compteur<=(others =>'0');
		elsif Update_Tempo_Pause='0' then compteur<=compteur;
		else compteur<=compteur+1;
		end if;
		
		if (compteur="1111111111") then Fin_Tempo_Pause <= '1' ;else Fin_Tempo_Pause <= '0'; end if;
	
		
	end if;
end process ;



end Behavioral;
