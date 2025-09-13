library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY psc IS
    PORT (
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        alpha_v  : IN  SIGNED(31 DOWNTO 0);
        alpha_qv : IN  SIGNED(31 DOWNTO 0);
        beta_v   : IN  SIGNED(31 DOWNTO 0);
        beta_qv  : IN  SIGNED(31 DOWNTO 0);
        alpha    : OUT SIGNED(31 DOWNTO 0);
        beta     : OUT SIGNED(31 DOWNTO 0)
    );
END psc;

ARCHITECTURE Behavioral OF psc IS

BEGIN

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                alpha <= (OTHERS => '0');
                beta  <= (OTHERS => '0');
            ELSE
                alpha <= shift_right(alpha_v - beta_qv, 1);
                beta  <= shift_right(alpha_qv + beta_v, 1);
            END IF;
        END IF;
    END PROCESS;

END Behavioral;
