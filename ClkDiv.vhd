library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity clkdiv is
port ( clk100,reset: in std_logic; 
       clk25: out std_logic );
end entity;

architecture logic of clkdiv is
signal compte : std_logic_vector(1 downto 0);
begin
process (clk100,reset )
begin
if reset ='0' then
compte <= "00";
elsif rising_edge(clk100) then 
compte <= compte + 1 ;
end if;
end process;
clk25 <= compte(1);
end logic;