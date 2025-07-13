library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_vector_processor is
end tb_vector_processor;

architecture Behavioral of tb_vector_processor is

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    signal x          : std_logic_vector(31 downto 0);
    signal y          : std_logic_vector(31 downto 0);
    signal angle      : std_logic_vector(31 downto 0);
    signal magnitude  : std_logic_vector(31 downto 0);
    signal sector  : std_logic_vector(2 downto 0);
    signal iterations : integer range 1 to 16 := 16;

    constant clk_period : time := 10 ns;

begin

    uut: entity work.vector_processor
        port map (
            clk        => clk,
            reset      => reset,
            x          => x,
            y          => y,
            angle      => angle,
            magnitude  => magnitude,
            sector     => sector,
            iterations => iterations
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

        stim_proc: process
        constant Q28      : real := 268435456.0;
        constant ONE      : integer := integer(1.0   * Q28);
        constant TWO      : integer := integer(-2.0   * Q28);
        constant FIVE     : integer := integer(5.0   * Q28);
        constant SEVEN    : integer := integer(7.0   * Q28);
        constant HALF_NEG : integer := integer(0.5  * Q28);

        constant REAL1    : integer := integer(4.2637 * Q28);
        constant REAL2    : integer := integer(-6.731 * Q28);
        constant REAL3    : integer := integer(2.718  * Q28);
        constant REAL4    : integer := integer(-2.414 * Q28);

        constant REAL5    : integer := integer(7.95   * Q28); 
        constant REAL6    : integer := integer(7.88  * Q28);

    begin
        reset <= '1';
        wait for 2 * clk_period + clk_period/2;
        reset <= '0';

        x <= std_logic_vector(to_signed(TWO, 32));
        y <= std_logic_vector(to_signed(-SEVEN, 32));
        wait for clk_period;

        x <= std_logic_vector(to_signed(0, 32));
        y <= std_logic_vector(to_signed(HALF_NEG, 32));
        wait for clk_period;
        
        x <= std_logic_vector(to_signed(HALF_NEG, 32));
        y <= std_logic_vector(to_signed(0, 32));
        wait for clk_period;

        x <= std_logic_vector(to_signed(-FIVE, 32));
        y <= std_logic_vector(to_signed(FIVE, 32));
        wait for clk_period;

        x <= std_logic_vector(to_signed(REAL1, 32));
        y <= std_logic_vector(to_signed(REAL2, 32));
        wait for clk_period;

        x <= std_logic_vector(to_signed(REAL3, 32));
        y <= std_logic_vector(to_signed(REAL4, 32));
        wait for clk_period;

        x <= std_logic_vector(to_signed(REAL5, 32));  
        y <= std_logic_vector(to_signed(REAL6, 32));  
        wait for clk_period;

        wait;
    end process;


end Behavioral;
