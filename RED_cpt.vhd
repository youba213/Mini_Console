----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.11.2022 17:38:52
-- Design Name: 
-- Module Name: RED_cpt - Behavioral
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

entity RED_cpt is
Port (clk,reset: in std_logic;
	  COM: in std_logic_vector(1 downto 0);
      RED_out: out std_logic_vector(3 downto 0) );
end RED_cpt;

architecture Behavioral of RED_cpt is
signal T: std_logic_vector(4 downto 0);
begin
process(clk,reset)
  begin
  if reset='0' then 
    T<=(others=>'1');

  elsif rising_edge(clk)then
    if com="01" then T<=T + 1;
    elsif com="10" then T<= T - 1;
    else T<=T;
    end if;
  end if;
end process;
RED_out<=T(4 downto 1);

end Behavioral;