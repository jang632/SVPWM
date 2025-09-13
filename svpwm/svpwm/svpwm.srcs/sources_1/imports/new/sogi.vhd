library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY sogi IS
    PORT (
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        v_in   : IN  SIGNED(31 DOWNTO 0);           
        v_out  : OUT SIGNED(31 DOWNTO 0);
        qv_out : OUT SIGNED(31 DOWNTO 0)
    );
END sogi;

ARCHITECTURE Behavioral OF sogi IS

    CONSTANT Ts       : SIGNED(31 DOWNTO 0) := x"00001062"; -- fs = 64kHz
    CONSTANT k        : SIGNED(31 DOWNTO 0) := x"0199999A"; -- 0.1
    CONSTANT omega_int: SIGNED(31 DOWNTO 0) := x"013A28C6"; -- 2*pi*50Hz
    CONSTANT k_omega  : SIGNED(31 DOWNTO 0) := x"01F6A7A3"; -- k*omega

    SIGNAL diff_reg   : SIGNED(31 DOWNTO 0);

    SIGNAL mult_reg_1 : SIGNED(63 DOWNTO 0);
    SIGNAL mult_reg_2 : SIGNED(95 DOWNTO 0);
    SIGNAL mult_reg_3 : SIGNED(95 DOWNTO 0);
    SIGNAL mult_reg_4 : SIGNED(95 DOWNTO 0);
    SIGNAL mult_reg_5 : SIGNED(95 DOWNTO 0);

    SIGNAL v          : SIGNED(63 DOWNTO 0);
    SIGNAL qv         : SIGNED(63 DOWNTO 0);

    SIGNAL dv         : SIGNED(63 DOWNTO 0);
    SIGNAL dqv        : SIGNED(95 DOWNTO 0);

BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                diff_reg   <= (OTHERS => '0');
                v_out      <= (OTHERS => '0');
                qv_out     <= (OTHERS => '0');
                v          <= (OTHERS => '0');
                qv         <= (OTHERS => '0');
                mult_reg_1 <= (OTHERS => '0');
                mult_reg_2 <= (OTHERS => '0');
                mult_reg_3 <= (OTHERS => '0');
                mult_reg_4 <= (OTHERS => '0');
                dv         <= (OTHERS => '0');
                dqv        <= (OTHERS => '0');
            ELSE

                diff_reg   <= v_in - SHIFT_LEFT(v(63 DOWNTO 32), 16);          -- 32b/28
                mult_reg_1 <= k_omega * diff_reg;                               -- 64b/48
                mult_reg_2 <= omega_int * qv;                                   -- 96b/60
                dv         <= mult_reg_1 - SHIFT_LEFT(mult_reg_2(95 DOWNTO 32), 20); -- 64b/48
                mult_reg_3 <= Ts * dv;                                          -- 96b/76
                v          <= v + mult_reg_3(95 DOWNTO 32);                     -- 64b/44
                dqv        <= omega_int * v;                                    -- 96b/60
                mult_reg_4 <= Ts * dqv(95 DOWNTO 32);                           -- 96b/56
                qv         <= qv + SHIFT_LEFT(mult_reg_4(95 DOWNTO 32), 20);    -- 64b/44

                v_out  <= SHIFT_LEFT(v(63 DOWNTO 32), 16);
                qv_out <= SHIFT_LEFT(qv(63 DOWNTO 32), 16);
            END IF;
        END IF;
    END PROCESS;

END Behavioral;
