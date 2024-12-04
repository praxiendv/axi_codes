 //for bytecount field
//since PCIE max transfer size = 1024Dwords=4096bytes and we use 512bit axi data hence axlen=64 and asize=64..fix bytecount field to be 12bit
module axi_top(
input clk,
input reset_n,

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
 wire [511:0]ip_data;
/*
axi_rd axi_rd(
.clk(clk),
.reset_n(reset_n),
.addrtrans_mem_rddata(addrtrans_mem_rddata_rd),
.addrtrans_fifo_empty(addrtrans_fifo_empty_rd),
.axi_axready(axi_arready),
.addrtrans_mem_rd(addrtrans_mem_rd_rd),
.axi_aid(axi_arid),
.axi_addr(axi_rdaddr),
.axi_alen(axi_arlen),
.axi_asize(axi_arsize),
.axi_axvalid(axi_arvalid),
.rd_transfifo_wr(),
.io_transfifo_wrdata()
);

*/

assign decoded_ip_wr_grant = ip_wr_grant0
            |ip_wr_grant0
            |ip_wr_grant1
            |ip_wr_grant2
;
assign decoded_ip_rd_grant = ip_rd_grant0

            |ip_rd_grant0
            |ip_rd_grant1
            |ip_rd_grant2
            |ip_rd_grant3
;

assign decoded_rdaddress_in = 

                              (ip_rd_grant0)?rdaddr_0 :
                              (ip_rd_grant1)?rdaddr_1 :
                              (ip_rd_grant2)?rdaddr_2 :
                              (ip_rd_grant3)?rdaddr_3 :
 64'd0;
assign decoded_wraddress_in = 

                              (ip_wr_grant0)?wraddr_0 :
                              (ip_wr_grant1)?wraddr_1 :
                              (ip_wr_grant2)?wraddr_2 :
 64'd0;


assign decoded_rdbytecount_in =

(ip_rd_grant0)? rdbytecount_0 :
(ip_rd_grant1)? rdbytecount_1 :
(ip_rd_grant2)? rdbytecount_2 :
(ip_rd_grant3)? rdbytecount_3 :
 12'd0;

assign decoded_wrbytecount_in = 

(ip_wr_grant0)? wrbytecount_0 :
(ip_wr_grant1)? wrbytecount_1 :
(ip_wr_grant2)? wrbytecount_2 :
 12'd0;

//below decoded signals indicate the address and bytecount processing of the submaster for which grant is given
addr_4k_align_max_mtu addr_4k_align_max_mtu_wr(
.clk(clk),
.reset_n(reset_n),
.submaster_rd_grant_0(ip_rd_grant0),
.submaster_wr_grant_0(ip_wr_grant0),
.process_address_decoding(decoded_ip_wr_grant),//this signal ..next decoding should start after acknowledgement...when no conversion is required(), state should move immediately
.address_decoding_done(),//assert this signal immediately if no conversion is required
.addrin(decoded_wraddress_in),
.total_bytes(decoded_wrbytecount_in),
.ram4k_wr(ram4k_wr_waddr_mem),
.ram4k_wrdata(ram4k_wrdata_waddr_mem)//[63:0]addr(),remaining will be bytes
);
//below decoded signals indicate the address and bytecount processing of the submaster for which grant is given
addr_4k_align_max_mtu addr_4k_align_max_mtu_rd(
.clk(clk),
.reset_n(reset_n),
.submaster_rd_grant_0(ip_rd_grant0),
.submaster_wr_grant_0(ip_wr_grant0),
.process_address_decoding(decoded_ip_rd_grant),//this signal ..next decoding should start after acknowledgement...when no conversion is required(), state should move immediately
.address_decoding_done(),//assert this signal immediately if no conversion is required
.addrin(decoded_rdaddress_in),
.total_bytes(decoded_rdbytecount_in),
.ram4k_wr(ram4k_wr_raddr_mem),
.ram4k_wrdata(ram4k_wrdata_raddr_mem)//[63:0]addr(),remaining will be bytes
);
/*
axi_converter rd_axi_converter(
.clk(clk),
.reset_n(reset_n),
.fifo_empty(empty_raddr_mem),//this is 4K address fifo empty signal which has 4K aligned address and bytecounts
.ram4k_rddata(dataout_raddr_mem),

.ram_4k_rd(rd_raddr_mem),
.ram_axi_conv_wr(ram_axi_conv_wr_rd_converter),
.ram_wrdata(ram_wrdata_rd_converter)//axi_asize(),axi_alen(),axi_id(),axi_addr_out
);
*/

wr_axi_converter rd_axi_converter(
.clk(clk),
.reset_n(reset_n),
.rd_converter(1),
.xfer_done(),
.fifo_empty(empty_raddr_mem),//this is 4K address fifo empty signal which has 4K aligned address and bytecounts
.ram4k_rddata(dataout_raddr_mem),

.ram_4k_rd(rd_raddr_mem),
.axi_awid(axi_arid),
.axi_wraddr(axi_rdaddr),
.axi_awlen(axi_arlen),
.axi_awsize(axi_arsize),
.axi_awburst(axi_arburst),
.axi_awlock(axi_arlock),
.axi_awcache(axi_arcache),
.axi_awprot(axi_arprot),
.axi_awqos(axi_arqos),
.axi_awregion(axi_arregion),
.axi_awuser(axi_aruser),
.axi_awvalid(axi_arvalid),
.axi_awready(axi_arready),



//wr data channel
.axi_wid(),
.axi_wrdata(),
.axi_wstrb(),
.axi_wlast(),
.axi_wuser(),
.axi_wvalid(),
.axi_wready(0),

//wr response channel
.axi_bid('d0),
.axi_bresp('d0),
.axi_buser('d0),
.axi_bvalid('d0),
.axi_bready(),


//Submaster wrdata
.rd_submaster_wrfifo(),
.ip_data(),

//for axi read
.rd_transfifo_wr(rd_transfifo_wr_rd),
.io_transfifo_wrdata(io_transfifo_wrdata_rd)
);



wr_axi_converter wr_axi_converter(
.clk(clk),
.reset_n(reset_n),

.rd_converter(0),
.xfer_done(xfer_done),
.fifo_empty(empty_waddr_mem),//this is 4K address fifo empty signal which has 4K aligned address and bytecounts
.ram4k_rddata(dataout_waddr_mem),

.ram_4k_rd(wr_raddr_mem),
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


//Submaster wrdata
.rd_submaster_wrfifo(rd_submaster_wrfifo),
.ip_data(ip_data)
);

rd_channel rd_channel(
.clk(clk),
.reset_n(reset_n),
.rvalid(axi_rvalid),
.rid(axi_rid),
.rdata(axi_rddata),
.resp(axi_rresp),
.rlast(axi_rlast), 
.ready(axi_rready),
.ip_fifo_wrdata(rdfifo_wrdata0),
.ip_fifo_wr_0(rdfifo_wr0),
.axi_rd_err0(axi_rd_err0),
.xfer_done_0(rd_xfer_done0),
.ip_fifo_wr_1(rdfifo_wr1),
.axi_rd_err1(axi_rd_err1),
.xfer_done_1(rd_xfer_done1),
.ip_fifo_wr_2(rdfifo_wr2),
.axi_rd_err2(axi_rd_err2),
.xfer_done_2(rd_xfer_done2),
.ip_fifo_wr_3(rdfifo_wr3),
.axi_rd_err3(axi_rd_err3),
.xfer_done_3(rd_xfer_done3),

.fifo_rd_0(addrtrans_mem_rd_rd_0),//to read axi converted fifo
.fifo_empty_0(addrtrans_fifo_empty_rd_0),//axi converter fifo status
.axi_conv_fifo_rddata_0(axi_conv_fifo_rddata_0),
.fifo_rd_1(addrtrans_mem_rd_rd_1),//to read axi converted fifo
.fifo_empty_1(addrtrans_fifo_empty_rd_1),//axi converter fifo status
.axi_conv_fifo_rddata_1(axi_conv_fifo_rddata_1),
.fifo_rd_2(addrtrans_mem_rd_rd_2),//to read axi converted fifo
.fifo_empty_2(addrtrans_fifo_empty_rd_2),//axi converter fifo status
.axi_conv_fifo_rddata_2(axi_conv_fifo_rddata_2),
.fifo_rd_3(addrtrans_mem_rd_rd_3),//to read axi converted fifo
.fifo_empty_3(addrtrans_fifo_empty_rd_3),//axi converter fifo status
.axi_conv_fifo_rddata_3(axi_conv_fifo_rddata_3),
.fifo_rd_4(addrtrans_mem_rd_rd_4),//to read axi converted fifo
.fifo_empty_4(addrtrans_fifo_empty_rd_4),//axi converter fifo status
.axi_conv_fifo_rddata_4(axi_conv_fifo_rddata_4),
.fifo_rd_5(addrtrans_mem_rd_rd_5),//to read axi converted fifo
.fifo_empty_5(addrtrans_fifo_empty_rd_5),//axi converter fifo status
.axi_conv_fifo_rddata_5(axi_conv_fifo_rddata_5),
.fifo_rd_6(addrtrans_mem_rd_rd_6),//to read axi converted fifo
.fifo_empty_6(addrtrans_fifo_empty_rd_6),//axi converter fifo status
.axi_conv_fifo_rddata_6(axi_conv_fifo_rddata_6),
.fifo_rd_7(addrtrans_mem_rd_rd_7),//to read axi converted fifo
.fifo_empty_7(addrtrans_fifo_empty_rd_7),//axi converter fifo status
.axi_conv_fifo_rddata_7(axi_conv_fifo_rddata_7),
.id_mismatch_err(),
.bytecount_mismatch()//tbd
);



assign wr_xfer_done0 = xfer_done & processing_submaster_0;
assign axi_wr_err0= axi_bresp != 'd0;
assign wrfifo_rd0= rd_submaster_wrfifo & processing_submaster_0;
assign wr_xfer_done1 = xfer_done & processing_submaster_1;
assign axi_wr_err1= axi_bresp != 'd0;
assign wrfifo_rd1= rd_submaster_wrfifo & processing_submaster_1;
assign wr_xfer_done2 = xfer_done & processing_submaster_2;
assign axi_wr_err2= axi_bresp != 'd0;
assign wrfifo_rd2= rd_submaster_wrfifo & processing_submaster_2;
assign ip_data = 

                 (processing_submaster_0)?wrfifo_rddata0:
                 (processing_submaster_1)?wrfifo_rddata1:
                 (processing_submaster_2)?wrfifo_rddata2:
                 0;

submaster_wr_arb submaster_wr_arb(
.clk(clk),


.start_0(ip_wr_start0),
.grant_0(ip_wr_grant0),
.xfer_done0(wr_xfer_done0),
.processing_submaster_0(processing_submaster_0),
.start_1(ip_wr_start1),
.grant_1(ip_wr_grant1),
.xfer_done1(wr_xfer_done1),
.processing_submaster_1(processing_submaster_1),
.start_2(ip_wr_start2),
.grant_2(ip_wr_grant2),
.xfer_done2(wr_xfer_done2),
.processing_submaster_2(processing_submaster_2),
.reset_n(reset_n)
);
submaster_rd_arb submaster_rd_arb(
.clk(clk),

.start_0(ip_rd_start0),
.grant_0(ip_rd_grant0),
.xfer_done0(rd_xfer_done0),
.processing_submaster_0(),
.start_1(ip_rd_start1),
.grant_1(ip_rd_grant1),
.xfer_done1(rd_xfer_done1),
.processing_submaster_1(),
.start_2(ip_rd_start2),
.grant_2(ip_rd_grant2),
.xfer_done2(rd_xfer_done2),
.processing_submaster_2(),
.start_3(ip_rd_start3),
.grant_3(ip_rd_grant3),
.xfer_done3(rd_xfer_done3),
.processing_submaster_3(),
.reset_n(reset_n)
);

//include all RAM here itself
//below 2rams take input from 4k_aligned block and provides to convertor block to be converted to asize,alen,etc
mem_with_controller #(7,3,83) axi_waddr_mem

(
.clk(clk),
.reset_n(reset_n),
.wr(ram4k_wr_waddr_mem),
.rd(wr_raddr_mem),
.empty(empty_waddr_mem),
.datain(ram4k_wrdata_waddr_mem),
.dataout(dataout_waddr_mem)
);

mem_with_controller #(7,3,83) axi_raddr_mem(
.clk(clk),
.reset_n(reset_n),
.wr(ram4k_wr_raddr_mem),
.rd(rd_raddr_mem),
.empty(empty_raddr_mem),
.datain(ram4k_wrdata_raddr_mem),
.dataout(dataout_raddr_mem)
);


//below 2 rams take input from convertor module and provides to axi_rd_wr module to drive the address phase of signals to AXI slave 
mem_with_controller #(7,3,97) axi_conv_rd_mem(
.clk(clk),
.reset_n(reset_n),
.wr(ram_axi_conv_wr_rd_converter),
.rd(addrtrans_mem_rd_rd),
.empty(addrtrans_fifo_empty_rd),
.datain(ram_wrdata_rd_converter),
.dataout(addrtrans_mem_rddata_rd)
);


//below 2 rams take address phase issued by DUT from axi_rd_wr and provide to rd_channel and wr_channel to perform read and write transactions..this will be based on id

assign acc_rd_ram0= axi_arvalid & axi_arready & axi_arid == 0;
assign addrtrans_fifo_empty_rd0=addrtrans_fifo_empty_rd & current_rid_in_process == 0;

mem_with_controller #(7,3,97)axi_rchanel_mem_0(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram0),
.rd(addrtrans_mem_rd_rd_0),
.empty(addrtrans_fifo_empty_rd_0),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_0),
.dataout(axi_conv_fifo_rddata_0)
);
assign acc_rd_ram1= axi_arvalid & axi_arready & axi_arid == 1;
assign addrtrans_fifo_empty_rd1=addrtrans_fifo_empty_rd & current_rid_in_process == 1;

mem_with_controller #(7,3,97)axi_rchanel_mem_1(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram1),
.rd(addrtrans_mem_rd_rd_1),
.empty(addrtrans_fifo_empty_rd_1),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_1),
.dataout(axi_conv_fifo_rddata_1)
);
assign acc_rd_ram2= axi_arvalid & axi_arready & axi_arid == 2;
assign addrtrans_fifo_empty_rd2=addrtrans_fifo_empty_rd & current_rid_in_process == 2;

mem_with_controller #(7,3,97)axi_rchanel_mem_2(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram2),
.rd(addrtrans_mem_rd_rd_2),
.empty(addrtrans_fifo_empty_rd_2),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_2),
.dataout(axi_conv_fifo_rddata_2)
);
assign acc_rd_ram3= axi_arvalid & axi_arready & axi_arid == 3;
assign addrtrans_fifo_empty_rd3=addrtrans_fifo_empty_rd & current_rid_in_process == 3;

mem_with_controller #(7,3,97)axi_rchanel_mem_3(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram3),
.rd(addrtrans_mem_rd_rd_3),
.empty(addrtrans_fifo_empty_rd_3),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_3),
.dataout(axi_conv_fifo_rddata_3)
);
assign acc_rd_ram4= axi_arvalid & axi_arready & axi_arid == 4;
assign addrtrans_fifo_empty_rd4=addrtrans_fifo_empty_rd & current_rid_in_process == 4;

mem_with_controller #(7,3,97)axi_rchanel_mem_4(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram4),
.rd(addrtrans_mem_rd_rd_4),
.empty(addrtrans_fifo_empty_rd_4),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_4),
.dataout(axi_conv_fifo_rddata_4)
);
assign acc_rd_ram5= axi_arvalid & axi_arready & axi_arid == 5;
assign addrtrans_fifo_empty_rd5=addrtrans_fifo_empty_rd & current_rid_in_process == 5;

mem_with_controller #(7,3,97)axi_rchanel_mem_5(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram5),
.rd(addrtrans_mem_rd_rd_5),
.empty(addrtrans_fifo_empty_rd_5),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_5),
.dataout(axi_conv_fifo_rddata_5)
);
assign acc_rd_ram6= axi_arvalid & axi_arready & axi_arid == 6;
assign addrtrans_fifo_empty_rd6=addrtrans_fifo_empty_rd & current_rid_in_process == 6;

mem_with_controller #(7,3,97)axi_rchanel_mem_6(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram6),
.rd(addrtrans_mem_rd_rd_6),
.empty(addrtrans_fifo_empty_rd_6),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_6),
.dataout(axi_conv_fifo_rddata_6)
);
assign acc_rd_ram7= axi_arvalid & axi_arready & axi_arid == 7;
assign addrtrans_fifo_empty_rd7=addrtrans_fifo_empty_rd & current_rid_in_process == 7;

mem_with_controller #(7,3,97)axi_rchanel_mem_7(
.clk(clk),
.reset_n(reset_n),
.wr(rd_transfifo_wr_rd & acc_rd_ram7),
.rd(addrtrans_mem_rd_rd_7),
.empty(addrtrans_fifo_empty_rd_7),
.datain(io_transfifo_wrdata_rd),// & acc_rd_ram_7),
.dataout(axi_conv_fifo_rddata_7)
);
//to do ..use different IDs for Read and write ID width
endmodule