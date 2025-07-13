library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clarke_transform is
    PORT(
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        v_a      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_b      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_c      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_alpha  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        v_beta   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );     
end clarke_transform;

architecture Behavioral of clarke_transform is
    CONSTANT TWO_THIRDS        : signed(15 DOWNTO 0) := x"2AAD";    
    CONSTANT SQ_THREE_THIRDS  : signed(15 DOWNTO 0) := x"24F5";
    CONSTANT ONE_THIRD        : signed(15 DOWNTO 0) := x"1555";
begin
    PROCESS(clk)
    BEGIN 
        IF(reset = '1') THEN 
            v_alpha <= (others => '0');  
            v_beta  <= (others => '0');             
        ELSIF rising_edge(clk) THEN 
            v_alpha <= STD_LOGIC_VECTOR(resize(resize(TWO_THIRDS * signed(v_a), 32) - resize(ONE_THIRD * signed(v_b), 32) - resize(ONE_THIRD * signed(v_c), 32), 32));
            v_beta  <= STD_LOGIC_VECTOR(resize(resize(SQ_THREE_THIRDS * signed(v_b), 32) - resize(SQ_THREE_THIRDS * signed(v_c), 32), 32));
        END IF;
    END PROCESS;
end Behavioral;