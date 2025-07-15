library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_switching_time_processor is
end tb_switching_time_processor;

architecture behavior of tb_switching_time_processor is

    -- Komponent testowany
    component switching_time_processor
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            angle  : in  std_logic_vector(31 downto 0);
            Vref   : in  std_logic_vector(31 downto 0);
            sector : in  std_logic_vector(2 downto 0);
            T0     : out signed(63 downto 0);
            T1     : out signed(63 downto 0);
            T2     : out signed(63 downto 0);
            sector_delayed : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Sygnały testowe
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '1';
    signal angle   : std_logic_vector(31 downto 0);
    signal Vref    : std_logic_vector(31 downto 0);
    signal sector  : std_logic_vector(2 downto 0);
    signal sector_delayed : std_logic_vector(2 downto 0);
    signal T0      : signed(63 downto 0);
    signal T1      : signed(63 downto 0);
    signal T2      : signed(63 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instancja DUT
    DUT: switching_time_processor
        port map (
            clk     => clk,
            reset   => reset,
            angle   => angle,
            Vref    => Vref,
            sector  => sector,
            T0      => T0,
            T1      => T1,
            T2      => T2,
            sector_delayed => sector_delayed
        );

    -- Generowanie zegara
    clk_process : process
    begin
        while now < 1 ms loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Proces testowy
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';

        -- Test 1: sektor 001, angle ≈ π/6, Vref = 0.5
        angle  <= x"0DDBBBAA";  -- ~0.5236 (π/6) in Q4.28
        Vref   <= x"08000000";  -- 0.5 in Q6.26
        sector <= "001";
        wait for 200 ns;

        -- Test 2: sektor 010, angle ≈ π/3, Vref = 0.75
        angle  <= x"10C15238";  -- π/3 in Q4.28
        Vref   <= x"0C000000";  -- 0.75 in Q6.26
        sector <= "010";
        wait for 200 ns;

        -- Test 3: sektor 100, angle ≈ π, Vref = 1.0
        angle  <= x"3243F6A9";  -- π in Q4.28
        Vref   <= x"10000000";  -- 1.0 in Q6.26
        sector <= "100";
        wait for 200 ns;

        wait;
    end process;

end behavior;
