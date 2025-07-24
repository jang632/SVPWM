----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.07.2025 20:09:29
-- Design Name: 
-- Module Name: top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
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

COMPONENT blk_mem_gen_1 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

COMPONENT blk_mem_gen_2 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

SIGNAL ena : STD_LOGIC; 
SIGNAL wea : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL addra : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL doutA : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL doutB : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL doutC : STD_LOGIC_VECTOR(15 DOWNTO 0);

begin

inst_memA : blk_mem_gen_0
  port map (
    clka    => clk,
    ena     => ena,
    wea     => wea,
    addra   => addra,
    dina    => (OTHERS => '0'),
    douta   => doutA
  );

inst_memB : blk_mem_gen_1
  port map (
    clka    => clk,
    ena     => ena,
    wea     => wea,
    addra   => addra,
    dina    => (OTHERS => '0'),
    douta   => doutB
  );

inst_memC : blk_mem_gen_2
  port map (
    clka    => clk,
    ena     => ena,
    wea     => wea,
    addra   => addra,
    dina    => (OTHERS => '0'),
    douta   => doutC
  );

inst_svpwm : svpwm
  port map (
    clk      => clk,
    reset    => reset,
    v_a      => doutA,
    v_b      => doutB,
    v_c      => doutC,
    HB1_top  => HB1_top,
    HB1_bot  => HB1_bot,
    HB2_top  => HB2_top,
    HB2_bot  => HB2_bot,
    HB3_top  => HB3_top,
    HB3_bot  => HB3_bot
  );

end Behavioral;
