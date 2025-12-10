LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY switching_time_processor IS
    PORT(
        clk         : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        angle       : IN  SIGNED(31 DOWNTO 0); -- 28 bin point
        vref        : IN  SIGNED(31 DOWNTO 0); -- 26 bin point
        sector      : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        t0          : OUT SIGNED(63 DOWNTO 0);
        t1          : OUT SIGNED(63 DOWNTO 0);
        t2          : OUT SIGNED(63 DOWNTO 0);
        sector_out  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END switching_time_processor;

ARCHITECTURE Behavioral OF switching_time_processor IS

    COMPONENT cordic_sin_cos
        GENERIC(
            iterations : INTEGER
        );
        PORT(
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

    COMPONENT shift_register_std IS
        GENERIC(
            data_len   : INTEGER;
            delay_len  : INTEGER
        );
        PORT(
            clk        : IN  STD_LOGIC;
            reset      : IN  STD_LOGIC;
            sig_in     : IN  STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0);
            sig_delay  : OUT STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0)
        );
    END COMPONENT;

    TYPE fsm IS (calculate_t1, calculate_t2);
    SIGNAL state : fsm;

    SIGNAL theta_T1      : SIGNED(31 DOWNTO 0);
    SIGNAL theta_T2      : SIGNED(31 DOWNTO 0);
    SIGNAL sin_val_T1    : SIGNED(31 DOWNTO 0);
    SIGNAL sin_val_T2    : SIGNED(31 DOWNTO 0);
    SIGNAL t1_int        : SIGNED(63 DOWNTO 0);
    SIGNAL t2_int        : SIGNED(63 DOWNTO 0);
    SIGNAL t1_delay      : SIGNED(63 DOWNTO 0);

    SIGNAL t1_mult_reg   : SIGNED(63 DOWNTO 0); -- 56
    SIGNAL t1_mult_reg2  : SIGNED(63 DOWNTO 0);
    SIGNAL t1_slice_reg  : SIGNED(31 DOWNTO 0);
    SIGNAL t1_shift_reg  : SIGNED(63 DOWNTO 0);
    SIGNAL t1_delay_reg  : SIGNED(63 DOWNTO 0);

    SIGNAL t2_mult_reg   : SIGNED(63 DOWNTO 0);
    SIGNAL t2_mult_reg2  : SIGNED(63 DOWNTO 0);
    SIGNAL t2_slice_reg  : SIGNED(31 DOWNTO 0);
    SIGNAL t2_shift_reg  : SIGNED(63 DOWNTO 0);
    SIGNAL t2_delay_reg  : SIGNED(63 DOWNTO 0);

    SIGNAL vref_delay    : SIGNED(31 DOWNTO 0);

    CONSTANT PI_3    : SIGNED(31 DOWNTO 0) := X"10C15238";
    CONSTANT PI2_3   : SIGNED(31 DOWNTO 0) := X"2182A470";
    CONSTANT PI      : SIGNED(31 DOWNTO 0) := X"3243F6A9";
    CONSTANT PI4_3   : SIGNED(31 DOWNTO 0) := X"430548E1";
    CONSTANT PI5_3   : SIGNED(31 DOWNTO 0) := X"53C69B19";
    CONSTANT PI2     : SIGNED(31 DOWNTO 0) := X"6487ED51";

    CONSTANT M       : SIGNED(31 DOWNTO 0) := X"000114c1"; --31 bin point = [Tz*sqrt(3)]/Vdc
    CONSTANT TZ      : SIGNED(63 DOWNTO 0) := X"00022F3D8FED7049"; -- 63 bin point = 1/fs

BEGIN

    cordic_inst_T1 : cordic_sin_cos
        GENERIC MAP(
            iterations => 16
        )
        PORT MAP(
            clk        => clk,
            reset      => reset,
            theta      => theta_T1,
            sin_value  => sin_val_T1,
            cos_value  => OPEN
        );
        
    cordic_inst_T2 : cordic_sin_cos
        GENERIC MAP(
            iterations => 16
        )
        PORT MAP(
            clk        => clk,
            reset      => reset,
            theta      => theta_T2,
            sin_value  => sin_val_T2,
            cos_value  => OPEN
        );

    shift_reg_vref : shift_register
        GENERIC MAP(
            data_len   => 32,
            delay_len  => 16
        )
        PORT MAP(
            clk        => clk,
            reset      => reset,
            sig_in     => vref,
            sig_delay  => vref_delay
        );

    shift_reg_sector : shift_register_std
        GENERIC MAP(
            data_len   => 3,
            delay_len  => 21
        )
        PORT MAP(
            clk        => clk,
            reset      => reset,
            sig_in     => sector,
            sig_delay  => sector_out
        );

    PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset = '1' THEN
                theta_T2      <= (OTHERS => '0');
                t2_mult_reg   <= (OTHERS => '0');
                t2_mult_reg2  <= (OTHERS => '0');
                t2_slice_reg  <= (OTHERS => '0');
                t2_shift_reg  <= (OTHERS => '0');

            ELSE
                    IF    sector = "001" THEN theta_T2 <= PI_3    - angle;
                    ELSIF sector = "010" THEN theta_T2 <= PI2_3   - angle;
                    ELSIF sector = "011" THEN theta_T2 <= PI      - angle;
                    ELSIF sector = "100" THEN theta_T2 <= PI4_3   - angle;
                    ELSIF sector = "101" THEN theta_T2 <= PI5_3   - angle;
                    ELSIF sector = "110" THEN theta_T2 <= PI2     - angle;
                    END IF;

                    t2_mult_reg   <= vref_delay * sin_val_T2;
                    t2_slice_reg  <= t2_mult_reg(63 DOWNTO 32);
                    t2_mult_reg2  <= M * t2_slice_reg;
                    t2_shift_reg  <= SHIFT_LEFT(t2_mult_reg2, 10);
            END IF;
        END IF;
 END PROCESS;
                
 PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset = '1' THEN
                t1_delay      <= (OTHERS => '0');
                t1_mult_reg   <= (OTHERS => '0');
                t1_mult_reg2  <= (OTHERS => '0');
                t1_slice_reg  <= (OTHERS => '0');
                t1_shift_reg  <= (OTHERS => '0');
            ELSE
                    IF    sector = "001" THEN theta_T1 <= angle;
                    ELSIF sector = "010" THEN theta_T1 <= angle - PI_3;
                    ELSIF sector = "011" THEN theta_T1 <= angle - PI2_3;
                    ELSIF sector = "100" THEN theta_T1 <= angle - PI;
                    ELSIF sector = "101" THEN theta_T1 <= angle - PI4_3;
                    ELSIF sector = "110" THEN theta_T1 <= angle - PI5_3;
                    ELSE                      theta_T1 <= (OTHERS => '0');
                    END IF;

                    t1_mult_reg   <= vref_delay * sin_val_T1; -- 54
                    t1_slice_reg  <= t1_mult_reg(63 DOWNTO 32); -- 22
                    t1_mult_reg2  <= M * t1_slice_reg; --53
                    t1_shift_reg  <= SHIFT_LEFT(t1_mult_reg2, 10); --63            
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) then
            IF reset = '1' THEN 
                t1_int       <= (OTHERS => '0');
                t2_int       <= (OTHERS => '0');
            ELSE
                t2_int       <= t1_shift_reg;
                t1_int       <= t2_shift_reg; 
            END IF;
        END IF;
    END PROCESS;
    

    t0 <= TZ - t1_int - t2_int; --63
    t1 <= t1_int;
    t2 <= t2_int;

END Behavioral;
