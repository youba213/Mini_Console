----------------------------------------------------------------------------------
-- Company: 	UPMC
-- Engineer: 	Julien Denoulet
-- 
--	Gestion des Afficheurs 7 Segments
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity aff_mgr_basys is
    Port ( clk25 			: in  STD_LOGIC;								-- Horloge 25 MHz
           reset 			: in  STD_LOGIC;								-- Reset Asynchrone
           pause 			: in  STD_LOGIC;								-- Commande Pause
           master_slave	: in STD_LOGIC;								-- Selection Manette de Jeu (Encodeur / Accéléromètre)
			  game_type 	: in  STD_LOGIC;								-- Type de Jeu (Pong / Casse-Briques=
           sel_seg 		: out STD_LOGIC_VECTOR (3 downto 0); 	-- Selection de l'Afficheur
           seg 			: out STD_LOGIC_VECTOR (7 downto 0));	-- Valeur des Segments de l'Afficheur
end aff_mgr_basys;

--------------------------------------------------
-- Fonctionnement Afficheurs
--------------------------------------------------
--
--		- Segments Allumés à 0, Eteints à 1
--		- Validation
--				- SEL = 0 --> Affichage des Segments
--				- SEL = 1 --> Segments Eteints

--		- Numéro des Segments Afficheur (Point = 7)
--
--					  0
--				 --------
--				-			-
--			 5	-			- 1
--				-	  6	-
--				 --------
--				-			-
--			 4	-			- 2
--				-			-
--				 --------
--				     3
--
--------------------------------------------------


architecture Behavioral of aff_mgr_basys is

signal counter: integer range 0 to 100000; -- COmpteur de Temporisation

begin

process(clk25, reset)
      begin
      if reset = '0' then 
			counter<=0; sel_seg <= not "0000"; seg <= not "00000000";
      elsif rising_edge(clk25) then
      
			-- Gestion du Compteur
			counter <= counter + 1; 
         if (counter = 99999) then counter <= 0; end if;
   
			-- affichage de "CASSE BRI(ques)"
			case (counter) is
				
				when 00000 => sel_seg <= not "0001"; seg <= not "00111001"; --not "00111001"; --C
				when 25000 => sel_seg <= not "0010"; seg <= not "00010000"; --I
				when 50000 => sel_seg <= not "0100"; seg <= not "01010000"; --R
				when 75000 => sel_seg <= not "1000"; seg <= not "01111100"; --B
--				when 40000 => sel_seg <= not "00010000"; seg <= not "01101101"; --s
--				when 50000 => sel_seg <= not "00100000"; seg <= not "01101101"; --s
--				when 60000 => sel_seg <= not "01000000"; seg <= not "01110111"; --a
--				when 70000 => sel_seg <= not "10000000"; seg <= not "00111001"; --c

				when others => NULL;
			
			end case;    
  
			if master_slave = '0' then 
			
			-- Affichage de "MANETTE"
				case (counter) is

				    when 00000 => sel_seg <= not "0001"; seg <= not "01111000"; --T
				    when 25000 => sel_seg <= not "0010"; seg <= not "01010100"; --N
				    when 50000 => sel_seg <= not "0100"; seg <= not "01110111"; --A
				    when 75000 => sel_seg <= not "1000"; seg <= not "00110111"; --M
					
--					when 00000 => sel_seg <= not "00000001"; seg <= not "00000000"; 
--					when 10000 => sel_seg <= not "00000010"; seg <= not "01111001"; --e
--					when 20000 => sel_seg <= not "00000100"; seg <= not "01111000"; --t
--					when 30000 => sel_seg <= not "00001000"; seg <= not "01111000"; --t
--					when 40000 => sel_seg <= not "00010000"; seg <= not "01111001"; --e
--					when 50000 => sel_seg <= not "00100000"; seg <= not "01010100"; --n
--					when 60000 => sel_seg <= not "01000000"; seg <= not "01110111"; --a
--					when 70000 => sel_seg <= not "10000000"; seg <= not "00110111"; --m
      
					when others => NULL;

				end case;

			-- Affichage de "PAUSE"
			elsif pause = '1' then       
     
				case (counter) is

				    when 00000 => sel_seg <= not "0001"; seg <= not "01101101"; --S
				    when 25000 => sel_seg <= not "0010"; seg <= not "00111110"; --U
				    when 50000 => sel_seg <= not "0100"; seg <= not "01110111"; --A
				    when 75000 => sel_seg <= not "1000"; seg <= not "01110011"; --P

--					when 00000 => sel_seg <= not "00000001"; seg <= not "00000000"; 
--					when 10000 => sel_seg <= not "00000010"; seg <= not "00000000"; 
--					when 20000 => sel_seg <= not "00000100"; seg <= not "00000000"; 
--					when 30000 => sel_seg <= not "00001000"; seg <= not "01111001"; --e
--					when 40000 => sel_seg <= not "00010000"; seg <= not "01101101"; --s
--					when 50000 => sel_seg <= not "00100000"; seg <= not "00111110"; --u
--					when 60000 => sel_seg <= not "01000000"; seg <= not "01110111"; --a
--					when 70000 => sel_seg <= not "10000000"; seg <= not "01110011"; --p
      
					when others => NULL;

				end case;
 
			-- Affichage de "PONG"
			elsif game_type = '1' then       
				
				case (counter) is
				
				    when 00000 => sel_seg <= not "0001"; seg <= not "01111101"; --G
                    when 25000 => sel_seg <= not "0010"; seg <= not "00110111"; --N
                    when 50000 => sel_seg <= not "0100"; seg <= not "00111111"; --O
                    when 75000 => sel_seg <= not "1000"; seg <= not "01110011"; --P

--					when 00000 => sel_seg <= not "00000001"; seg <= not "00000000"; --
--					when 10000 => sel_seg <= not "00000010"; seg <= not "00000000"; --
--					when 20000 => sel_seg <= not "00000100"; seg <= not "00000000"; --
--					when 30000 => sel_seg <= not "00001000"; seg <= not "00000000"; --
--					when 40000 => sel_seg <= not "00010000"; seg <= not "01111101"; --g
--					when 50000 => sel_seg <= not "00100000"; seg <= not "00110111"; --n
--					when 60000 => sel_seg <= not "01000000"; seg <= not "00111111"; --o
--					when 70000 => sel_seg <= not "10000000"; seg <= not "01110011"; --p
      
					when others => NULL;

				end case;
			end if;     
		end if;
	end process;
end Behavioral;

