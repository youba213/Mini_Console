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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mode is
    port ( 
        clk,reset,pause_Rqt,Endframe,Lost,No_Brick: in std_logic;
     Brick_Win,Pause,Game_lost: out std_logic ) ;
end mode;

architecture Behavioral of mode is
type etat is (S0,S1,S2,S3,S4);
signal EP,EF: etat;
signal T_Lost: std_logic_vector(5 downto 0);
signal fin_tempo,timer_lost,raz_tempo,load_timer,update_timer,update_tempo: std_logic;

begin

MAEmode: entity work.MAE_mode
    port map (
            clk                     =>      clk,
            reset                   =>      reset,
            pause_Rqt               =>      pause_Rqt,
            Endframe                =>      Endframe,
            Lost                    =>      Lost,
            No_Brick                =>      No_Brick,
            fin_tempo_pause         =>      fin_tempo,
            Brick_Win               =>      Brick_Win,
            Pause                   =>      Pause,
            raz_tempo_pause         =>      raz_tempo,
            load_timer_lost         =>      load_timer,
            update_timer_lost       =>      update_timer,
            update_tempo_pause      =>      update_tempo,
            Timer_Lost              =>      T_Lost
    );
TimerLost: entity work.Timer_Lost
        port map (
        clk                         =>      clk,
        reset                       =>      reset,
        load_timer_lost             =>      load_timer,
        update_timer_lost           =>      update_timer,
        Game_Lost                   =>      Game_lost,
        Timer_Lost                  =>      T_Lost
    );
TempoPose: entity work.Tempo_Pause
    port map (
            clk                     =>      clk,
            reset                   =>      reset,
            update_tempo_pause      =>      update_tempo,
            raz_tempo_pause         =>      raz_tempo,
            fin_tempo_pause         =>      fin_tempo
            
    );


end Behavioral;