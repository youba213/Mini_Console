----------------------------------------------------------------------------------
-- Company: 	UPMC
-- Engineer: 	Julien Denoulet
-- 
--	Selection du Type de Jeu
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity game_mgr is
    Port ( clk25 : in  STD_LOGIC;			-- Horloge 25 MHz
           reset : in  STD_LOGIC;			-- Reset Asynchrone
           game_rqt : in  STD_LOGIC;		-- Demande de Changement de Jeu
           game_type : out  STD_LOGIC);	-- Type de Jeu (0 = Casse Briques / 1 = Pong)
end game_mgr;

architecture Behavioral of game_mgr is

-- Etats de la ME
type etat is (BRICK, CHANGE_2_PONG, PONG, CHANGE_2_BRICK);

signal EP, EF: etat;	-- Signaux d'Etat Present et Futur

begin


	-- REGISTRE D'ETAT DE LA MAE
	process(clk25,reset)
	
	begin
	
		if reset = '0' then
			EP <= BRICK;
		elsif rising_edge(clk25) then
			EP <= EF;
		end if;
	
	end process;


	-- EVOLUTION DE LA MAE
	process(EP,game_rqt)
	
	begin
	
		case (EP) is
		
			-- Dans l'etat BRICK
				-- Le Jeu Est Casse Briques
				-- Tant qu'On N'A Pas de Demande de Changement
			when BRICK 				=>	game_type <= '0'; EF <= BRICK;
											if game_rqt = '1' then
												EF <= CHANGE_2_PONG;
											end if;

			-- Dans l'etat CHANGE_2_PONG
				-- Le Jeu Est Pong
				-- On Reste dans l'Etat Tant que la Requete de Changement Est Maintenue
			when CHANGE_2_PONG 	=> game_type <= '1'; EF <= CHANGE_2_PONG;
											if game_rqt = '0' then
												EF <= PONG;
											end if;

			-- Dans l'etat PONG
				-- Le Jeu Est Pong
				-- Tant qu'On N'A Pas de Demande de Changement
			when PONG 				=> game_type <= '1'; EF <= PONG;
											if game_rqt = '1' then
												EF <= CHANGE_2_BRICK;
											end if;

			-- Dans l'etat CHANGE_2_PONG
				-- Le Jeu Est Casse Briques
				-- On Reste dans l'Etat Tant que la Requete de Changement Est Maintenue
			when CHANGE_2_BRICK 	=> game_type <= '0'; EF <= CHANGE_2_BRICK;
											if game_rqt = '0' then
												EF <= BRICK;
											end if;

		end case;
	end process;


end Behavioral;

