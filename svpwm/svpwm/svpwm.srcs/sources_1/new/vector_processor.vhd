library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY vector_processor IS
    GENERIC (
        iterations : INTEGER := 16
    );
    PORT (
        clk        : IN  STD_LOGIC;
        reset      : IN  STD_LOGIC;
        x          : IN  SIGNED(31 DOWNTO 0);  -- 28 binary point
        y          : IN  SIGNED(31 DOWNTO 0);  -- 28 binary point
        angle      : OUT SIGNED(31 DOWNTO 0);  -- 28 binary point
        magnitude  : OUT SIGNED(31 DOWNTO 0);  -- 26 binary point
        sector     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END vector_processor;

ARCHITECTURE Behavioral OF vector_processor IS

    TYPE pipelined_io IS RECORD
        pip_y        : SIGNED(33 DOWNTO 0);
        pip_x        : SIGNED(33 DOWNTO 0);
        pip_z        : SIGNED(31 DOWNTO 0);
        pip_quadrant : STD_LOGIC_VECTOR(1 DOWNTO 0);
    END RECORD;

    TYPE pipe_stages IS ARRAY (0 TO 15) OF pipelined_io;
    SIGNAL pipeline : pipe_stages;

    SIGNAL magnitude_int     : SIGNED(63 DOWNTO 0);
    SIGNAL angle_int         : SIGNED(31 DOWNTO 0);
    SIGNAL sector_int        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL angle_stage1      : SIGNED(31 DOWNTO 0);
    SIGNAL angle_stage2      : SIGNED(31 DOWNTO 0);

    SIGNAL x_reg             : SIGNED(33 DOWNTO 0);
    SIGNAL y_reg             : SIGNED(33 DOWNTO 0);
    SIGNAL quadrant_reg      : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL mult_reg          : SIGNED(65 DOWNTO 0);
    SIGNAL shift_reg         : SIGNED(65 DOWNTO 0);
    SIGNAL add_reg           : SIGNED(65 DOWNTO 0);
    SIGNAL mult_reg_pipe     : SIGNED(65 DOWNTO 0);
    SIGNAL shift_reg_pipe    : SIGNED(65 DOWNTO 0);

    CONSTANT PI              : SIGNED(31 DOWNTO 0) := x"3243F6A9";
    CONSTANT TWO_PI          : SIGNED(31 DOWNTO 0) := x"6487ED51";

    CONSTANT DEG_60          : SIGNED(31 DOWNTO 0) := x"10C15238";
    CONSTANT DEG_120         : SIGNED(31 DOWNTO 0) := x"2182A470";
    CONSTANT DEG_180         : SIGNED(31 DOWNTO 0) := x"3243F6A9";
    CONSTANT DEG_240         : SIGNED(31 DOWNTO 0) := x"430548E1";
    CONSTANT DEG_300         : SIGNED(31 DOWNTO 0) := x"53C69B19";

    CONSTANT NEAR_ZERO       : SIGNED(31 DOWNTO 0) := x"000012E0";
    CONSTANT NEG_NEAR_ZERO   : SIGNED(31 DOWNTO 0) := x"FFFFED20";

    CONSTANT cordic_const    : SIGNED(31 DOWNTO 0) := x"01B74EDB";

    TYPE angle_delay_array IS ARRAY (0 TO 1) OF SIGNED(31 DOWNTO 0);
    SIGNAL angle_delay       : angle_delay_array;

    SIGNAL sector_delay      : STD_LOGIC_VECTOR(2 DOWNTO 0);

    TYPE angle_array IS ARRAY (0 TO 15) OF SIGNED(31 DOWNTO 0);
    SIGNAL angles : angle_array := (
        0  => to_signed(INTEGER(0.7853981633974483   * 268435456.0), 32),
        1  => to_signed(INTEGER(0.4636476090008061   * 268435456.0), 32),
        2  => to_signed(INTEGER(0.24497866312686414  * 268435456.0), 32),
        3  => to_signed(INTEGER(0.12435499454676144  * 268435456.0), 32),
        4  => to_signed(INTEGER(0.06241880999595735  * 268435456.0), 32),
        5  => to_signed(INTEGER(0.031239833430268277 * 268435456.0), 32),
        6  => to_signed(INTEGER(0.015623728620476831 * 268435456.0), 32),
        7  => to_signed(INTEGER(0.007812341060101111 * 268435456.0), 32),
        8  => to_signed(INTEGER(0.003906230131966972 * 268435456.0), 32),
        9  => to_signed(INTEGER(0.001953122516478819 * 268435456.0), 32),
        10 => to_signed(INTEGER(0.000976562189559320 * 268435456.0), 32),
        11 => to_signed(INTEGER(0.000488281211194898 * 268435456.0), 32),
        12 => to_signed(INTEGER(0.000244140620149362 * 268435456.0), 32),
        13 => to_signed(INTEGER(0.000122070311893670 * 268435456.0), 32),
        14 => to_signed(INTEGER(0.000061035156174209 * 268435456.0), 32),
        15 => to_signed(INTEGER(0.000030517578115526 * 268435456.0), 32)
    );

BEGIN
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                x_reg        <= (OTHERS => '0');
                y_reg        <= (OTHERS => '0');
                quadrant_reg <= (OTHERS => '0');
            ELSE
                IF signed(x) > 0 AND signed(y) > 0 THEN
                    x_reg        <= resize(signed(x), 34);
                    y_reg        <= resize(signed(y), 34);
                    quadrant_reg <= "00";
                ELSIF signed(x) <= 0 AND signed(y) >= 0 THEN
                    x_reg        <= -resize(signed(x), 34);
                    y_reg        <= -resize(signed(y), 34);
                    quadrant_reg <= "01";
                ELSIF signed(x) < 0 AND signed(y) < 0 THEN
                    x_reg        <= -resize(signed(x), 34);
                    y_reg        <= -resize(signed(y), 34);
                    quadrant_reg <= "10";
                ELSE
                    x_reg        <= resize(signed(x), 34);
                    y_reg        <= resize(signed(y), 34);
                    quadrant_reg <= "11";
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                pipeline <= (OTHERS => ((OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0')));
            ELSE
                pipeline(0).pip_y        <= y_reg;
                pipeline(0).pip_x        <= x_reg;
                pipeline(0).pip_quadrant <= quadrant_reg;
                pipeline(0).pip_z        <= (OTHERS => '0');

                FOR i IN 0 TO iterations - 2 LOOP
                    IF pipeline(i).pip_y < 0 THEN
                        pipeline(i+1).pip_y <= pipeline(i).pip_y + shift_right(pipeline(i).pip_x, i);
                        pipeline(i+1).pip_x <= pipeline(i).pip_x - shift_right(pipeline(i).pip_y, i);
                        pipeline(i+1).pip_z <= pipeline(i).pip_z - angles(i);
                    ELSE
                        pipeline(i+1).pip_y <= pipeline(i).pip_y - shift_right(pipeline(i).pip_x, i);
                        pipeline(i+1).pip_x <= pipeline(i).pip_x + shift_right(pipeline(i).pip_y, i);
                        pipeline(i+1).pip_z <= pipeline(i).pip_z + angles(i);
                    END IF;
                    pipeline(i+1).pip_quadrant <= pipeline(i).pip_quadrant;
                END LOOP;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                angle_int        <= (OTHERS => '0');
                add_reg          <= (OTHERS => '0');
                mult_reg         <= (OTHERS => '0');
                shift_reg        <= (OTHERS => '0');
                mult_reg_pipe    <= (OTHERS => '0');
                shift_reg_pipe   <= (OTHERS => '0');
            ELSE
                CASE pipeline(iterations - 1).pip_quadrant IS
                    WHEN "00" =>
                        angle_int <= pipeline(iterations - 1).pip_z;
                    WHEN "01" | "10" =>
                        angle_int <= pipeline(iterations - 1).pip_z + PI;
                    WHEN OTHERS =>
                        IF pipeline(iterations - 1).pip_z < NEAR_ZERO AND pipeline(iterations - 1).pip_z > NEG_NEAR_ZERO THEN
                            angle_int <= (OTHERS => '0');
                        ELSE
                            angle_int <= pipeline(iterations - 1).pip_z + TWO_PI;
                        END IF;
                END CASE;

                mult_reg        <= pipeline(iterations - 1).pip_x * cordic_const;
                shift_reg       <= resize(shift_right(pipeline(iterations - 1).pip_x, 1), 66);
                mult_reg_pipe   <= mult_reg;
                shift_reg_pipe  <= shift_reg;
                add_reg         <= shift_right(mult_reg_pipe, 28) + shift_reg_pipe;
            END IF;
        END IF;
    END PROCESS;

    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                angle        <= (OTHERS => '0');
                magnitude    <= (OTHERS => '0');
                sector       <= "000";
                angle_stage1 <= (OTHERS => '0');
                angle_stage2 <= (OTHERS => '0');
                angle_delay  <= (OTHERS => (OTHERS => '0'));
            ELSE
                IF angle_int < DEG_60 OR angle_int = x"00000000" THEN
                    sector_int <= "001";
                ELSIF angle_int < DEG_120 THEN
                    sector_int <= "010";
                ELSIF angle_int < DEG_180 THEN
                    sector_int <= "011";
                ELSIF angle_int < DEG_240 THEN
                    sector_int <= "100";
                ELSIF angle_int < DEG_300 THEN
                    sector_int <= "101";
                ELSE
                    sector_int <= "110";
                END IF;

                IF pipeline(iterations - 1).pip_x /= 0 AND pipeline(iterations - 1).pip_y /= 0 THEN
                    angle_delay  <= angle_int & angle_delay(0);
                    angle        <= angle_delay(1);
                    sector_delay <= sector_int;
                    sector       <= sector_delay;
                    magnitude    <= add_reg(33 DOWNTO 2);
                ELSE
                    angle     <= (OTHERS => '0');
                    magnitude <= (OTHERS => '0');
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;
