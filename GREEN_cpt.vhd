library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity GREEN_cpt is
Port (clk,reset: in std_logic;
	  COM: in std_logic_vector(1 downto 0);
      GREEN_out: out std_logic_vector(3 downto 0) );
end GREEN_cpt;

architecture Behavioral of GREEN_cpt is
signal T: std_logic_vector(4 downto 0);
begin
process(clk,reset)
  begin
  if reset='0' then 
    T<=(others=>'0');

  elsif rising_edge(clk)then
    if com="01" then T<=T + 1;
    elsif com="10" then T<= T - 1;
    else T<=T;
    end if;
  end if;
end process;
GREEN_out<=T(4 downto 1);

end Behavioral;