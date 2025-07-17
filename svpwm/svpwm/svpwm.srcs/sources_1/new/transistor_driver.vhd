
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transistor_driver is
    PORT( 
        clk     : IN STD_LOGIC;
        reset   : IN STD_LOGIC;
        T0      : IN signed(63 DOWNTO 0);
        T1      : IN signed(63 DOWNTO 0);
        T2      : IN signed(63 DOWNTO 0);
        sector  : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        HB1_top : OUT STD_LOGIC;
        HB1_bot : OUT STD_LOGIC;
        HB2_top : OUT STD_LOGIC;
        HB2_bot : OUT STD_LOGIC;
        HB3_top : OUT STD_LOGIC;
        HB3_bot : OUT STD_LOGIC
        );
end transistor_driver;

architecture Behavioral of transistor_driver is

component center_pwm is
    PORT(
        clk        : IN STD_LOGIC;
        reset      : IN STD_LOGIC;
        duty_cycle : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pwm        : OUT STD_LOGIC;
        pwm_n      : OUT STD_LOGIC
        );  
end component;

CONSTANT time_scale : signed(31 DOWNTO 0) := x"2faf07ff";

SIGNAL duty_cycle_HB1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL duty_cycle_HB2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL duty_cycle_HB3 : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

HB1 : center_pwm 
    PORT MAP(
        clk        => clk,
        reset      => reset,
        duty_cycle => duty_cycle_HB1,
        pwm        => HB1_top,
        pwm_n      => HB1_bot
        );  
        
HB2 : center_pwm 
    PORT MAP(
        clk        => clk,
        reset      => reset,
        duty_cycle => duty_cycle_HB2,
        pwm        => HB2_top,
        pwm_n      => HB2_bot
        );  

HB3 : center_pwm 
    PORT MAP(
        clk        => clk,
        reset      => reset,
        duty_cycle => duty_cycle_HB3,
        pwm        => HB3_top,
        pwm_n      => HB3_bot
        );  
        
PROCESS(clk)
    variable switch_calc_1 : signed(63 downto 0);
    variable switch_calc_2 : signed(63 downto 0);
    variable switch_calc_3 : signed(63 downto 0);
    variable switch_calc_4 : signed(63 downto 0);
    variable debug_var : signed(95 downto 0);
BEGIN
    switch_calc_1 := T1 + T2 + shift_right(T0,1);
    switch_calc_2 := T2 + shift_right(T0,1);
    switch_calc_3 := shift_right(T0,1);
    switch_calc_4 := T1 + shift_right(T0,1);   
 CASE sector IS
        WHEN "001" =>
            debug_var := shift_right(switch_calc_1 * time_scale,0);
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_1 * time_scale,67),16)); 
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_2 * time_scale,67),16)); 
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_3 * time_scale,67),16)); 

        WHEN "010" =>
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_4 * time_scale,67),16)); 
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_1 * time_scale,67),16)); 
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_3 * time_scale,67),16)); 

        WHEN "011" =>
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_3 * time_scale,67),16)); 
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_1 * time_scale,67),16)); 
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_2  * time_scale,67),16)); 

        WHEN "100" =>
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_3 * time_scale,67),16)); 
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_4 * time_scale,67),16)); 
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_1 * time_scale,67),16)); 

        WHEN "101" =>
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_2 * time_scale,67),16)); 
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_3 * time_scale,67),16)); 
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_1 * time_scale,67),16)); 

        WHEN OTHERS =>
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_1 * time_scale,67),16)); 
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_3 * time_scale,67),16)); 
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(shift_right(switch_calc_4 * time_scale,67),16)); 
    END CASE;
END PROCESS;   
                   
end Behavioral;
