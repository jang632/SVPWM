library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY parke_transform IS
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
END parke_transform;

ARCHITECTURE Behavioral OF parke_transform IS

    SIGNAL v_alpha        : SIGNED(31 DOWNTO 0);
    SIGNAL v_beta         : SIGNED(31 DOWNTO 0);

    SIGNAL sin_val        : SIGNED(31 DOWNTO 0);
    SIGNAL cos_val        : SIGNED(31 DOWNTO 0);

    SIGNAL v_d_int        : SIGNED(63 DOWNTO 0);
    SIGNAL v_q_int        : SIGNED(63 DOWNTO 0);

    SIGNAL v_alpha_delayed : SIGNED(31 DOWNTO 0);
    SIGNAL v_beta_delayed  : SIGNED(31 DOWNTO 0);

    SIGNAL alpha_v   : SIGNED(31 DOWNTO 0);
    SIGNAL alpha_qv  : SIGNED(31 DOWNTO 0);
    SIGNAL beta_v    : SIGNED(31 DOWNTO 0);
    SIGNAL beta_qv   : SIGNED(31 DOWNTO 0);
    SIGNAL sogi_alpha : SIGNED(31 DOWNTO 0);
    SIGNAL sogi_beta  : SIGNED(31 DOWNTO 0);

    COMPONENT clarke_transform
        PORT (
            clk      : IN  STD_LOGIC;
            reset    : IN  STD_LOGIC;
            v_a      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_b      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_c      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_alpha  : OUT SIGNED(31 DOWNTO 0);
            v_beta   : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT cordic_sin_cos
        GENERIC (
            iterations : INTEGER
        );
        PORT (
            clk        : IN  STD_LOGIC;
            reset      : IN  STD_LOGIC;
            theta      : IN  SIGNED(31 DOWNTO 0);
            sin_value  : OUT SIGNED(31 DOWNTO 0);
            cos_value  : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

  COMPONENT shift_register IS
        GENERIC(
            data_len   : INTEGER;
            delay_len  : INTEGER
        );
        PORT(
            clk        : IN  STD_LOGIC;
            reset      : IN  STD_LOGIC;
            sig_in     : IN  SIGNED(data_len - 1 DOWNTO 0);
            sig_delay  : OUT SIGNED(data_len - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT sogi
        PORT (
            clk    : IN  STD_LOGIC;
            reset  : IN  STD_LOGIC;
            v_in   : IN  SIGNED(31 DOWNTO 0);
            v_out  : OUT SIGNED(31 DOWNTO 0);
            qv_out : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT psc
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
    END COMPONENT;

BEGIN

    clarke_inst : clarke_transform
        PORT MAP (
            clk      => clk,
            reset    => reset,
            v_a      => v_a,
            v_b      => v_b,
            v_c      => v_c,
            v_alpha  => v_alpha,
            v_beta   => v_beta
        );

    cordic_inst : cordic_sin_cos
        GENERIC MAP (
            iterations => 16
        )
        PORT MAP (
            clk        => clk,
            reset      => reset,
            theta      => theta,
            sin_value  => sin_val,
            cos_value  => cos_val
        );
        
    shift_reg_alpha : shift_register
        GENERIC MAP(
            data_len   => 32,
            delay_len  => 14
        )
        PORT MAP(
            clk        => clk,
            reset      => reset,
            sig_in     => sogi_alpha,
            sig_delay  => v_alpha_delayed
        );
        
     shift_reg_beta : shift_register
        GENERIC MAP(
            data_len   => 32,
            delay_len  => 14
        )
        PORT MAP(
            clk        => clk,
            reset      => reset,
            sig_in     => sogi_beta,
            sig_delay  => v_beta_delayed
        );

    psc_inst : psc
        PORT MAP (
            clk      => clk,
            reset    => reset,
            alpha_v  => alpha_v,
            alpha_qv => alpha_qv,
            beta_v   => beta_v,
            beta_qv  => beta_qv,
            alpha    => sogi_alpha,
            beta     => sogi_beta
        );

    sogi_alpha_inst : sogi
        PORT MAP (
            clk    => clk,
            reset  => reset,
            v_in   => v_alpha,
            v_out  => alpha_v,
            qv_out => alpha_qv
        );

    sogi_beta_inst : sogi
        PORT MAP (
            clk    => clk,
            reset  => reset,
            v_in   => v_beta,
            v_out  => beta_v,
            qv_out => beta_qv
        );

    PROCESS(clk)
    BEGIN
        IF reset = '1' THEN
            v_d_int <= (OTHERS => '0');
            v_q_int <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            v_d_int <= v_alpha_delayed * cos_val + v_beta_delayed  * sin_val;
            v_q_int <= v_beta_delayed  * cos_val - v_alpha_delayed  * sin_val;
        END IF;
    END PROCESS;

    v_d <= v_d_int(63 DOWNTO 32);
    v_q <= v_q_int(63 DOWNTO 32);

END Behavioral;
