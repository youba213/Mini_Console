----------------------------------------------------------------------------------
-- Company: UPMC
-- Engineer: Julien Denoulet
-- 
--	Génération des Commandes de Déplacement de l'Accéléromètre
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity accelero_mgr is
    Port ( clk25 : 			in  STD_LOGIC;		-- Horloge
           reset : 			in  STD_LOGIC;		-- Reset
           SCLK : 			out STD_LOGIC;		-- Interface SPI: Clock
           SDO : 				out STD_LOGIC;		-- Interface SPI: Data Output
           sdI : 				in  STD_LOGIC;		-- Interface SPI: Data Input
           SS : 				out STD_LOGIC;		-- Interface SPI: Slave Select
			  own_acc_left:	out STD_LOGIC;		-- Commande de Déplacement à Gauche
			  own_acc_right: 	out STD_LOGIC		-- Commande de Déplacement à Droite
			  );
end accelero_mgr;

architecture Behavioral of accelero_mgr is

signal xAxis : STD_LOGIC_VECTOR(11 downto 0);		-- Axe X de l'Accéléromètre
signal yAxis : STD_LOGIC_VECTOR(11 downto 0);		-- Axe Y de l'Accéléromètre
signal zAxis : STD_LOGIC_VECTOR(11 downto 0);		-- Axe Z de l'Accéléromètre
signal tmpAxis : STD_LOGIC_VECTOR(11 downto 0);		-- Température du Capteur
signal Data_Ready : std_logic;							-- Nouvelles Données en Sortie du Capteur

begin


	-- GESTION ACCELEROMETRE
	accelero : entity work.ADXL362Ctrl(Behavioral) 
	
			port map( 
				SYSCLK => clk25,				-- Horloge
				RESET => RESET,				-- Reset

             -- Accelerometer data signals
				ACCEL_X 		=> xAxis,		-- Axe X de l'Accéléromètre
				ACCEL_Y  	=> yAxis,		-- Axe Y de l'Accéléromètre
				ACCEL_Z  	=> zAxis,		-- Axe Z de l'Accéléromètre
				ACCEL_TMP 	=> tmpAxis,		-- Température du Capteur
				Data_Ready	=> Data_Ready,	-- Nouvelle Donnée Disponible

                --SPI Interface Signals
				SCLK      	=> SCLK,			-- Serial Clock
				MOSI     	=> SDO,			-- Data Output
				MISO     	=> SDI,			-- Data Input
				SS      		=> SS				-- Slave Select
         );


	-- TRAITEMENT DES SIGNAUX DE L'ACCELEROMETRE
	--		GENERATION DES COMMANDES DE DEPLACEMENT
   process(clk25,reset) is
		begin
			
			if (reset = '0') then
				
				own_acc_left <= '0'; own_acc_right <= '0';
			
			elsif rising_edge(clk25) then
			
				if ((((yAxis(11) and yAxis(10) and yAxis(9)) = '1') and (yAxis(8) = '0')) or
					 (((yAxis(11) and yAxis(10)) = '1') and (yAxis(9) = '0')))then
                
						own_acc_left <= '0';
                  own_acc_right <= '1';

				elsif (((yAxis(9) or yAxis(10)) = '1') and (yAxis(11) = '0')) then

						own_acc_left <= '1';
                  own_acc_right <= '0';
				
				else
            
						own_acc_left <= '0';
                  own_acc_right <= '0';
				end if;                    
			end if;
   
   end process;


end Behavioral;

