library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity move is
    port(clk,reset: in std_logic;
    QA,QB: in std_logic;
    R,L: out std_logic);
end move;

architecture Behavioral of move is
type etat is (S0,S1,S2,S3,S4,S5);
signal EP,EF: etat;
--signal red_out,green_out,blue_out:std_logic_vector(3 downto 0);
begin



-----------------------------------   Registre d'etats   -------------------------------    
    process(clk,reset)
        begin
        if reset='0' then EP <= S0;
        elsif rising_edge(clk) then EP <= EF;
        end if;
    end process;
------------------------------------   COMBINATOIR DES ETATS  --------------------------------------------------
process(EP,QA,QB)
begin
    case (EP) is
        when S0 => EF<=S0; if QA='1' and QB='0'  then EF<=S1; elsif QA='1' AND QB='1' then EF<=S2; end if;
        when S1 => EF<=S3; 
        when S2 => EF<=S3;
        when S3 => EF<=S3; if QA='0' and QB='1' then EF<=S4; elsif QA='0' and QB='0'then EF<=S5; end if;
        when S4 => EF<=S0;
        when S5 => EF<=S0;
    end case;
end process;
----------------------------------- COMBINATOIR DES SORTIES --------------------------------------------------
process(EP)
begin
    case (EP) is
        when S0 => R<='0'; L<='0';
        when S1 => R<='0'; L<='1';
        when S2 => R<='1'; L<='0';
        when S3 => R<='0'; L<='0';
        when S4 => R<='0'; L<='1';
        when S5 => R<='1'; L<='0';
    end case;
end process;

end Behavioral;