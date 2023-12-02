library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MAE is
    port(clk,reset: in std_logic;
    red_in,green_in,blue_in: in std_logic_vector(3 downto 0);
    com_R,com_G,com_B: out std_logic_vector(1 downto 0));
end MAE;

architecture Behavioral of MAE is
type etat is (S0,S1,S2);
signal EP,EF: etat;
--signal red_out,green_out,blue_out:std_logic_vector(3 downto 0);
begin



-----------------------------------   Registre d’etats   -------------------------------    
    process(clk,reset)
        begin
        if reset='0' then EP <= S0;
        elsif rising_edge(clk) then EP <= EF;
        end if;
    end process;
------------------------------------   COMBINATOIR DES ETATS  --------------------------------------------------
process(EP,red_in,green_in,blue_in)
begin
    case (EP) is
        when S0 => EF<=S0; if green_in="1111" then EF<=S1; end if;
        when S1 => EF<=S1; if blue_in="1111" then EF<=S2; end if;
        when S2 => EF<=S2; if red_in="1111" then EF<=S0; end if;
    end case;
end process;
----------------------------------- COMBINATOIR DES SORTIES --------------------------------------------------
process(EP)
begin
    case (EP) is
        when S0 => com_R<="10"; com_G<="01"; com_B<="11";
        when S1 => com_R<="11"; com_G<="10"; com_B<="01";
        when S2 => com_R<="01"; com_G<="11"; com_B<="10";
    end case;
end process;

end Behavioral;