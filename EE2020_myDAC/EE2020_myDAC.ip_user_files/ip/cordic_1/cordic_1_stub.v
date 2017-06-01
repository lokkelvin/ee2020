// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Thu Mar 23 23:18:41 2017
// Host        : BLACK-LAPTOP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Desktop/MyWork/EE2020_myDAC_square_gen_working.xpr/EE2020_myDAC/EE2020_myDAC.srcs/sources_1/ip/cordic_1/cordic_1_stub.v
// Design      : cordic_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "cordic_v6_0_11,Vivado 2016.4" *)
module cordic_1(aclk, s_axis_phase_tvalid, 
  s_axis_phase_tdata, m_axis_dout_tvalid, m_axis_dout_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,s_axis_phase_tvalid,s_axis_phase_tdata[7:0],m_axis_dout_tvalid,m_axis_dout_tdata[15:0]" */;
  input aclk;
  input s_axis_phase_tvalid;
  input [7:0]s_axis_phase_tdata;
  output m_axis_dout_tvalid;
  output [15:0]m_axis_dout_tdata;
endmodule
