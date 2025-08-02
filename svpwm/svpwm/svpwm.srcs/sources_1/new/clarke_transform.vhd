library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clarke_transform is
    PORT (
        clk     : IN  STD_LOGIC;
        reset   : IN  STD_LOGIC;
        v_a     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_b     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_c     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_alpha : OUT SIGNED(31 DOWNTO 0);
        v_beta  : OUT SIGNED(31 DOWNTO 0)
    );
end clarke_transform;

architecture Behavioral of clarke_transform is

    CONSTANT TWO_THIRDS       : SIGNED(15 DOWNTO 0) := x"2AAD";
    CONSTANT SQ_THREE_THIRDS  : SIGNED(15 DOWNTO 0) := x"24F5";
    CONSTANT ONE_THIRD        : SIGNED(15 DOWNTO 0) := x"1555";

    SIGNAL mult_reg_1 : SIGNED(31 DOWNTO 0);
    SIGNAL mult_reg_2 : SIGNED(31 DOWNTO 0);
    SIGNAL mult_reg_3 : SIGNED(31 DOWNTO 0);
    SIGNAL mult_reg_4 : SIGNED(31 DOWNTO 0);
    SIGNAL mult_reg_5 : SIGNED(31 DOWNTO 0);

begin

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (reset = '1') THEN
                mult_reg_1 <= (OTHERS => '0');
                mult_reg_2 <= (OTHERS => '0');
                mult_reg_3 <= (OTHERS => '0');
                mult_reg_4 <= (OTHERS => '0');
                mult_reg_5 <= (OTHERS => '0');
            ELSE
                mult_reg_1 <= TWO_THIRDS      * signed(v_a);
                mult_reg_2 <= ONE_THIRD       * signed(v_b);
                mult_reg_3 <= ONE_THIRD       * signed(v_c);
                mult_reg_4 <= SQ_THREE_THIRDS * signed(v_b);
                mult_reg_5 <= SQ_THREE_THIRDS * signed(v_c);
            END IF;
        END IF;
    END PROCESS;

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (reset = '1') THEN
                v_alpha <= (OTHERS => '0');
                v_beta  <= (OTHERS => '0');
            ELSE
                v_alpha <= mult_reg_1 - mult_reg_2 - mult_reg_3;
                v_beta  <= mult_reg_4 - mult_reg_5;
            END IF;
        END IF;
    END PROCESS;

end Behavioral;
