library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cordic_sin_cos is
    PORT(
        clk       : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        theta     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sin_value : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        cos_value : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        iterations: IN INTEGER RANGE 1 TO 16
    );     
end cordic_sin_cos;

architecture Behavioral of cordic_sin_cos is

    SIGNAL index : INTEGER RANGE 0 TO ITERATIONS;

    type pipelined_IO is record 
        pip_theta    : signed(31 DOWNTO 0);
        pip_sin      : signed(31 DOWNTO 0);
        pip_cos      : signed(31 DOWNTO 0);
        pip_quadrant : STD_LOGIC_VECTOR(1 DOWNTO 0);
    end record pipelined_IO;

    TYPE pipe_stages is array (0 to 15) of pipelined_IO;
    SIGNAL pipeline : pipe_stages;

    constant PI_OVER_2        : signed(31 downto 0) := to_signed(421657429, 32);  -- π/2
    constant PI               : signed(31 downto 0) := to_signed(843314857, 32);  -- π
    constant THREE_PI_OVER_2  : signed(31 downto 0) := to_signed(1264972286, 32); -- 3π/2
    constant TWO_PI           : signed(31 downto 0) := to_signed(1686629714, 32); -- 2π

    type angle_array is array (0 to 15) of signed(31 downto 0);  
    signal angles : angle_array := (
        0  => to_signed(integer(0.7853981633974483 * 268435456.0), 32),  -- 45°
        1  => to_signed(integer(0.4636476090008061 * 268435456.0), 32),  -- 26.565°
        2  => to_signed(integer(0.24497866312686414 * 268435456.0), 32), -- 14.036°
        3  => to_signed(integer(0.12435499454676144 * 268435456.0), 32), -- 7.125°
        4  => to_signed(integer(0.06241880999595735 * 268435456.0), 32), -- 3.576°
        5  => to_signed(integer(0.031239833430268277 * 268435456.0), 32),-- 1.790°
        6  => to_signed(integer(0.015623728620476831 * 268435456.0), 32),-- 0.895°
        7  => to_signed(integer(0.007812341060101111 * 268435456.0), 32),-- 0.448°
        8  => to_signed(integer(0.0039062301319669718 * 268435456.0), 32),-- 0.224°
        9  => to_signed(integer(0.0019531225164788188 * 268435456.0), 32),-- 0.112°
        10 => to_signed(integer(0.0009765621895593195 * 268435456.0), 32),-- 0.056°
        11 => to_signed(integer(0.0004882812111948983 * 268435456.0), 32),-- 0.028°
        12 => to_signed(integer(0.00024414062014936177 * 268435456.0), 32),-- 0.014°
        13 => to_signed(integer(0.00012207031189367021 * 268435456.0), 32),-- 0.007°
        14 => to_signed(integer(6.103515617420877e-05 * 268435456.0), 32),-- 0.0035°
        15 => to_signed(integer(3.0517578115526096e-05 * 268435456.0), 32) -- 0.00175°
    );

begin

    PROCESS(clk)
    BEGIN 
        IF reset = '1' THEN 
            pipeline <= (others => ((others => '0'), (others => '0'), (others => '0'), (others => '0')));
        ELSIF rising_edge(clk) THEN
            IF signed(theta) < PI_OVER_2 THEN
                pipeline(0).pip_theta    <= signed(theta);
                pipeline(0).pip_quadrant <= "00";
            ELSIF signed(theta) <= PI THEN
                pipeline(0).pip_theta    <= PI - signed(theta);
                pipeline(0).pip_quadrant <= "01";
            ELSIF signed(theta) <= THREE_PI_OVER_2 THEN
                pipeline(0).pip_theta    <= signed(theta) - PI;
                pipeline(0).pip_quadrant <= "10";
            ELSIF signed(theta) <= TWO_PI THEN 
                pipeline(0).pip_theta    <= TWO_PI - signed(theta);
                pipeline(0).pip_quadrant <= "11";
            ELSE 
                pipeline(0).pip_theta    <= (others => '0');
                pipeline(0).pip_quadrant <= "11";
            END IF;

            pipeline(0).pip_cos <= x"09B74A7D"; 
            pipeline(0).pip_sin <= (others => '0');

            FOR i IN 0 TO iterations - 2 LOOP 
                IF pipeline(i).pip_theta < 0 THEN                               
                    pipeline(i+1).pip_cos      <= pipeline(i).pip_cos + shift_right(pipeline(i).pip_sin, i);
                    pipeline(i+1).pip_sin      <= pipeline(i).pip_sin - shift_right(pipeline(i).pip_cos, i);
                    pipeline(i+1).pip_quadrant <= pipeline(i).pip_quadrant;
                    pipeline(i+1).pip_theta    <= pipeline(i).pip_theta + angles(i);                             
                ELSE
                    pipeline(i+1).pip_sin      <= pipeline(i).pip_sin + shift_right(pipeline(i).pip_cos, i);
                    pipeline(i+1).pip_cos      <= pipeline(i).pip_cos - shift_right(pipeline(i).pip_sin, i);
                    pipeline(i+1).pip_quadrant <= pipeline(i).pip_quadrant;
                    pipeline(i+1).pip_theta    <= pipeline(i).pip_theta - angles(i);                             
                END IF;                            
            END LOOP;             
        END IF;
    END PROCESS;  
    
    PROCESS(pipeline(15).pip_sin, pipeline(15).pip_cos)
    BEGIN
        CASE pipeline(15).pip_quadrant IS
            WHEN "00" =>
                sin_value <= STD_LOGIC_VECTOR(pipeline(iterations - 1).pip_sin);
                cos_value <= STD_LOGIC_VECTOR(pipeline(iterations - 1).pip_cos);
            WHEN "01" =>
                sin_value <= STD_LOGIC_VECTOR(pipeline(iterations - 1).pip_sin);
                cos_value <= STD_LOGIC_VECTOR(-pipeline(iterations - 1).pip_cos);
            WHEN "10" =>
                sin_value <= STD_LOGIC_VECTOR(-pipeline(iterations - 1).pip_sin);
                cos_value <= STD_LOGIC_VECTOR(-pipeline(iterations - 1).pip_cos);
            WHEN OTHERS =>
                sin_value <= STD_LOGIC_VECTOR(-pipeline(iterations - 1).pip_sin);
                cos_value <= STD_LOGIC_VECTOR(pipeline(iterations - 1).pip_cos);
        END CASE;
    END PROCESS;
           
end Behavioral;