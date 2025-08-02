-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
-- Date        : Sat Aug  2 20:30:04 2025
-- Host        : DESKTOP-1FUVVL9 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/Jan/Desktop/SVPWM/svpwm/svpwm/svpwm.gen/sources_1/bd/design_1/ip/design_1_top_0_1/design_1_top_0_1_stub.vhdl
-- Design      : design_1_top_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_top_0_1 is
  Port ( 
    clk : in STD_LOGIC;
    reset : in STD_LOGIC;
    HB1_top : out STD_LOGIC;
    HB1_bot : out STD_LOGIC;
    HB2_top : out STD_LOGIC;
    HB2_bot : out STD_LOGIC;
    HB3_top : out STD_LOGIC;
    HB3_bot : out STD_LOGIC
  );

end design_1_top_0_1;

architecture stub of design_1_top_0_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,reset,HB1_top,HB1_bot,HB2_top,HB2_bot,HB3_top,HB3_bot";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "top,Vivado 2024.1";
begin
end;
