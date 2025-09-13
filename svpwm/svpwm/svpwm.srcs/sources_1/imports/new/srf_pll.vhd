library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY srf_pll IS
    PORT (
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        v_a    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_b    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_c    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        omega  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        phase  : OUT SIGNED(31 DOWNTO 0)
    );
END srf_pll;

ARCHITECTURE Behavioral OF srf_pll IS

    SIGNAL theta     : SIGNED(31 DOWNTO 0);

    SIGNAL v_d       : SIGNED(31 DOWNTO 0);
    SIGNAL v_q       : SIGNED(31 DOWNTO 0);

    SIGNAL omega_int : SIGNED(31 DOWNTO 0);
    SIGNAL theta_int : SIGNED(63 DOWNTO 0);

    CONSTANT Ts      : SIGNED(31 DOWNTO 0) := x"00008312"; -- 1/64kHz

    SIGNAL v_q_ema   : SIGNED(31 DOWNTO 0) := (OTHERS => '0');

    COMPONENT parke_transform
        PORT (
            clk   : IN  STD_LOGIC;
            reset : IN  STD_LOGIC;
            v_a   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_b   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_c   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            theta : IN  SIGNED(31 DOWNTO 0);
            v_d   : OUT SIGNED(31 DOWNTO 0);
            v_q   : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT pi_controller
        PORT (
            clk       : IN  STD_LOGIC;
            reset     : IN  STD_LOGIC;
            error_in  : IN  SIGNED(31 DOWNTO 0);
            omega_out : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ema_filter IS
        PORT (
            clk      : IN  STD_LOGIC;
            reset    : IN  STD_LOGIC;
            data_in  : IN  SIGNED(31 DOWNTO 0);
            data_out : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    parke_inst : parke_transform
        PORT MAP (
            clk     => clk,
            reset   => reset,
            v_a     => v_a,
            v_b     => v_b,
            v_c     => v_c,
            theta   => theta,
            v_d     => v_d,
            v_q     => v_q
        );

    pi_ctrl_inst : pi_controller
        PORT MAP (
            clk       => clk,
            reset     => reset,
            error_in  => v_q_ema,
            omega_out => omega_int
        );

    ema_inst : ema_filter
        PORT MAP (
            clk      => clk,
            reset    => reset,
            data_in  => v_q,
            data_out => v_q_ema
        );

    PROCESS(clk)
    BEGIN        
        IF (clk = '1') THEN 
            IF reset = '1' THEN
                theta_int <= x"5F1089F871A47000"; --steady state value
            ELSE
                theta_int <= theta_int + shift_left(SIGNED(omega_int) * Ts, 13);
                IF theta_int > x"6487ED5110BBA800" THEN --2*pi
                    theta_int <= theta_int - x"6487ED5110BBA800"; --2*pi
                ELSIF theta_int < x"0000000000000000" THEN
                    theta_int <= theta_int + x"6487ED5110BBA800"; --2*pi
                END IF;
            END IF;
        END IF;
    END PROCESS;

    theta <= theta_int(63 DOWNTO 32);
    
    
    omega <= STD_LOGIC_VECTOR(omega_int);
    phase <= theta_int(63 DOWNTO 32);

END Behavioral;
