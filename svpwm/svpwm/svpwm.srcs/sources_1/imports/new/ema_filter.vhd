library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY ema_filter IS
    PORT (
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        data_in  : IN  SIGNED(31 DOWNTO 0);
        data_out : OUT SIGNED(31 DOWNTO 0)
    );
END ema_filter;

ARCHITECTURE Behavioral OF ema_filter IS

    TYPE pipeline IS ARRAY (0 TO 1) OF SIGNED(31 DOWNTO 0);
    SIGNAL ema_val : SIGNED(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS(clk)
    BEGIN
        IF reset = '1' THEN
            ema_val  <= (OTHERS => '0');
            data_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            ema_val  <= ema_val + shift_right(data_in - ema_val, 8);
            data_out <= ema_val;
        END IF;
    END PROCESS;

END Behavioral;
