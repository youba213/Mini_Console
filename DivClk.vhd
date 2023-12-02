library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity DivClk is
port ( clk100,reset: in std_logic; 
       clk20: out std_logic );
end entity;

architecture logic of DivClk is
signal compte : std_logic_vector(22 downto 0);
begin

process (clk100,reset )
begin

if reset ='0' then

compte <= (others=>'0');
clk20 <= '0';

elsif rising_edge(clk100) then 
	compte <= compte + 1 ;
    if compte =  2499999 then
    clk20 <= '1';
	elsif compte = 4999999 then
    clk20 <= '0';
    compte <= (others=>'0');
    end if;
    
end if;
end process;
end logic;