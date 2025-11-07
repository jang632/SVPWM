
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
PORT( 
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        miso     : IN     STD_LOGIC;
        sclk     : BUFFER STD_LOGIC;
        ss_n     : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
        HB1_top  : OUT STD_LOGIC;
        HB1_bot  : OUT STD_LOGIC;
        HB2_top  : OUT STD_LOGIC;
        HB2_bot  : OUT STD_LOGIC;
        HB3_top  : OUT STD_LOGIC;
        HB3_bot  : OUT STD_LOGIC
        );
end top;

architecture Behavioral of top is

COMPONENT svpwm IS
    PORT( 
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;
        v_a       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
        v_b       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_c       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        HB1_top  : OUT STD_LOGIC;
        HB1_bot  : OUT STD_LOGIC;
        HB2_top  : OUT STD_LOGIC;
        HB2_bot  : OUT STD_LOGIC;
        HB3_top  : OUT STD_LOGIC;
        HB3_bot  : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

COMPONENT spi IS
 GENERIC(
    slaves  : INTEGER := 1;  --number of spi slaves
    d_width : INTEGER := 48); --data bus width
 PORT(
    clock   : IN     STD_LOGIC;                             --system clock
    reset_n : IN     STD_LOGIC;                             --asynchronous reset
    enable  : IN     STD_LOGIC;                             --initiate transaction
    cpol    : IN     STD_LOGIC;                             --spi clock polarity
    cpha    : IN     STD_LOGIC;                             --spi clock phase
    cont    : IN     STD_LOGIC;                             --continuous mode command
    clk_div : IN     INTEGER;                               --system clock cycles per 1/2 period of sclk
    addr    : IN     INTEGER;                               --address of slave
    miso    : IN     STD_LOGIC;                             --master in, slave out
    sclk    : BUFFER STD_LOGIC;                             --spi clock
    ss_n    : BUFFER STD_LOGIC_VECTOR(slaves-1 DOWNTO 0);   --slave select
    busy    : OUT    STD_LOGIC;                             --busy / data ready signal
    rx_data : OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0)); --data received
END COMPONENT spi;

SIGNAL ena : STD_LOGIC; 
SIGNAL wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL addra : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL v_a : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL v_b : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL v_c : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL index : unsigned(15 DOWNTO 0);

SIGNAL spi_ena     : STD_LOGIC; 
SIGNAL spi_cont    : STD_LOGIC; 
SIGNAL spi_busy    : STD_LOGIC; 
SIGNAL spi_rx_data : STD_LOGIC_VECTOR(47 DOWNTO 0);

begin

spi_master: spi
    GENERIC MAP(
      slaves => 1, 
      d_width => 48)
    PORT MAP(
      clock => clk, 
      reset_n => reset, 
      enable => spi_ena, 
      cpol => '1', 
      cpha => '1',
      cont => spi_cont, 
      clk_div => 8, 
      addr => 0, 
      miso => miso,
      sclk => sclk, 
      ss_n => ss_n,  
      busy => spi_busy, 
      rx_data => spi_rx_data
    );

inst_svpwm : svpwm
  port map (
    clk      => clk,
    reset    => reset,
    v_a      => spi_rx_data(47 DOWNTO 32),
    v_b      => spi_rx_data(31 DOWNTO 16),
    v_c      => spi_rx_data(15 DOWNTO 0),
    HB1_top  => HB1_top,
    HB1_bot  => HB1_bot,
    HB2_top  => HB2_top,
    HB2_bot  => HB2_bot,
    HB3_top  => HB3_top,
    HB3_bot  => HB3_bot
  );
 
ena <= '1'; 
  
PROCESS(clk)
BEGIN 
    IF(rising_edge(clk)) THEN 
       IF(reset = '1') THEN 
        spi_ena <= '0';
        spi_cont <= '0';
       ELSE 
          IF(index < x"0302") THEN 
            index <= index + 1;
            spi_ena <= '0';
            spi_cont <= '0';
          ELSE
            spi_ena <= '1';
            spi_cont <= '1';
            index <= x"0000";
          END IF; 
       END IF;
     END IF;
END PROCESS;

end Behavioral;


            