// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sat Aug  2 20:30:04 2025
// Host        : DESKTOP-1FUVVL9 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Jan/Desktop/SVPWM/svpwm/svpwm/svpwm.gen/sources_1/bd/design_1/ip/design_1_top_0_1/design_1_top_0_1_stub.v
// Design      : design_1_top_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "top,Vivado 2024.1" *)
module design_1_top_0_1(clk, reset, HB1_top, HB1_bot, HB2_top, HB2_bot, 
  HB3_top, HB3_bot)
/* synthesis syn_black_box black_box_pad_pin="reset,HB1_top,HB1_bot,HB2_top,HB2_bot,HB3_top,HB3_bot" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input reset;
  output HB1_top;
  output HB1_bot;
  output HB2_top;
  output HB2_bot;
  output HB3_top;
  output HB3_bot;
endmodule
