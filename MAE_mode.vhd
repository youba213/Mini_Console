-------- vesion 2 ----------------------

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.11.2022 19:50:42
-- Design Name: 
-- Module Name: mode - Behavioral
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

entity MAE_mode is
    port ( 
         clk, reset, pause_Rqt, Endframe, Lost, No_Brick, fin_tempo_pause : in std_logic;
         Brick_Win,Pause,raz_tempo_pause,load_timer_lost,update_timer_lost,update_tempo_pause: out std_logic;
         Timer_Lost: in std_logic_vector(5 downto 0));
end MAE_mode;

architecture Behavioral of MAE_mode is
type etat is (S0,S1,S2,S3,S4,S5,S6);
signal EP,EF: etat;
signal Sortie: std_logic_vector(5 downto 0);
--signal red_out,green_out,blue_out:std_logic_vector(3 downto 0);
begin



-----------------------------------   Registre d'etats   -------------------------------    
    process(clk,reset)
        begin
        if reset='0' then EP <= S0;
        elsif rising_edge(clk) then EP <= EF;
        end if;
    end process;
------------------------------------   COMBINATOIR DES ETATS  --------------------------------------------------
process(EP,pause_Rqt,Endframe,Lost,No_Brick,fin_tempo_pause,timer_lost)
begin
    case (EP) is
        when S0 => EF <= S0 ; if (pause_rqt ='1') then   EF<= S1 ;  elsif (timer_lost > "000000" and Endframe ='1') then EF<= S5 ;end if;
		when S1 => EF <= S1 ; if (fin_tempo_pause='1' and  pause_rqt='0') then EF <= S2; end if;   
		when S2 => EF <= S2 ; if (No_brick = '1') then EF <= S4; elsif ( pause_rqt='1') then EF<= S6;elsif (lost = '1') then EF <= S3 ; end if ; 
		when S3 => EF <= S0 ; 
		when S4 => EF <= S4;  
		when S5 => EF <= S0 ; 
		when S6 => EF <= S6; if (fin_tempo_pause='1' and  pause_rqt='0') then EF<=S0; end if ;
        

    end case;
end process;
----------------------------------- COMBINATOIR DES SORTIES --------------------------------------------------
process(EP)
begin
    case (EP) is
			when S0 => sortie <= "011000";
			when S1 => sortie <= "000100";
			when S2 => sortie <= "001000";
			when S3 => sortie <= "000010";
			when S4 => sortie <= "100000";
			when S5 => sortie <= "010001";
			when S6 => sortie <= "010100";

    end case;
end process;
-----------------------------------------------------------------------------------------------------------------

Brick_Win<=Sortie(5);
Pause<=Sortie(4);
raz_tempo_pause<=Sortie(3);
update_tempo_pause<=Sortie(2);
load_timer_lost<=Sortie(1);
update_timer_lost<=Sortie(0);

end Behavioral;