----------------------------------------------------------------------------------
--	Company: UPMC
--	Engineer: Julien Denoulet
-- 
--	Module Principal - Casse Briques
--
----------------------------------------------------------------------------------
library IEEE,work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use work.pong_pack.all;

entity top_nexys is
    Port (	clk100 						: in STD_LOGIC;								-- Horloge 100 Mhz				
				ouest 						: in STD_LOGIC; 								-- Reset Asynchrone (Bouton Ouest)				
				nord,sud,est				: in STD_LOGIC;								-- Boutons Poussoir			
				centre 						: in STD_LOGIC; 								-- Bouton Central (Demande de Pause)				
				
				S15,S3,S2,S1,S0 			: in STD_LOGIC;								-- Switchs						
				
				rot_a_console				: in STD_LOGIC;								-- Encodeur Rotatif (Mode Console)			
				rot_b_console				: in STD_LOGIC;								-- Encodeur Rotatif (Mode Console)			
				rot_a_manette				: in STD_LOGIC;								-- Encodeur Rotatif (Mode Manette)		
				rot_b_manette				: in STD_LOGIC;								-- Encodeur Rotatif (Mode Manette)
				
				tx_left						: out std_logic;								-- Emission Commande Gauche vers Autre Carte				
				rx_left						: in std_logic;								-- Réception Commande Gauche d'une Autre Carte
				tx_right						: out std_logic;								-- Emission Commande Droite vers Autre Carte
				rx_right						: in std_logic;								-- Réception Commande Droite d'une Autre Carte
				
				hsync 						: out  STD_LOGIC;								-- Synchro Horizontale VGA	
				vsync 						: out  STD_LOGIC;								-- Synchro Verticale VGA	
				VGA_red 					: out  STD_LOGIC_VECTOR(3 downto 0);			-- Rouge VGA					
				VGA_green 					: out  STD_LOGIC_VECTOR(3 downto 0);			-- Vert VGA						
				VGA_blue 					: out  STD_LOGIC_VECTOR(3 downto 0);			-- Bleu VGA							
				
				SS 							: out STD_LOGIC;								-- Bus SPI Accéléromètre - Slave Select
				SCLK 							: out STD_LOGIC;								-- Bus SPI Accéléromètre - Clock
				SDI 							: in STD_LOGIC;								-- Bus SPI Accéléromètre - Data Input
				SDO 							: out STD_LOGIC;								-- Bus SPI Accéléromètre - Data Output
				
				SEL_SEG 						: out STD_LOGIC_VECTOR (7 downto 0);   -- Selection de l'Afficheur
				SEG							: out STD_LOGIC_VECTOR (7 downto 0);   -- Segments Afficheurs
            
				led							: out STD_LOGIC_VECTOR(11 downto 0)		-- LEDs						

 -------------------------------------------------------------------------               
                
               );
end top_nexys;

architecture Behavioral of top_nexys is

signal clk25: std_logic;									-- Horloge 25 Mhz
signal reset: std_logic;									-- Reset Asynchrone

signal display: std_logic_vector(11 downto 0);		-- Pour Affichage des LEDs

-- PARAMETRES DE JEU
signal game_rqt: std_logic;								-- Demande de Changement de Jeu (Appui sur un Bouton Poussoir)
signal master_slave: std_logic;							-- Mode Maitre (Console) ou Esclave (Manette)
signal master_slave_rqt: std_logic;						-- Demande de Changement de Mode (Appui sur un Bouton Poussoir)


-- SIGNAUX D'AFFICHAGE
signal xpos,ypos: std_logic_vector(9 downto 0);		-- Coordonnees Pixel Courant
signal visible: std_logic;									-- Zone Visible de l'Image
signal endframe: std_logic;								-- Fin Image Visible
signal VGA_red_i: std_logic_vector(3 downto 0);	    -- Couleur R Fournie au VGA (sur 3x4 bits)
signal VGA_green_i: std_logic_vector(3 downto 0);	-- Couleur G Fournie au VGA (sur 3x4 bits)
signal VGA_blue_i: std_logic_vector(3 downto 0);	-- Couleur B Fournie au VGA (sur 3x4 bits)
signal red,green,blue: std_logic_vector(3 downto 0); -- Consigne de Couleur des Objets à Afficher (sur 3x1 bit) 
signal variable_red: std_logic_vector(3 downto 0);  -- Consigne de Couleur RED variable(sur 4 bits) 
signal variable_green: std_logic_vector(3 downto 0);  -- Consigne de Couleur GREEN variable(sur 4 bits) 
signal variable_blue: std_logic_vector(3 downto 0);  -- Consigne de Couleur BLUE variable(sur 4 bits) 
signal moving_color_cmd: std_logic;                 -- Commande d'affichage des couleurs variables

-- SIGNAUX DES MANETTES DE JEU
signal manette: std_logic;									-- Selection Manette de Jeu (Encodeur / Accéléromètre)
signal rot_a,rot_b: std_logic;							-- Signaux de l'Encodeur Rotatif (Selon le Mode Choisi)
signal own_rot_left,own_rot_right: std_logic;		-- Mouvement de l'Encodeur Rotatif de la Carte
signal own_left,own_right: std_logic;					-- Mouvement de Déplacement de la Carte (Selon Commande Acc/Enc)
signal other_left,other_right: std_logic;				-- Mouvement de Déplacement de l'Autre Carte
signal own_press,other_press: std_logic;				-- Appui sur Bouton Encodeur
signal pause_rqt: std_logic;								-- Demande de Pause

-- SIGNAUX ACCELEROMETRE
signal Clk_Acc : STD_LOGIC;								-- Horloge pour les Commandes de Déplacement de l'Accéléromètre
signal own_acc_left,own_acc_right: STD_LOGIC;		-- Commandes de Déplacement de l'Accéléromètre

-- SIGNAUX OPTIONS DE JEU
signal game_type: std_logic;								-- Type de Jeu (0 = Casse Brique / 1 = Pong)
signal taille: std_logic;									-- Parametre Taille de la Raquette
signal speed: std_logic;									-- Parametre Vitesse de la Balle
signal obstacle: std_logic;								-- Presence d'un Obstacle (Pong)
signal game_lost: std_logic;								-- Drapeau Partie Perdue
signal pause: std_logic;									-- Mode Pause

-- SIGNAUX OBJETS DU JEU
signal bluebox: std_logic;									-- Pixel Courant = Case Bleue du Decor
signal left: std_logic;										-- Pixel Courant = Bord Gauche de L'Ecran
signal right: std_logic;									-- Pixel Courant = Bord Droit de L'Ecran
signal bottom: std_logic;									-- Pixel Courant = En Bas de L'Ecran
signal lost: std_logic;										-- La Balle Va Sortir de L'Ecran
signal pad: std_logic;										-- Pixel Courant = Raquette
signal ball: std_logic;										-- Pixel Courant = Balle
signal wall_pong: std_logic;								-- Pixel Courant = Mur Jeu Pong
signal wall_brick: std_logic;								-- Pixel Courant = Mur Jeu Casse Briques
signal barrier: std_logic;									-- Pixel Courant = Obstacle (Jeu Pong)
signal brick: tableau;										-- Pixel Courant = Brique(i)(j)
signal brick_bounce: tableau;								-- Pixel Courant Rebondit Contre une Brique(i)(j)



begin


-----------------------------------------------------------------------------------------
	-- GENERATEURS D'HORLOGES
	clk25MHz: entity work.ClkDiv
			port map (
				clk100 => clk100,			-- Horloge 100 MHz
				reset => reset,			-- Reset Asynchrone
				clk25 => clk25			-- Horloge 25 MHz
				);	

	clk25Hz: entity work.ClkAcc
			port map (
				clk100 => clk100,			-- Horloge 100 MHz
				reset => reset,			-- Reset Asynchrone
				Clk_Acc	=> Clk_Acc);	-- Horloge 25 Hz (Pour Traitement des Commandes Accéléromètre)

-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------
	-- GESTION DES ENTREES/SORTIES DE LA CARTE

	-- Switch S0: 0 = Systeme OFF / 1 = Systeme ON
	-- Reset Asynchrone COnnecte au Bouton Ouest 
	reset <= (not ouest) and S0 ;

	-- CONTROLEUR DES INTERRUPTEURS
	switch: entity work.switch_mgr
		port map(
			S15		=> S15,
			S3			=> S3,
			S2			=> S2,
			S1			=> S1,
			taille	=> taille,
			speed		=> speed,
			obstacle	=> obstacle,
			manette	=> manette
		);
		
		
	-- CONTROLEUR DES BOUTONS POUSSOIRS
	buttons: entity work.button_mgr
		port map (
			clk25 			=> clk25,				-- Horloge
			reset 			=> reset,				-- Reset Asynchrone
			nord				=> nord,					-- Bouton Nord
			sud 				=> sud,					-- Bouton Sud
			est 				=> est,					-- Bouton Est
			press_sud		=> master_slave_rqt,	-- Demande de Changement de Mode (Bouton Sud)
			press_nord_est	=> game_rqt				-- Demande de Changement de Jeu (Bouton Nord ou Est)
		);		


	-- AFFICHEURS 7 SEGMENTS
	aff: entity work.aff_mgr_nexys
			port map (
				clk25 			=> clk25,			-- Horloge 25 MHz
				reset 			=> reset,			-- Reset Asynchrone
				pause				=> pause,			-- Commande Pause
				master_slave	=>	master_slave,	-- Mode Maitre (Console) ou Esclave (Manette)
				game_type		=> game_type,		-- Type de Jeu (Pong / Casse-Briques=
				sel_seg 			=> sel_seg,			-- Selection de l'Afficheur
				seg 				=> seg);				-- Valeur des Segments de l'Afficheur



	-- Sélection de l'Entrée à Utiliser pour l'Encodeur Rotatif
	-- En Fonction du Mode Console (PMOD B) ou Manette (PMOD C)
	rot_a <= rot_a_console when master_slave = '1' else rot_a_manette;
	rot_b <= rot_b_console when master_slave = '1' else rot_b_manette;


	-- CONTROLEUR DE L'ENCODEUR ROTATIF DE LA CARTE
	codeur: entity work.ip_rotary
		port map (
			clk25 		=> clk25,				-- Horloge
			reset 		=> reset,				-- Reset Asynchrone
			rot_a 		=> rot_a,				-- Switch A du Codeur
			rot_b 		=> rot_b,				-- Switch B du Codeur
			rot_left 	=> own_rot_left,		-- Commande de Rotation a Gauche
			rot_right 	=> own_rot_right);	-- Commande de Rotation a Droite

-----------------------------------------------------------------

	-- GESTION ACCELEROMETRE
	accelero_mgr : entity work.accelero_mgr(Behavioral) 
	
			port map( 
				clk25 			=> clk25,			-- Horloge
				reset 			=> RESET,			-- Reset

             -- Accelerometer data signals
				own_acc_left	=> own_acc_left,	-- Commande de Déplacement à Gauche
				own_acc_right	=> own_acc_right,	-- Commande de Déplacement à Droite

                --SPI Interface Signals
				SCLK      		=> SCLK,				-- Serial Clock
				SDO     			=> SDO,				-- Data Output
				SDI     			=> SDI,				-- Data Input
				SS      			=> SS					-- Slave Select
         );

-----------------------------------------------------------------


-- Choix de la Manette par le Switch S15 (Manette)
--		- 0 --> Encodeur Rotatif
--		- 1 --> Accéléromètre
own_left 	<= own_acc_left 	when manette = '1' else own_rot_left;
own_right 	<= own_acc_right 	when manette = '1' else own_rot_right;

-- Envoi des Commandes de Déplacement (pour le Mode Manette)
tx_left <= own_left; tx_right <= own_right;

-- Acquisition des Commandes de Déplacement d'une Autre Carte Utilisée comme Manette
other_left <= rx_left; other_right <= rx_right;

-- Gestion de la Pause: Seule la Carte Maitre Peut Mettre le Jeu en Pause
own_press <= centre;
pause_rqt <= own_press;


-----------------------------------------------------------------

	
	-- GESTION DES LEDS
		-- LED Allumees Si On Est en Mode Maitre (Console)
		-- LED Eteintes Si On Est en Mode Esclave (Manette)

	display <= (others => '1') when (S0 = '1' and master_slave = '1')
	else (others => '0');

	-- Envoi de la Valeur a Afficher sur les LEDs
	led <= display;
	
--------------------------------------------------------------------------------------------------------
	
	-- GESTION DES OBJETS
	obj_ctrl: entity work.objects
			port map (
				clk25 				=> clk25,				-- Horloge 25 MHz
				clk_acc           => Clk_Acc,				-- Horloge pour les Commandes de Déplacement de l'Accéléromètre
				reset					=> reset,				-- Reset Asynchrone
				endframe				=> endframe,			-- Fin de l'Image Visible
				xpos 					=> xpos,					-- Coordonnee X du Pixel Courant
				ypos 					=> ypos,					-- Coordonnee Y du Pixel Courant
				
				own_left 			=> own_left,   		-- Commande Deplacement Gauche Codeur de la Carte
				own_right 			=> own_right,        -- Commande Deplacement Droite Codeur de la Carte
            other_left 			=> other_left,   		-- Commande Deplacement Gauche Codeur Autre Carte
            other_right 		=> other_right,  		-- Commande Deplacement Droite Codeur Autre Carte
								
				game_type			=> game_type,			-- Choix du Type de Jeu
            manette   			=> manette,          -- Selection Manette (Encodeur vs Accéléromètre)
				taille				=> taille,				-- Parametre Taille
				speed 				=> speed,				-- Vitesse du Jeu
				obstacle 			=> obstacle,			-- Presence d'un Obstacle (Pong)
				pause					=> pause,				-- Commande Mode Pause
				game_lost			=> game_lost,			-- Mode Echec
				bluebox 				=> bluebox,				-- Pixel Courant = Case Bleue
				left 					=> left,					-- Pixel Courant = Gauche de l'Ecran
				right 				=> right,				-- Pixel Courant = Droite de l'Ecran
				bottom 				=> bottom,				-- Pixel Courant = Bas de l'Ecran
				wall_pong			=> wall_pong,			-- Pixel Courant = Mur Jeu Pong
				wall_brick 			=> wall_brick,			-- Pixel Courant = Mur Jeu Casse Briques
				barrier				=> barrier,				-- Pixel Courant = Obstacle (Jeu Pong)
				pad 					=> pad,					-- Pixel Appartient a la Raquette
				brick					=> brick,				-- Pixel Courant = Brique
				brick_bounce		=> brick_bounce,		-- Rebond Contre une Brique
				ball 					=> ball 					-- Pixel Courant = Balle
			 );

    -- Génération Signal de Commande d'Affichage d'une Couleur Variable
    -- Mise à 1 si le Pixel Courant Appartient à une Brique, Mise à 0 sinon
    process(brick)
    begin
        moving_color_cmd <= '0'; 
        for i in 0 to 1 loop
            for j in 0 to 8 loop
                if brick(i)(j)='1' then 
                    moving_color_cmd <= '1'; 
                end if;
            end loop;
        end loop;
    end process;

------------------------------------------------------------------

	lost <= ball and (bottom or left or right);	-- La Balle Sort de L'Exran Si Elle Atteint un des Bords

	-- GESTION DU JEU
	game_ctrl: entity work.game
			port map (
				clk25 				=> clk25,				-- Horloge 25 MHz
				reset 				=> reset,				-- Reset Asynchrone
				master_slave_rqt 	=> master_slave_rqt,	-- Demande de Changement de Mode (Console / Manette)
				game_rqt 			=> game_rqt,			-- Demande de Changement de Jeu (Pong / Casse Briques)
				
				-- ************** REMPLACER L'INSTRUCTION CI-DESSOUS PAR CELLE EN COMMENTAIRE *****************
				pause_rqt 			=> S1,					-- Demande de Pause - Appui sur Bouton Encodeur
				-- pause_rqt 			=> pause_rqt,					-- Demande de Pause - Appui sur Bouton Encodeur
				-- ********************************************************************************************

				endframe 			=> endframe,			-- Fin de l'Image Visible
				visible 				=> visible,				-- Zone Visible de l'Image
				wall_pong			=> wall_pong,			-- Pixel Courant = Mur Jeu Pong
				wall_brick 			=> wall_brick,			-- Pixel Courant = Mur Jeu Casse Briques
				barrier				=> barrier,				-- Pixel Courant = Obstacle (Jeu Pong)
				lost 					=> lost,					-- La Balle Sort de L'Ecran
				bluebox 				=> bluebox,				-- Pixel Courant = Case Bleue
				pad 					=> pad,					-- Pixel Courant = Raquette
				ball					=> ball,					-- Pixel Courant = Balle
				brick 				=> brick,				-- Pixel Courant = Brique
				red 					=> red(3),					-- Commande Affichage Rouge
				green 				=> green(3),				-- Commande Affichage Vert
				blue 					=> blue(3),					-- Commande Affichage Bleu
				brick_bounce 		=> brick_bounce,		-- Rebond Contre une Brique
				master_slave		=>	master_slave,		-- Selection Mode Esclave / Maitre
				game_type			=>	game_type,			-- Selection du Type de Jeu
				game_lost 			=> game_lost,			-- Timer du Mode Partie Perdue
				pause 				=> pause					-- Mode Pause
			);


-----------------------------------------------------------------------------------


	-- CONTROLEUR VGA
	vga_ctrl: entity work.VGA
			port map (
				clk25 	=> clk25,		-- Horloge 25 MHz
				reset 	=> reset,		-- Reset Asynchrone
				r			=> red(3),			-- Commande Affichage Rouge
				g 			=> green(3),		-- Commande Affichage Vert
				b 			=> blue(3),			-- Commande Affichage Bleu
				red 		=> VGA_red(3),		-- Affichage Pixel Rouge
				green 	=> VGA_green(3),	-- Affichage Pixel Vert
				blue 		=> VGA_blue(3),	-- Affichage Pixel Bleu
				vsync 	=> vsync,		-- Synchro Verticale
				hsync 	=> hsync,		-- Synchro Horizontale
				visible 	=> visible,		-- Zone Visible de l'Image
				endframe	=> endframe,	-- Fin de l'Image Visible
				xpos  	=> xpos,			-- Coordonnee X du Pixel Courant
				ypos  	=> ypos);		-- Coordonnee Y du Pixel Courant

VGA_red(2 downto 0) <= "000";
VGA_green(2 downto 0) <= "000";
VGA_blue(2 downto 0) <= "000";

-----------------------------------------------------------------------------------

	-- CONTROLEUR VGA 4 bits
--	vga_ctrl: entity work.VGA_4bits
--			port map (
--				clk25 	=> clk25,		-- Horloge 25 MHz
--				reset 	=> reset,		-- Reset Asynchrone
--				r		=> VGA_red_i,		-- Commande Affichage Rouge
--				g 		=> VGA_green_i,		-- Commande Affichage Vert
--				b 		=> VGA_blue_i,		-- Commande Affichage Bleu
--				red 		=> VGA_red,		-- Affichage Pixel Rouge
--				green 	=> VGA_green,	-- Affichage Pixel Vert
--				blue 		=> VGA_blue,	-- Affichage Pixel Bleu
--				vsync 	=> vsync,		-- Synchro Verticale
--				hsync 	=> hsync,		-- Synchro Horizontale
--				visible 	=> visible,		-- Zone Visible de l'Image
--				endframe	=> endframe,	-- Fin de l'Image Visible
--				xpos  	=> xpos,			-- Coordonnee X du Pixel Courant
--				ypos  	=> ypos);		-- Coordonnee Y du Pixel Courant


    -- INSTANCIATION MODULE DE GENERATION DE COULEURS VARIABLES
--    ColorGen:   entity work.Moving_Colors
--                port map(
--                    Clk100      => clk100,  -- Horloge 100 Mhz
--                    Reset       => reset, -- Reset Asynchrone
--                   RED_OUT     => variable_red,     -- Consigne Couleur Rouge
--                    GREEN_OUT   => variable_green,   -- Consigne Couleur Verte
--                    BLUE_OUT    => variable_blue     -- Consigne Couleur Bleue
--                );


    -- CONSIGNE DE COULEUR ENVOYEE AU CONTROLEUR VGA
--    VGA_red_i <=    "0000" when master_slave = '0' else         -- Noir Si on Est en Mode Manette
--                    variable_red when (moving_color_cmd='1')    -- Sinon Couleur Variable si Commande Activée
--                    else red;                                   -- Sinon Consigne ROUGE Standard

--    VGA_green_i <=  "0000" when master_slave = '0' else         -- Noir Si on Est en Mode Manette
--                    variable_green when (moving_color_cmd='1')  -- Sinon Couleur Variable si Commande Activée
--                    else green;                                 -- Sinon Consigne VERTE Standard

--    VGA_blue_i <=   "0000" when master_slave = '0' else         -- Noir Si on Est en Mode Manette
--                    variable_blue when (moving_color_cmd='1')   -- Sinon Couleur Variable si Commande Activée
--                    else blue;                                  -- Sinon Consigne BLEUE Standard
      
end Behavioral;

