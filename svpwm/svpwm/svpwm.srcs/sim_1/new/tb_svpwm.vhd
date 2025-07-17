library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

ENTITY tb_svpwm IS
END tb_svpwm;

ARCHITECTURE behavior OF tb_svpwm IS

    SIGNAL clk      : STD_LOGIC := '0';
    SIGNAL reset    : STD_LOGIC := '0';
    SIGNAL v_a       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_b       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_c       : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL HB1_TOP  : STD_LOGIC;
    SIGNAL HB1_BOT  : STD_LOGIC;
    SIGNAL HB2_TOP  : STD_LOGIC;
    SIGNAL HB2_BOT  : STD_LOGIC;
    SIGNAL HB3_TOP  : STD_LOGIC;
    SIGNAL HB3_BOT  : STD_LOGIC;

    FILE txt_file   : TEXT;

BEGIN

    DUT : ENTITY work.svpwm
        PORT MAP (
            clk      => clk,
            reset    => reset,
            v_a       => v_a,
            v_b       => v_b,
            v_c       => v_c,
            HB1_top  => HB1_TOP,
            HB1_bot  => HB1_BOT,
            HB2_top  => HB2_TOP,
            HB2_bot  => HB2_BOT,
            HB3_top  => HB3_TOP,
            HB3_bot  => HB3_BOT
        );

    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0'; WAIT FOR 5 ns;
            clk <= '1'; WAIT FOR 5 ns;
        END LOOP;
    END PROCESS;

    stimulus_proc : PROCESS
        VARIABLE line_buf : LINE;
        VARIABLE col1_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE col2_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE col3_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        v_a    <= (OTHERS => '0');
        v_b    <= (OTHERS => '0');
        v_c    <= (OTHERS => '0');
        reset <= '1';
        WAIT FOR 1500 ns;
        reset <= '0';

        FILE_OPEN(txt_file, "Sine50Hz_64kHz.txt", READ_MODE);

        WHILE NOT ENDFILE(txt_file) LOOP
            READLINE(txt_file, line_buf);
            READ(line_buf, col1_txt);
            READ(line_buf, col2_txt);
            READ(line_buf, col3_txt);

            v_a <= col1_txt;
            v_b <= col2_txt;
            v_c <= col3_txt;

            WAIT FOR 15625 ns;
        END LOOP;

        FILE_CLOSE(txt_file);
        WAIT;
    END PROCESS;

END behavior;
