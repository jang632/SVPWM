library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity vector_processor  is
    PORT(
        clk        : IN  STD_LOGIC;
        reset      : IN  STD_LOGIC;
        x          : IN  STD_LOGIC_VECTOR (31 DOWNTO 0); -- 28 binary point
        y          : IN  STD_LOGIC_VECTOR (31 DOWNTO 0); -- 28 binary point
        angle      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); -- 28 binary point
        magnitude  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); -- 26 binary point
        sector     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        iterations : IN  INTEGER RANGE 1 TO 16
    );     
end vector_processor ;

architecture Behavioral of vector_processor  is

    type pipelined_IO is record 
        pip_Y, pip_X      : signed(63 DOWNTO 0);
        pip_Z             : signed(31 DOWNTO 0);
        pip_quadrant      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    end record;

    type pipe_stages is array (0 to 15) of pipelined_IO;
    SIGNAL pipeline : pipe_stages;
    
    SIGNAL magnitude_int : signed(63 DOWNTO 0);
    SIGNAL angle_int : signed(31 DOWNTO 0);

    CONSTANT cordic_const : signed(63 DOWNTO 0) := x"0000000001b74edb";

    type angle_array is array (0 to 15) of signed(31 DOWNTO 0);
    signal angles : angle_array := (
        0  => to_signed(integer(0.7853981633974483 * 268435456.0), 32),  -- 45°
        1  => to_signed(integer(0.4636476090008061 * 268435456.0), 32),  -- 26.565°
        2  => to_signed(integer(0.24497866312686414 * 268435456.0), 32), -- 14.036°
        3  => to_signed(integer(0.12435499454676144 * 268435456.0), 32), -- 7.125°
        4  => to_signed(integer(0.06241880999595735 * 268435456.0), 32), -- 3.576°
        5  => to_signed(integer(0.031239833430268277 * 268435456.0), 32), -- 1.790°
        6  => to_signed(integer(0.015623728620476831 * 268435456.0), 32), -- 0.895°
        7  => to_signed(integer(0.007812341060101111 * 268435456.0), 32), -- 0.448°
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
            IF signed(x) > 0 AND signed(y) > 0 THEN 
                pipeline(0).pip_X       <= resize(signed(x), 64);
                pipeline(0).pip_Y       <= resize(signed(y), 64);
                pipeline(0).pip_quadrant <= "00";                      
            ELSIF signed(x) <= 0 AND signed(y) >= 0 THEN 
                pipeline(0).pip_X       <= -resize(signed(x), 64);
                pipeline(0).pip_Y       <= -resize(signed(y), 64);
                pipeline(0).pip_quadrant <= "01";                     
            ELSIF signed(x) < 0 AND signed(y) < 0 THEN 
                pipeline(0).pip_X       <= -resize(signed(x), 64);
                pipeline(0).pip_Y       <= -resize(signed(y), 64);
                pipeline(0).pip_quadrant <= "10";                       
            ELSIF signed(x) < 0 AND signed(y) < 0 THEN
                pipeline(0).pip_X       <= resize(signed(x), 64);
                pipeline(0).pip_Y       <= resize(signed(y), 64);
                pipeline(0).pip_quadrant <= "11";
            ELSE
                pipeline(0).pip_X       <= resize(signed(x), 64);
                pipeline(0).pip_Y       <= resize(signed(y), 64);
                pipeline(0).pip_quadrant <= "11";
            END IF;
            
            FOR i IN 0 TO 14 LOOP 
                IF pipeline(i).pip_Y < 0 THEN                                   
                    pipeline(i+1).pip_Y       <= pipeline(i).pip_Y + shift_right(pipeline(i).pip_X, i);
                    pipeline(i+1).pip_X       <= pipeline(i).pip_X - shift_right(pipeline(i).pip_Y, i);
                    pipeline(i+1).pip_quadrant <= pipeline(i).pip_quadrant;
                    pipeline(i+1).pip_Z       <= pipeline(i).pip_Z - angles(i);                             
                ELSE
                    pipeline(i+1).pip_Y       <= pipeline(i).pip_Y - shift_right(pipeline(i).pip_X, i);
                    pipeline(i+1).pip_X       <= pipeline(i).pip_X + shift_right(pipeline(i).pip_Y, i);
                    pipeline(i+1).pip_quadrant <= pipeline(i).pip_quadrant;
                    pipeline(i+1).pip_Z       <= pipeline(i).pip_Z + angles(i);                             
                END IF;       

                magnitude_int <= shift_right(pipeline(i+1).pip_X, 1) + shift_right(resize(pipeline(i+1).pip_X * cordic_const, 64), 28);              
            END LOOP;                           

        END IF;
    END PROCESS;  
    
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF pipeline(iterations - 1).pip_X = 0 AND pipeline(iterations - 1).pip_Y = 0 THEN 
                angle_int <= (others => '0');
                angle <= (others => '0');
                magnitude <= (others => '0');
                sector <= "000";
            ELSE 
                CASE pipeline(15).pip_quadrant IS
                    WHEN "00" => 
                        angle_int <= pipeline(iterations - 1).pip_Z ;
                    WHEN "01" => 
                        angle_int <= pipeline(iterations - 1).pip_Z + x"3243f6a9";
                    WHEN "10" =>
                        angle_int <= pipeline(iterations - 1).pip_Z + x"3243f6a9";
                    WHEN OTHERS => 
                        IF pipeline(iterations - 1).pip_Z < x"000012e0" and pipeline(iterations - 1).pip_Z > x"ffffed20" THEN 
                            angle_int <= x"00000000";
                        ELSE
                            angle_int <= pipeline(iterations - 1).pip_Z + x"6487ed51";
                        END IF;
                END CASE;
                
                IF angle_int < x"10c15238" or signed(angle_int) = x"00000000" THEN --60
                    sector <= "001";
                ELSIF angle_int < x"2182a470" THEN --120
                    sector <= "010";
                ELSIF angle_int < x"3243f6a9" THEN --180
                    sector <= "011";
                ELSIF angle_int < x"430548e1" THEN --240
                    sector <= "100";
                ELSIF angle_int < x"53c69b19" THEN --300
                    sector <= "101";
                ELSE
                    sector <= "110";
                END IF;
                
            angle <= STD_LOGIC_VECTOR(angle_int);
            magnitude <= STD_LOGIC_VECTOR(magnitude_int(33 DOWNTO 2));     
                
            END IF;
        END IF;
    END PROCESS; 
                

end Behavioral;
