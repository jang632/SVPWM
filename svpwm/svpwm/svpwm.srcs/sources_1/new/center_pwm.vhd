
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity center_pwm is
    PORT(
        clk        : IN STD_LOGIC;
        reset      : IN STD_LOGIC;
        duty_cycle : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pwm        : OUT STD_LOGIC;
        pwm_n      : OUT STD_LOGIC
        );  
end center_pwm;

architecture Behavioral of center_pwm is
    SIGNAL clk_count : unsigned(15 DOWNTO 0);
    SIGNAL duty_cycle_latch : unsigned(15 DOWNTO 0);
    SIGNAL up_down : STD_LOGIC;
begin

    PROCESS(clk)
    BEGIN
        IF(reset = '1') THEN
            clk_count <= (others => '0');
            up_down <= '1';
        ELSIF(rising_edge(clk)) THEN 
              
            IF(up_down = '1') THEN 
                clk_count <= clk_count + 1;  
            ELSE 
                clk_count <= clk_count - 1;
            END IF;
            
            IF(clk_count = to_unsigned(1, clk_count'length)) THEN 
                up_down <= '1';
                duty_cycle_latch <= unsigned(duty_cycle);
            ELSIF(clk_count = to_unsigned(3332, clk_count'length)) THEN 
                up_down <= '0';
            END IF;
            
            IF(clk_count < unsigned(duty_cycle_latch)) THEN 
                pwm <= '1';
                pwm_n <= '0';
            ELSE 
                pwm <= '0';
                pwm_n <= '1';
            END IF;           
         END IF;            
    END PROCESS;      

end Behavioral;
