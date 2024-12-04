//this module should be instantiated for read and write and signals to be routed accordingly
//this module will assert AXI I/O signals and also write into transfifo, to process id based out of order transfers
module axi_rd(
input clk,
input reset_n,
input [96:0]addrtrans_mem_rddata,
input addrtrans_fifo_empty,
input axi_axready,
output addrtrans_mem_rd,
output [7:0] axi_aid,
output [63:0] axi_addr,
output [2:0] axi_alen,
output [2:0] axi_asize,
output axi_axvalid,
output rd_transfifo_wr,
output [96:0]io_transfifo_wrdata
);
//axi_asize,axi_alen,axi_id,axi_addr_out
reg addrtrans_fifo_empty_d;
assign addrtrans_mem_rd = axi_axready & axi_axvalid & !addrtrans_fifo_empty;

assign axi_addr = addrtrans_mem_rddata[63:0];

assign axi_aid = addrtrans_mem_rddata[ 71 :64 ];

assign axi_alen = addrtrans_mem_rddata[74 : 72];


assign axi_asize = addrtrans_mem_rddata[77 : 75];

assign axi_axvalid = !addrtrans_fifo_empty;
assign rd_transfifo_wr = axi_axvalid & axi_axready;
assign io_transfifo_wrdata = {addrtrans_mem_rddata[89 : 78],axi_aid,axi_asize,axi_alen,axi_addr};
assign axi_len = addrtrans_mem_rddata[66 : 64];
//assign axi_asize = addrtrans_mem_rddata[69 : 67];
//assign axi_aid = addrtrans_mem_rddata[ 77 :70 ];
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   addrtrans_fifo_empty_d <= 1'b1;
  else
   addrtrans_fifo_empty_d <= addrtrans_fifo_empty;
endmodule