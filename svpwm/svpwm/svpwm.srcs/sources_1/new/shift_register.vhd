library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_register is
    GENERIC ( 
        data_len : INTEGER;
        delay_len : INTEGER
        ); 
    PORT (
        clk       : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        sig_in   : IN STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0);
        sig_delay : OUT STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0)
    );
end shift_register;

architecture Behavioral of shift_register is

    TYPE delay_array is array(0 to delay_len - 1) of STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0);
    SIGNAL sig_delay_line : delay_array := (others => (others => '0'));

begin

    PROCESS(clk)
    BEGIN
        IF reset = '1' THEN 
            sig_delay_line <= (others => (others => '0'));
            sig_delay      <= (others => '0');
        ELSIF rising_edge(clk) THEN
            FOR i IN delay_len - 1 DOWNTO 1 LOOP
                sig_delay_line(i) <= sig_delay_line(i - 1);
            END LOOP;
            sig_delay_line(0) <= sig_in;
            sig_delay <= sig_delay_line(delay_len - 1);
        END IF;
    END PROCESS;

end Behavioral;