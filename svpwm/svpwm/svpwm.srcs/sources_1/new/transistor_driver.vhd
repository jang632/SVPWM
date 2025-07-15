----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2025 20:21:21
-- Design Name: 
-- Module Name: transistor_driver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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

CONSTANT time_scale : signed(31 DOWNTO 0) := x"2faf07f8";

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
PROCESS(sector, T0, T1, T2, time_scale)
    variable tmp_val : signed(63 downto 0);
    variable shifted_val : signed(63 downto 0);
BEGIN
    -- Najpierw wyliczamy shift_right(T0,1) * time_scale, aby uniknąć powtórzeń
    switch_calc_1 := T1 + T2 + shift_right(T0,1);
    switch_calc_2 := T2 + shift_right(T0,1);
    switch_calc_3 := shift_right(T0,1);
    switch_calc_4 := T1 + shift_right(T0,1);
    
 case sector is
        when "001" =>
            tmp_val := (T1 + T2 + shifted_val); 
            duty_cycle_HB1 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T2 + shifted_val);
            duty_cycle_HB2 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := shifted_val;
            duty_cycle_HB3 <= resize(shift_left(tmp_val, 67), 16);

        when "010" =>
            tmp_val := (T1 + shifted_val);
            duty_cycle_HB1 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T1 + T2 + shifted_val);
            duty_cycle_HB2 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := shifted_val;
            duty_cycle_HB3 <= resize(shift_left(tmp_val, 67), 16);

        when "011" =>
            tmp_val := shifted_val;
            duty_cycle_HB1 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T1 + T2 + shifted_val);
            duty_cycle_HB2 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T2 + shifted_val);
            duty_cycle_HB3 <= resize(shift_left(tmp_val, 67), 16);

        when "100" =>
            tmp_val := shifted_val;
            duty_cycle_HB1 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T1 + shifted_val);
            duty_cycle_HB2 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T1 + T2 + shifted_val);
            duty_cycle_HB3 <= resize(shift_left(tmp_val, 67), 16);

        when "101" =>
            tmp_val := (T2 + shifted_val);
            duty_cycle_HB1 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := shifted_val;
            duty_cycle_HB2 <= resize(shift_left(tmp_val, 67), 16);
            tmp_val := (T1 + T2 + shifted_val);
            duty_cycle_HB3 <= resize(shift_left(tmp_val, 67), 16);

        when others =>
            tmp_val := (T1 + T2 + shifted_val);
            duty_cycle_HB1 <= resize(shift_left(tmp_val, 67), 16);
            duty_cycle_HB2 <= resize(shift_left(shifted_val, 67), 16);
            duty_cycle_HB3 <= resize(shift_left((T1 + shifted_val), 67), 16);
    end case;
                   
end Behavioral;
