

//---------------------------------------------------------------
import uvm_pkg::*;
`include "uvm_macros.svh"
//including interfcae and testcase files
`include "axi_interface.sv"
`include "axi_test.sv"
//--------------------------------------

module tb_top ;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  
input clk,
input reset_n,


//-------------SIGNALS --------------------------

//wr address channel
output [7:0] axi_awid,
output [63:0] axi_wraddr,
output [2:0] axi_awlen,
output [2:0] axi_awsize,
output [1:0] axi_awburst,
output axi_awlock,
output axi_awcache,
output axi_awprot,
output axi_awqos,
output axi_awregion,
output axi_awuser,
output axi_awvalid,
input axi_awready,



//wr data channel
output [7:0]axi_wid,
output [511:0] axi_wrdata,
output [63:0]axi_wstrb,
output axi_wlast,
output axi_wuser,
output axi_wvalid,
input axi_wready,

//wr response channel
input [7:0]axi_bid,
input [1:0]axi_bresp,
input axi_buser,
input axi_bvalid,
output axi_bready,


//rd address channel 
output [7:0] axi_arid,
output [63:0] axi_rdaddr,
output [2:0] axi_arlen,
output [2:0] axi_arsize,
output [1:0] axi_arburst,
output axi_arlock,
output axi_arcache,
output axi_arprot,
output axi_arqos,
output axi_arregion,
output axi_aruser,
output axi_arvalid,
input axi_arready,

//rd data channel and resp
input [7:0]axi_rid,
input [511:0] axi_rddata,
input axi_rlast,
output axi_ruser,
input axi_rvalid,
output axi_rready,
input [1:0]axi_rresp,

/*
output csysreq,
output csysack,
input ip_wr_start0,
output ip_wr_grant0,
output wr_xfer_done0,
output wrfifo_rd0,
input wrfifo_empty0,
input [11:0]wrbytecount_0,
input [63:0]wraddr_0,
input [511:0]wrfifo_rddata0,
output axi_wr_err0,
input ip_wr_start1,
output ip_wr_grant1,
output wr_xfer_done1,
output wrfifo_rd1,
input wrfifo_empty1,
input [11:0]wrbytecount_1,
input [63:0]wraddr_1,
input [511:0]wrfifo_rddata1,
output axi_wr_err1,
input ip_wr_start2,
output ip_wr_grant2,
output wr_xfer_done2,
output wrfifo_rd2,
input wrfifo_empty2,
input [11:0]wrbytecount_2,
input [63:0]wraddr_2,
input [511:0]wrfifo_rddata2,
output axi_wr_err2,

//ports connected to read and write ip requestor block
//read ip requestor block
input ip_rd_start0,
output ip_rd_grant0,
output rd_xfer_done0,
output rdfifo_wr0,
input [11:0]rdbytecount_0,
input [63:0]rdaddr_0,
output axi_rd_err0,
output [511:0]rdfifo_wrdata0,
input ip_rd_start1,
output ip_rd_grant1,
output rd_xfer_done1,
output rdfifo_wr1,
input [11:0]rdbytecount_1,
input [63:0]rdaddr_1,
output axi_rd_err1,
output [511:0]rdfifo_wrdata1,
input ip_rd_start2,
output ip_rd_grant2,
output rd_xfer_done2,
output rdfifo_wr2,
input [11:0]rdbytecount_2,
input [63:0]rdaddr_2,
output axi_rd_err2,
output [511:0]rdfifo_wrdata2,
input ip_rd_start3,
output ip_rd_grant3,
output rd_xfer_done3,
output rdfifo_wr3,
input [11:0]rdbytecount_3,
input [63:0]rdaddr_3,
output axi_rd_err3,
output [511:0]rdfifo_wrdata3,
 
output cactive
);


wire processing_submaster_0;
wire processing_submaster_1;
wire processing_submaster_2;
//multibit
wire [96:0]addrtrans_mem_rddata_rd;
wire [96:0]io_transfifo_wrdata_rd;
wire [96:0]addrtrans_mem_rddata_wr;
wire [96:0]io_transfifo_wrdata_wr;
wire [63:0]decoded_wraddress_in;
wire [63:0]decoded_rdaddress_in;
wire [11:0]decoded_wrbytecount_in;
wire [11:0]decoded_rdbytecount_in;
wire [82:0]ram4k_wrdata_waddr_mem;
wire [82:0]ram4k_wrdata_raddr_mem;
wire [96:0]ram_wrdata_rd_converter;
wire [96:0]dataout_raddr_mem;
wire [96:0]dataout_waddr_mem;
wire [96:0]ram_wrdata_wr_converter;
wire [96:0]axi_conv_fifo_rddata_0;
wire [96:0]axi_conv_fifo_wrdata_0;
wire [96:0]axi_conv_fifo_rddata_1;
wire [96:0]axi_conv_fifo_wrdata_1;
wire [96:0]axi_conv_fifo_rddata_2;
wire [96:0]axi_conv_fifo_wrdata_2;
wire [96:0]axi_conv_fifo_rddata_3;
wire [96:0]axi_conv_fifo_wrdata_3;
wire [96:0]axi_conv_fifo_rddata_4;
wire [96:0]axi_conv_fifo_wrdata_4;
wire [96:0]axi_conv_fifo_rddata_5;
wire [96:0]axi_conv_fifo_wrdata_5;
wire [96:0]axi_conv_fifo_rddata_6;
wire [96:0]axi_conv_fifo_wrdata_6;
wire [96:0]axi_conv_fifo_rddata_7;
wire [96:0]axi_conv_fifo_wrdata_7;
wire [7:0] current_wid_in_process;
wire [7:0] current_rid_in_process;
 wire [511:0]ip_data;  */



//------------END SIGNALS-------------------------
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    reset_n = 1;
    #5 reset_n =0;
  end
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
 // dma_if intf(clk,reset);
   axi_intf intf(clk, reset_n);
  //---------------------------------------
  //DUT instance
  //---------------------------------------
  


axi_top DUT(
.clk(intf.clk),
.reset_n(intf.reset_n),

//awaddr channel
.axi_awid(axi_awid),
.axi_wraddr(axi_wraddr),
.axi_awlen(axi_awlen),
.axi_awsize(axi_awsize),
.axi_awburst(axi_awburst),
.axi_awlock(axi_awlock),
.axi_awcache(axi_awcache),
.axi_awprot(axi_awprot),
.axi_awqos(axi_awqos),
.axi_awregion(axi_awregion),
.axi_awuser(axi_awuser),
.axi_awvalid(axi_awvalid),
.axi_awready(axi_awready),

//araddr channel
.axi_arid(axi_arid),
.axi_rdaddr(axi_rdaddr),
.axi_arlen(axi_arlen),
.axi_arsize(axi_arsize),
.axi_arburst(axi_arburst),
.axi_arlock(axi_arlock),
.axi_arcache(axi_arcache),
.axi_arprot(axi_arprot),
.axi_arqos(axi_arqos),
.axi_arregion(axi_arregion),
.axi_aruser(axi_aruser),
.axi_arvalid(axi_arvalid),
.axi_arready(axi_arready),

//wr data channel
.axi_wid(axi_wid),
.axi_wrdata(axi_wrdata),
.axi_wstrb(axi_wstrb),
.axi_wlast(axi_wlast),
.axi_wuser(axi_wuser),
.axi_wvalid(axi_wvalid),
.axi_wready(axi_wready),

//wr response channel
.axi_bid(axi_bid),
.axi_bresp(axi_bresp),
.axi_buser(axi_buser),
//.axi_bvalid(axi_bvalid),
.axi_bvalid(axi_bvalid),
.axi_bready(axi_bready),

//rdata channel
.axi_rvalid(axi_rvalid),
.axi_rid(axi_rid),
.axi_rdata(axi_rdata),
.axi_rresp(axi_rresp),
.axi_rlast(axi_rlast), 
.axi_rready(axi_rready)

);
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual dma_if)::set(uvm_root::get(),"*","vif",intf);
    //enable wave dump
   // $dumpfile("dump.vcd"); 
  //  $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
  end
  
endmodule
