
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

CONSTANT time_scale : SIGNED(31 DOWNTO 0) := x"17d78400";

SIGNAL duty_cycle_HB1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL duty_cycle_HB2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL duty_cycle_HB3 : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL HB1_mult_reg : SIGNED(63 DOWNTO 0);
SIGNAL HB1_shift_reg : SIGNED(63 DOWNTO 0);

SIGNAL HB2_mult_reg : SIGNED(63 DOWNTO 0);
SIGNAL HB2_shift_reg : SIGNED(63 DOWNTO 0);

SIGNAL HB3_mult_reg : SIGNED(63 DOWNTO 0);
SIGNAL HB3_shift_reg : SIGNED(63 DOWNTO 0);

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
    variable switch_calc_1 : signed(31 downto 0);
    variable switch_calc_2 : signed(31 downto 0);
    variable switch_calc_3 : signed(31 downto 0);
    variable switch_calc_4 : signed(31 downto 0);
    variable switch_calc_slice : signed(63 downto 0);
    variable switch_calc_slice2 : signed(63 downto 0);
BEGIN
    switch_calc_slice := shift_right(T0,1);
    switch_calc_1 := T1(63 DOWNTO 32) + T2(63 DOWNTO 32) + switch_calc_slice(63 DOWNTO 32);
    switch_calc_2 := T2(63 DOWNTO 32) + shift_right(T0(63 DOWNTO 32),1);
    switch_calc_3 := switch_calc_slice(63 DOWNTO 32);
    switch_calc_4 := T1(63 DOWNTO 32) + shift_right(T0(63 DOWNTO 32),1);   
 CASE sector IS
        WHEN "001" =>
            HB1_mult_reg <= switch_calc_1 * time_scale;
            HB1_shift_reg <= shift_right(HB1_mult_reg,35);          
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(HB1_shift_reg,16)); 
            
            HB2_mult_reg <= switch_calc_2 * time_scale;
            HB2_shift_reg <= shift_right(HB2_mult_reg,35);
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(HB2_shift_reg,16)); 
            
            HB3_mult_reg <= switch_calc_3 * time_scale;
            HB3_shift_reg <= shift_right(HB3_mult_reg,35);
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(HB3_shift_reg,16)); 

        WHEN "010" =>
            HB1_mult_reg <= switch_calc_4 * time_scale;
            HB1_shift_reg <= shift_right(HB1_mult_reg,35);          
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(HB1_shift_reg,16)); 
            
            HB2_mult_reg <= switch_calc_1 * time_scale;
            HB2_shift_reg <= shift_right(HB2_mult_reg,35);
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(HB2_shift_reg,16)); 
            
            HB3_mult_reg <= switch_calc_3 * time_scale;
            HB3_shift_reg <= shift_right(HB3_mult_reg,35);
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(HB3_shift_reg,16));

        WHEN "011" =>
            HB1_mult_reg <= switch_calc_3 * time_scale;
            HB1_shift_reg <= shift_right(HB1_mult_reg,35);          
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(HB1_shift_reg,16)); 
            
            HB2_mult_reg <= switch_calc_1 * time_scale;
            HB2_shift_reg <= shift_right(HB2_mult_reg,35);
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(HB2_shift_reg,16)); 
            
            HB3_mult_reg <= switch_calc_2 * time_scale;
            HB3_shift_reg <= shift_right(HB3_mult_reg,35);
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(HB3_shift_reg,16));
        
        WHEN "100" =>
            HB1_mult_reg <= switch_calc_3 * time_scale;
            HB1_shift_reg <= shift_right(HB1_mult_reg,35);          
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(HB1_shift_reg,16)); 
            
            HB2_mult_reg <= switch_calc_4 * time_scale;
            HB2_shift_reg <= shift_right(HB2_mult_reg,35);
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(HB2_shift_reg,16)); 
            
            HB3_mult_reg <= switch_calc_1 * time_scale;
            HB3_shift_reg <= shift_right(HB3_mult_reg,35);
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(HB3_shift_reg,16));

        WHEN "101" =>
            HB1_mult_reg <= switch_calc_2 * time_scale;
            HB1_shift_reg <= shift_right(HB1_mult_reg,35);          
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(HB1_shift_reg,16)); 
            
            HB2_mult_reg <= switch_calc_3 * time_scale;
            HB2_shift_reg <= shift_right(HB2_mult_reg,35);
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(HB2_shift_reg,16)); 
            
            HB3_mult_reg <= switch_calc_1 * time_scale;
            HB3_shift_reg <= shift_right(HB3_mult_reg,35);
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(HB3_shift_reg,16));

        WHEN OTHERS =>
            HB1_mult_reg <= switch_calc_1 * time_scale;
            HB1_shift_reg <= shift_right(HB1_mult_reg,35);          
            duty_cycle_HB1 <= STD_LOGIC_VECTOR(resize(HB1_shift_reg,16)); 
            
            HB2_mult_reg <= switch_calc_3 * time_scale;
            HB2_shift_reg <= shift_right(HB2_mult_reg,35);
            duty_cycle_HB2 <= STD_LOGIC_VECTOR(resize(HB2_shift_reg,16)); 
            
            HB3_mult_reg <= switch_calc_4 * time_scale;
            HB3_shift_reg <= shift_right(HB3_mult_reg,35);
            duty_cycle_HB3 <= STD_LOGIC_VECTOR(resize(HB3_shift_reg,16));

    END CASE;
END PROCESS;   
                   
end Behavioral;
