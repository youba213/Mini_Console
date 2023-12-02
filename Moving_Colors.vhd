----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.11.2022 14:03:18
-- Design Name: 
-- Module Name: Moving_Colors - Behavioral
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

entity Moving_Colors is
    Port (clk100Mhz,raz: in std_logic;
            clk20out: out std_logic;
            com_R_out,com_G_out,com_B_out: out std_logic_vector(1 downto 0);
          RED_out,GREEN_out,BLUE_out: out std_logic_vector(3 downto 0) );
end Moving_Colors;

architecture Behavioral of Moving_Colors is
signal Clk20: std_logic;
signal red,green,blue: std_logic_vector(3 downto 0);
signal com_R,com_G,com_B: std_logic_vector(1 downto 0);
begin
------------------------------------------- instanciation des compteurs  -------------------------
    R: entity work.RED_cpt
    port map(
                clk => Clk20,  
                reset => raz,
                com => com_R,
                RED_out => red
    );
    
    G: entity work.GREEN_cpt
    port map(
                clk => Clk20,  
                reset => raz,
                com => com_G,
                GREEN_out => green
    );
    
    B: entity work.BLUE_cpt
    port map(
                clk => Clk20,  
                reset => raz,
                com => com_B,
                BLUE_out => blue
    );
    
    My_MAE: entity work.MAE
    port map(
            clk => clk100Mhz,
            reset => raz,
            red_in => red,
            green_in => green,
            blue_in => blue,
            com_R => com_R,
            com_G => com_G,
            com_B => com_B
 );
 
    DivH: entity work.DivClk
         port map(
                    clk100 => clk100Mhz,  
                    reset => raz,
                    clk20 => Clk20
         );

RED_out<= red;
GREEN_out<= green;
BLUE_out<= blue;
clk20out<=clk20;
com_R_out <= com_R;
com_G_out <= com_G;
com_B_out <= com_B;

end Behavioral;
