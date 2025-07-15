library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_center_pwm is
end tb_center_pwm;

architecture Behavioral of tb_center_pwm is

    -- Komponent testowanego modułu
    component center_pwm
        PORT(
            clk        : IN STD_LOGIC;
            reset      : IN STD_LOGIC;
            duty_cycle : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            pwm        : OUT STD_LOGIC;
            pwm_n      : OUT STD_LOGIC
        );
    end component;

    -- Sygnały TB
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';
    signal duty_cycle : STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
    signal pwm        : STD_LOGIC;
    signal pwm_n      : STD_LOGIC;

    -- Parametry czasowe
    constant clk_period : time := 10 ns;  -- 100 MHz zegar

begin

    -- Instancja DUT (Device Under Test)
    uut: center_pwm
        port map (
            clk        => clk,
            reset      => reset,
            duty_cycle => duty_cycle,
            pwm        => pwm,
            pwm_n      => pwm_n
        );

    -- Generacja zegara
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Proces testowy
    stim_proc: process
    begin
        -- Reset
        wait for 20 ns;
        reset <= '0';

        -- Test 1: 25% wypełnienia
        duty_cycle <= std_logic_vector(to_unsigned(0, 16)); -- 25% z 3333
        wait for 300 us;

        -- Test 2: 50% wypełnienia
        duty_cycle <= std_logic_vector(to_unsigned(1333, 16)); -- 50%
        wait for 67 us;

        -- Test 3: 75% wypełnienia
        duty_cycle <= std_logic_vector(to_unsigned(1998, 16)); -- 75%
        wait for 67 us;

        -- Test 4: 0%
        duty_cycle <= std_logic_vector(to_unsigned(2664, 16));
        wait for 67 us;

        -- Test 5: 100%
        duty_cycle <= std_logic_vector(to_unsigned(3000, 16));
        wait for 67 us;

        -- Koniec symulacji
        wait;
    end process;

end Behavioral;
