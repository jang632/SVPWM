library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_clarke_transform is
end tb_clarke_transform;

architecture behavior of tb_clarke_transform is

    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal v_a   : std_logic_vector(15 downto 0);
    signal v_b   : std_logic_vector(15 downto 0);
    signal v_c   : std_logic_vector(15 downto 0);

    signal v_alpha : SIGNED(31 downto 0);
    signal v_beta  : SIGNED(31 downto 0);


    file txt_file : text;

begin

    DUT: entity work.clarke_transform
        port map (
            clk      => clk,
            reset    => reset,
            v_a      => v_a,
            v_b      => v_b,
            v_c      => v_c,
            v_alpha  => v_alpha,
            v_beta   => v_beta
        );

    clk_gen : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    stimulus_proc : process
        variable line_buf : line;
        variable col1_txt : std_logic_vector(15 downto 0);
        variable col2_txt : std_logic_vector(15 downto 0);
        variable col3_txt : std_logic_vector(15 downto 0);
    begin

        v_a <= (others => '0');
        v_b <= (others => '0');
        v_c <= (others => '0');
        reset <= '1';
        wait for 20 ns;
        reset <= '0';


        file_open(txt_file, "Sine50Hz_64kHz.txt", read_mode);

        while not endfile(txt_file) loop
            readline(txt_file, line_buf);

            read(line_buf, col1_txt);
            read(line_buf, col2_txt);
            read(line_buf, col3_txt);


            v_a <= col1_txt;
            v_b <= col2_txt;
            v_c <= col3_txt;
           
            wait for 10 ns;
        end loop;

        file_close(txt_file);
        wait;
    end process;

end behavior;
 