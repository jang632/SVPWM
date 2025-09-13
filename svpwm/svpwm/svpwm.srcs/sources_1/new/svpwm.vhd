library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY svpwm IS
    PORT (
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        v_a      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
        v_b      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_c      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        HB1_top  : OUT STD_LOGIC;
        HB1_bot  : OUT STD_LOGIC;
        HB2_top  : OUT STD_LOGIC;
        HB2_bot  : OUT STD_LOGIC;
        HB3_top  : OUT STD_LOGIC;
        HB3_bot  : OUT STD_LOGIC
    );
END svpwm;

ARCHITECTURE Behavioral OF svpwm IS

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

    COMPONENT vector_processor IS
        GENERIC (
            iterations : INTEGER := 8
        );
        PORT (
            clk        : IN  STD_LOGIC;
            reset      : IN  STD_LOGIC;
            angle_in   : IN  SIGNED(31 DOWNTO 0);
            x          : IN  SIGNED(31 DOWNTO 0);
            y          : IN  SIGNED(31 DOWNTO 0);
            angle      : OUT SIGNED(31 DOWNTO 0);
            magnitude  : OUT SIGNED(31 DOWNTO 0);
            sector     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );     
    END COMPONENT;

    COMPONENT switching_time_processor
        PORT (
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            angle       : IN  SIGNED(31 DOWNTO 0);
            vref        : IN  SIGNED(31 DOWNTO 0);
            sector      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            T0          : OUT SIGNED(63 DOWNTO 0);
            T1          : OUT SIGNED(63 DOWNTO 0);
            T2          : OUT SIGNED(63 DOWNTO 0);
            sector_out  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT transistor_driver
        PORT (
            clk      : IN  STD_LOGIC;
            reset    : IN  STD_LOGIC;
            T0       : IN  SIGNED(63 DOWNTO 0);
            T1       : IN  SIGNED(63 DOWNTO 0);
            T2       : IN  SIGNED(63 DOWNTO 0);
            sector   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            HB1_top  : OUT STD_LOGIC;
            HB1_bot  : OUT STD_LOGIC;
            HB2_top  : OUT STD_LOGIC;
            HB2_bot  : OUT STD_LOGIC;
            HB3_top  : OUT STD_LOGIC;
            HB3_bot  : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT srf_pll
        PORT (
            clk    : IN  STD_LOGIC;
            reset  : IN  STD_LOGIC;
            v_a    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_b    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_c    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            omega  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            phase  : OUT SIGNED(31 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL clk_pulse       : STD_LOGIC;

    SIGNAL angle_vec       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mag_vec         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL v_alpha         : SIGNED(31 DOWNTO 0);
    SIGNAL v_beta          : SIGNED(31 DOWNTO 0);
    SIGNAL x               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL y               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL angle           : SIGNED(31 DOWNTO 0);
    SIGNAL angle_srf           : SIGNED(31 DOWNTO 0);    
    SIGNAL magnitude       : SIGNED(31 DOWNTO 0);
    SIGNAL sector          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    CONSTANT iterations    : INTEGER RANGE 1 TO 16 := 16;
    SIGNAL vref            : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL T0              : SIGNED(63 DOWNTO 0);
    SIGNAL T1              : SIGNED(63 DOWNTO 0);
    SIGNAL T2              : SIGNED(63 DOWNTO 0);
    SIGNAL sector_delayed  : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

    PROCESS(clk)
    variable count : INTEGER RANGE 0 TO 900 := 0;
    BEGIN 
        IF(rising_edge(clk)) THEN 

                IF(count < 781) THEN 
                    count := count + 1;
                    clk_pulse <= '0';
                ELSE 
                    count := 0;
                    clk_pulse <= '1';
                END IF; 

        END IF; 
    END PROCESS;

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

    vector_proc_inst : vector_processor
        GENERIC MAP (
            iterations => 16
        )
        PORT MAP (
            clk      => clk,
            reset    => reset,
            angle_in => angle_srf,
            x        => v_alpha,
            y        => v_beta,
            angle    => angle,
            magnitude => magnitude,
            sector   => sector
        );

    time_processor_inst : switching_time_processor
        PORT MAP (
            clk         => clk,
            reset       => reset,
            angle       => angle,
            vref        => magnitude,
            sector      => sector,
            T0          => T0,
            T1          => T1,
            T2          => T2,
            sector_out  => sector_delayed
        );

    driver_inst : transistor_driver
        PORT MAP (
            clk      => clk,
            reset    => reset,
            T0       => T0,
            T1       => T1,
            T2       => T2,
            sector   => sector_delayed,
            HB1_top  => HB1_top,
            HB1_bot  => HB1_bot,
            HB2_top  => HB2_top,
            HB2_bot  => HB2_bot,
            HB3_top  => HB3_top,
            HB3_bot  => HB3_bot
        );
        
        srf_inst : srf_pll
        PORT MAP (
            clk   => clk_pulse,
            reset => reset,
            v_a   => v_a,
            v_b   => v_b,
            v_c   => v_c,
            omega => OPEN,
            phase => angle_srf
        );

END Behavioral;
