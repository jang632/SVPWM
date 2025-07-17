
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity switching_time_processor is
    PORT(
        clk    : IN STD_LOGIC;
        reset  : IN STD_LOGIC;
        angle  : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --28 bin point
        Vref   : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --26 bin point
        sector : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        T0     : OUT signed(63 DOWNTO 0);
        T1     : OUT signed(63 DOWNTO 0);
        T2     : OUT signed(63 DOWNTO 0);
        sector_delayed : OUT STD_LOGIC_VECTOR (2 DOWNTO 0) 
        );
end switching_time_processor;

architecture Behavioral of switching_time_processor is
    component cordic_sin_cos
        Port (
            clk        : IN  STD_LOGIC;
            reset      : IN  STD_LOGIC;
            theta      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            sin_value  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            cos_value  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            iterations : IN  INTEGER range 1 to 16
        );
    end component;
    
    component shift_register is
        GENERIC ( 
            data_len : INTEGER;
            delay_len : INTEGER
        );
        Port (
            clk       : IN STD_LOGIC;
            reset     : IN STD_LOGIC;
            sig_in   : IN STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0);
            sig_delay : OUT STD_LOGIC_VECTOR(data_len - 1 DOWNTO 0)
        );
   end component;
    
    TYPE FSM IS (calculate_T1, calculate_T2);
    SIGNAL STATE : FSM;
    
    SIGNAL theta : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sin_val : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL T1_int : signed(63 DOWNTO 0);
    SIGNAL T2_int : signed(63 DOWNTO 0);
    SIGNAL T1_delay : signed(63 DOWNTO 0);
    
    SIGNAL Vref_delay : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    CONSTANT PI_3 : signed(31 DOWNTO 0)  := x"10c15238";
    CONSTANT PI2_3 : signed(31 DOWNTO 0) := x"2182a470";
    CONSTANT PI : signed(31 DOWNTO 0)    := x"3243f6a9";
    CONSTANT PI4_3 : signed(31 DOWNTO 0) := x"430548e1";
    CONSTANT PI5_3 : signed(31 DOWNTO 0) := x"53c69b19";
    CONSTANT PI2 : signed(31 DOWNTO 0)   := x"6487ed51";
    
    CONSTANT M : signed(31 DOWNTO 0)   := x"0000f229";
    CONSTANT Tz : signed(63 DOWNTO 0)   := x"00022f3d8fed7049";
    
    CONSTANT iterations : INTEGER RANGE 1 TO 16 := 16;
    
    SIGNAL not_used : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
begin

cordic_inst : cordic_sin_cos
        port map (
            clk        => clk,
            reset      => reset,
            theta      => theta,
            sin_value  => sin_val,
            cos_value  => not_used,
            iterations => iterations
        );

shift_reg_vref : shift_register
        generic map (
            data_len => 32,
            delay_len => 16
        )
        port map (
            clk        => clk,
            reset      => reset,
            sig_in     => Vref,
            sig_delay  => Vref_delay
        );

shift_reg_sector : shift_register
        generic map (
            data_len => 3,
            delay_len => 18
        )
        port map (
            clk        => clk,
            reset      => reset,
            sig_in     => sector,
            sig_delay  => sector_delayed
        );


PROCESS(clk)
variable M_Vref : signed(127 DOWNTO 0);
BEGIN 
    IF(reset = '1') THEN 
        theta <= (others => '0');
        T1_int <= (others => '0');
        T2_int <= (others => '0');
        T1_delay <= (others => '0');
        STATE <= CALCULATE_T1;         
    ELSIF(rising_edge(clk)) THEN 
        CASE STATE IS
            WHEN CALCULATE_T1 =>
                    IF sector = "001" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(PI_3) - signed(angle));
                    ELSIF sector = "010" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(PI2_3) - signed(angle));
                    ELSIF sector = "011" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(PI) - signed(angle));
                    ELSIF sector = "100" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(PI4_3) - signed(angle));
                    ELSIF sector = "101" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(PI5_3) - signed(angle));
                    ELSIF sector = "110" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(PI2) - signed(angle));
                    END IF;         
                    T2_int <= resize(shift_right(signed(Vref_delay) * signed(sin_val) *  M, 22) ,64); --63 bin point
                    STATE <= CALCULATE_T2;
        
            WHEN CALCULATE_T2 =>
                    IF sector = "001" THEN 
                        theta <= angle;
                    ELSIF sector = "010" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(angle) - signed(PI_3));
                    ELSIF sector = "011" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(angle) - signed(PI2_3));
                    ELSIF sector = "100" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(angle) - signed(PI));
                    ELSIF sector = "101" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(angle) - signed(PI4_3));
                    ELSIF sector = "110" THEN 
                        theta <= STD_LOGIC_VECTOR(signed(angle) - signed(PI5_3));
                    END IF;
                    T1_delay <= resize(shift_right(signed(Vref_delay) * signed(sin_val) *  M, 22) ,64); --63 bin point                    
                    STATE <= CALCULATE_T1;
           END CASE;
        T1_int <= T1_delay;
    END IF;
END PROCESS;
    
T0 <= Tz - T1_int(63 DOWNTO 0) - T2_int(63 DOWNTO 0);
T1 <= T1_int(63 DOWNTO 0);
T2 <= T2_int(63 DOWNTO 0);

end Behavioral;
