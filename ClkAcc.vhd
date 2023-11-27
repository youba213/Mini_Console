----------------------------------------------------------------------------------
-- Company: UPMC
-- Engineer: Julien Denoulet
-- 
-- Diviseur d'Horloge : 100 MHz --> 25 MHz et 25 Hz
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClkAcc is
    Port ( clk100,reset : in  STD_LOGIC;	-- Horloge 100 Mhz et Reset Asynchrone
			  clk_acc: out STD_LOGIC);			-- Horloge 25 Hz (pour Traiter les Commandes de l'Accéléromètre)
end ClkAcc;

architecture Behavioral of ClkAcc is

-- Compteur pour Horloge 25 Hz
signal CPT_25: std_logic_vector(20 downto 0);

-- Signal Tampon pour l'horloge 25 Hz
signal Clk2: std_logic;


begin

-- Affectation Horloge 25 Hz
Clk_Acc <= Clk2;


--------------------------------------------
-- GESTION DES COMPTEURS DE DIVISION
--		ET GENERATION DE L'HORLOGE 25 Hz
process(clk100,reset)

	begin
	
		if reset = '0' then 
		
			Clk2 <= '0'; CPT_25 <= (others => '0');

		elsif rising_edge(clk100) then
			
			CPT_25 <= CPT_25+1;
			
			if (CPT_25 = 1999999) then
				CPT_25 <= (others => '0');
				Clk2 <= not Clk2;
			end if;
			
		end if;

end process;
	

end Behavioral;
