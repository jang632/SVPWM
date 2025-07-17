library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_transistor_driver is
end tb_transistor_driver;

architecture test of tb_transistor_driver is

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal T0      : signed(63 downto 0) := (others => '0');
    signal T1      : signed(63 downto 0) := (others => '0');
    signal T2      : signed(63 downto 0) := (others => '0');
    signal sector  : std_logic_vector(2 downto 0) := (others => '0');
    signal HB1_top : std_logic;
    signal HB1_bot : std_logic;
    signal HB2_top : std_logic;
    signal HB2_bot : std_logic;
    signal HB3_top : std_logic;
    signal HB3_bot : std_logic;

    component transistor_driver
        port(
            clk     : in std_logic;
            reset   : in std_logic;
            T0      : in signed(63 downto 0);
            T1      : in signed(63 downto 0);
            T2      : in signed(63 downto 0);
            sector  : in std_logic_vector(2 downto 0);
            HB1_top : out std_logic;
            HB1_bot : out std_logic;
            HB2_top : out std_logic;
            HB2_bot : out std_logic;
            HB3_top : out std_logic;
            HB3_bot : out std_logic
        );
    end component;

begin

    UUT: transistor_driver
        port map (
            clk     => clk,
            reset   => reset,
            T0      => T0,
            T1      => T1,
            T2      => T2,
            sector  => sector,
            HB1_top => HB1_top,
            HB1_bot => HB1_bot,
            HB2_top => HB2_top,
            HB2_bot => HB2_bot,
            HB3_top => HB3_top,
            HB3_bot => HB3_bot
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        T0 <= to_signed(0, 64);
        T1 <= x"0000ba69daa47ac3";
        T2 <= x"0000ba69daa47ac3";

        sector <= "001";
        wait for 100 ns;

        sector <= "010";
        wait for 100 ns;

        sector <= "011";
        wait for 100 ns;

        sector <= "100";
        wait for 100 ns;

        sector <= "101";
        wait for 100 ns;

        sector <= "001";
        wait for 100 ns;

        wait;
    end process;

end test;
