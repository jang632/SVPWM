library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture Behavioral of tb_top is

    -- Component under test
    COMPONENT top
        PORT( 
            clk      : IN  STD_LOGIC;
            reset    : IN  STD_LOGIC;
            HB1_top  : OUT STD_LOGIC;
            HB1_bot  : OUT STD_LOGIC;
            HB2_top  : OUT STD_LOGIC;
            HB2_bot  : OUT STD_LOGIC;
            HB3_top  : OUT STD_LOGIC;
            HB3_bot  : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Signals to connect to DUT
    SIGNAL clk      : STD_LOGIC := '0';
    SIGNAL reset    : STD_LOGIC := '1';
    SIGNAL HB1_top  : STD_LOGIC;
    SIGNAL HB1_bot  : STD_LOGIC;
    SIGNAL HB2_top  : STD_LOGIC;
    SIGNAL HB2_bot  : STD_LOGIC;
    SIGNAL HB3_top  : STD_LOGIC;
    SIGNAL HB3_bot  : STD_LOGIC;

    CONSTANT clk_period : TIME := 20 ns;  -- 100 MHz clock

begin

    -- Instantiate the DUT
    uut: top
        PORT MAP (
            clk      => clk,
            reset    => reset,
            HB1_top  => HB1_top,
            HB1_bot  => HB1_bot,
            HB2_top  => HB2_top,
            HB2_bot  => HB2_bot,
            HB3_top  => HB3_top,
            HB3_bot  => HB3_bot
        );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process
    stim_proc: PROCESS
    BEGIN
        -- Initial reset
        WAIT FOR 20 ns;
        reset <= '0';

        -- Run simulation for a while
        WAIT FOR 2 ms;

        -- Finish simulation
        WAIT;
    END PROCESS;

end Behavioral;
