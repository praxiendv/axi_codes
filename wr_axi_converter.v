module wr_axi_converter(
input clk,
input reset_n,
input rd_converter,
input fifo_empty,//this is 4K address fifo empty signal which has 4K aligned address and bytecounts
input [82:0]ram4k_rddata,






output ram_4k_rd,
output [7:0] axi_awid,
output [63:0] axi_wraddr,
output reg [2:0] axi_awlen,
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


//Submaster wrdata
output rd_submaster_wrfifo,
input [511:0] ip_data,
output xfer_done,

//for axi read 
output rd_transfifo_wr,
output [96:0]io_transfifo_wrdata
);
reg[1:0] pstate,nstate;
parameter[1:0] IDLE_ST=0,
               ADDR_ST=1,
               DATA_ST=2,
               RESP_ST=3;
reg [511:0] ip_data_d;
wire [6:0] curr_transfer_count;
reg[63:0] temp_axi_wstrb_shifted;
wire [63:0] temp_axi_wstrb;
wire bytecount_reached;
wire [5:0] addr;
wire [11:0]bytecount;
wire [11:0]bytecount_axi_rd;
reg resp_st_d;
wire pos_resp_st;
wire fifo_rd_blk;
wire[5:0] unaligned_bytecount;
reg [11:0]tot_transfer_count;
reg [11:0]rd_transfer_count;
reg ram_4k_rd_d;
reg axi_bvalid_lat;
reg axi_wvalid_lat;
reg[11:0] tot_bytecount;
reg [5:0]temp_addr;
//reg[6:0] space_available;
wire[6:0] bytes_transferred;
reg[6:0] bytes_transferred_lat;

reg [511:0] ip_data_residue;
reg [6:0] residue_count;

wire[6:0] residue_count_sig;
wire[6:0]bytes_transferred_residue_count;
always@(*)
begin
nstate=IDLE_ST;
case(pstate)
  IDLE_ST:
    if(!fifo_empty)
      nstate = ADDR_ST;
    else
      nstate = IDLE_ST;
  ADDR_ST:
    if(axi_awready)
     begin
      if(!rd_converter)
         nstate = DATA_ST;
      else
         nstate = IDLE_ST;
     end
    else
      nstate = ADDR_ST;
  DATA_ST:
    if(bytecount_reached & axi_wready)
      nstate = RESP_ST;
    else
      nstate = DATA_ST;
  RESP_ST:
    if(axi_bvalid | axi_bvalid_lat)
      nstate = IDLE_ST;
    else
      nstate = RESP_ST;
endcase
end


always@(posedge clk or negedge reset_n)
  if(!reset_n)
    pstate <= IDLE_ST;
  else
    pstate <= nstate;

assign axi_awid=0;
assign addr=ram4k_rddata[5:0];
assign unaligned_bytecount=(addr == 'd0)?0:'d64-addr;
assign bytecount=(rd_converter)?ram4k_rddata[82:64]+unaligned_bytecount:ram4k_rddata[82:64];
assign bytecount_axi_rd=ram4k_rddata[82:64];
assign axi_awsize=6;//since 64
assign axi_awburst=1;//incremental burst
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    axi_awlen <= 0;
  else
    begin
      if(bytecount > 64)
       begin
        if(bytecount % 64 == 'd0) 
           axi_awlen <= (bytecount >> 6) -1;//64 is due to 512bit datawidth
        else
           axi_awlen <= (bytecount >> 6) ;//64 is due to 512bit datawidth
       end
      else
        axi_awlen <= 0;
    end
assign axi_awvalid=pstate == ADDR_ST;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   axi_wvalid_lat <= 'd0;
  else 
   axi_wvalid_lat <= pstate == DATA_ST ;
assign axi_wvalid = ((pstate == DATA_ST | axi_wvalid_lat) & !bytecount_reached); 
assign axi_wrdata = 
                     (residue_count[5:0] == 0)?ip_data:

                     (residue_count == 1)?{ip_data[503:0],ip_data_residue[7:0]}:

                     (residue_count == 2)?{ip_data[495:0],ip_data_residue[15:0]}:

                     (residue_count == 3)?{ip_data[487:0],ip_data_residue[23:0]}:

                     (residue_count == 4)?{ip_data[479:0],ip_data_residue[31:0]}:

                     (residue_count == 5)?{ip_data[471:0],ip_data_residue[39:0]}:

                     (residue_count == 6)?{ip_data[463:0],ip_data_residue[47:0]}:

                     (residue_count == 7)?{ip_data[455:0],ip_data_residue[55:0]}:

                     (residue_count == 8)?{ip_data[447:0],ip_data_residue[63:0]}:

                     (residue_count == 9)?{ip_data[439:0],ip_data_residue[71:0]}:

                     (residue_count == 10)?{ip_data[431:0],ip_data_residue[79:0]}:

                     (residue_count == 11)?{ip_data[423:0],ip_data_residue[87:0]}:

                     (residue_count == 12)?{ip_data[415:0],ip_data_residue[95:0]}:

                     (residue_count == 13)?{ip_data[407:0],ip_data_residue[103:0]}:

                     (residue_count == 14)?{ip_data[399:0],ip_data_residue[111:0]}:

                     (residue_count == 15)?{ip_data[391:0],ip_data_residue[119:0]}:

                     (residue_count == 16)?{ip_data[383:0],ip_data_residue[127:0]}:

                     (residue_count == 17)?{ip_data[375:0],ip_data_residue[135:0]}:

                     (residue_count == 18)?{ip_data[367:0],ip_data_residue[143:0]}:

                     (residue_count == 19)?{ip_data[359:0],ip_data_residue[151:0]}:

                     (residue_count == 20)?{ip_data[351:0],ip_data_residue[159:0]}:

                     (residue_count == 21)?{ip_data[343:0],ip_data_residue[167:0]}:

                     (residue_count == 22)?{ip_data[335:0],ip_data_residue[175:0]}:

                     (residue_count == 23)?{ip_data[327:0],ip_data_residue[183:0]}:

                     (residue_count == 24)?{ip_data[319:0],ip_data_residue[191:0]}:

                     (residue_count == 25)?{ip_data[311:0],ip_data_residue[199:0]}:

                     (residue_count == 26)?{ip_data[303:0],ip_data_residue[207:0]}:

                     (residue_count == 27)?{ip_data[295:0],ip_data_residue[215:0]}:

                     (residue_count == 28)?{ip_data[287:0],ip_data_residue[223:0]}:

                     (residue_count == 29)?{ip_data[279:0],ip_data_residue[231:0]}:

                     (residue_count == 30)?{ip_data[271:0],ip_data_residue[239:0]}:

                     (residue_count == 31)?{ip_data[263:0],ip_data_residue[247:0]}:

                     (residue_count == 32)?{ip_data[255:0],ip_data_residue[255:0]}:

                     (residue_count == 33)?{ip_data[247:0],ip_data_residue[263:0]}:

                     (residue_count == 34)?{ip_data[239:0],ip_data_residue[271:0]}:

                     (residue_count == 35)?{ip_data[231:0],ip_data_residue[279:0]}:

                     (residue_count == 36)?{ip_data[223:0],ip_data_residue[287:0]}:

                     (residue_count == 37)?{ip_data[215:0],ip_data_residue[295:0]}:

                     (residue_count == 38)?{ip_data[207:0],ip_data_residue[303:0]}:

                     (residue_count == 39)?{ip_data[199:0],ip_data_residue[311:0]}:

                     (residue_count == 40)?{ip_data[191:0],ip_data_residue[319:0]}:

                     (residue_count == 41)?{ip_data[183:0],ip_data_residue[327:0]}:

                     (residue_count == 42)?{ip_data[175:0],ip_data_residue[335:0]}:

                     (residue_count == 43)?{ip_data[167:0],ip_data_residue[343:0]}:

                     (residue_count == 44)?{ip_data[159:0],ip_data_residue[351:0]}:

                     (residue_count == 45)?{ip_data[151:0],ip_data_residue[359:0]}:

                     (residue_count == 46)?{ip_data[143:0],ip_data_residue[367:0]}:

                     (residue_count == 47)?{ip_data[135:0],ip_data_residue[375:0]}:

                     (residue_count == 48)?{ip_data[127:0],ip_data_residue[383:0]}:

                     (residue_count == 49)?{ip_data[119:0],ip_data_residue[391:0]}:

                     (residue_count == 50)?{ip_data[111:0],ip_data_residue[399:0]}:

                     (residue_count == 51)?{ip_data[103:0],ip_data_residue[407:0]}:

                     (residue_count == 52)?{ip_data[95:0],ip_data_residue[415:0]}:

                     (residue_count == 53)?{ip_data[87:0],ip_data_residue[423:0]}:

                     (residue_count == 54)?{ip_data[79:0],ip_data_residue[431:0]}:

                     (residue_count == 55)?{ip_data[71:0],ip_data_residue[439:0]}:

                     (residue_count == 56)?{ip_data[63:0],ip_data_residue[447:0]}:

                     (residue_count == 57)?{ip_data[55:0],ip_data_residue[455:0]}:

                     (residue_count == 58)?{ip_data[47:0],ip_data_residue[463:0]}:

                     (residue_count == 59)?{ip_data[39:0],ip_data_residue[471:0]}:

                     (residue_count == 60)?{ip_data[31:0],ip_data_residue[479:0]}:

                     (residue_count == 61)?{ip_data[23:0],ip_data_residue[487:0]}:

                     (residue_count == 62)?{ip_data[15:0],ip_data_residue[495:0]}:

                     (residue_count == 63)?{ip_data[7:0],ip_data_residue[503:0]}:
                     0;
                    //(residue_count == 'd1)?{ip_data[511:0],ip_data_residue[7:0]};
assign rd_submaster_wrfifo=(axi_wvalid & axi_wready & tot_bytecount > 'd64 & !fifo_rd_blk) | (pstate == ADDR_ST & axi_awready & (tot_transfer_count !=rd_transfer_count ));
assign axi_bready=1;
assign axi_wid=0;
assign ram_4k_rd=((pos_resp_st & !rd_converter) | ( pstate == ADDR_ST & rd_converter & axi_awready)) & !fifo_empty;
assign pos_resp_st=pstate == RESP_ST & !resp_st_d;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    resp_st_d <= 'd0;
  else
    resp_st_d <= pstate == RESP_ST;
 
assign xfer_done = ram_4k_rd_d & fifo_empty;
assign axi_wlast=pstate == DATA_ST & tot_bytecount <= 'd64;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    ram_4k_rd_d <= 'd0;
  else
    ram_4k_rd_d <= ram_4k_rd;

assign temp_axi_wstrb=(bytes_transferred==64)?'hFFFF_FFFF_FFFF_FFFF:
                      (bytes_transferred==63)?'h7FFF_FFFF_FFFF_FFFF:
                      (bytes_transferred==62)?'h3FFF_FFFF_FFFF_FFFF:
                      (bytes_transferred==61)?'h1FFF_FFFF_FFFF_FFFF:
                      (bytes_transferred==60)?'hFFF_FFFF_FFFF_FFFF:
                      (bytes_transferred==59)?'h7FF_FFFF_FFFF_FFFF:
                      (bytes_transferred==58)?'h3FF_FFFF_FFFF_FFFF:
                      (bytes_transferred==57)?'h1FF_FFFF_FFFF_FFFF:
                      (bytes_transferred==56)?'hFF_FFFF_FFFF_FFFF:
                      (bytes_transferred==55)?'h7F_FFFF_FFFF_FFFF:
                      (bytes_transferred==54)?'h3F_FFFF_FFFF_FFFF:
                      (bytes_transferred==53)?'h1F_FFFF_FFFF_FFFF:
                      (bytes_transferred==52)?'hF_FFFF_FFFF_FFFF:
                      (bytes_transferred==51)?'h7_FFFF_FFFF_FFFF:
                      (bytes_transferred==50)?'h3_FFFF_FFFF_FFFF:
                      (bytes_transferred==49)?'h1_FFFF_FFFF_FFFF:
                      (bytes_transferred==48)?'hFFFF_FFFF_FFFF:
                      (bytes_transferred==47)?'h7FFF_FFFF_FFFF:
                      (bytes_transferred==46)?'h3FFF_FFFF_FFFF:
                      (bytes_transferred==45)?'h1FFF_FFFF_FFFF:
                      (bytes_transferred==44)?'hFFF_FFFF_FFFF:
                      (bytes_transferred==43)?'h7FF_FFFF_FFFF:
                      (bytes_transferred==42)?'h3FF_FFFF_FFFF:
                      (bytes_transferred==41)?'h1FF_FFFF_FFFF:
                      (bytes_transferred==40)?'hFF_FFFF_FFFF:
                      (bytes_transferred==39)?'h7F_FFFF_FFFF:
                      (bytes_transferred==38)?'h3F_FFFF_FFFF:
                      (bytes_transferred==37)?'h1F_FFFF_FFFF:
                      (bytes_transferred==36)?'hF_FFFF_FFFF:
                      (bytes_transferred==35)?'h7_FFFF_FFFF:
                      (bytes_transferred==34)?'h3_FFFF_FFFF:
                      (bytes_transferred==33)?'h1_FFFF_FFFF:
                      (bytes_transferred==32)?'hFFFF_FFFF:
                      (bytes_transferred==31)?'h7FFF_FFFF:
                      (bytes_transferred==30)?'h3FFF_FFFF:
                      (bytes_transferred==29)?'h1FFF_FFFF:
                      (bytes_transferred==28)?'hFFF_FFFF:
                      (bytes_transferred==27)?'h7FF_FFFF:
                      (bytes_transferred==26)?'h3FF_FFFF:
                      (bytes_transferred==25)?'h1FF_FFFF:
                      (bytes_transferred==24)?'hFF_FFFF:
                      (bytes_transferred==23)?'h7F_FFFF:
                      (bytes_transferred==22)?'h3F_FFFF:
                      (bytes_transferred==21)?'h1F_FFFF:
                      (bytes_transferred==20)?'hF_FFFF:
                      (bytes_transferred==19)?'h7_FFFF:
                      (bytes_transferred==18)?'h3_FFFF:
                      (bytes_transferred==17)?'h1_FFFF:
                      (bytes_transferred==16)?'hFFFF:
                      (bytes_transferred==15)?'h7FFF:
                      (bytes_transferred==14)?'h3FFF:
                      (bytes_transferred==13)?'h1FFF:
                      (bytes_transferred==12)?'hFFF:
                      (bytes_transferred==11)?'h7FF:
                      (bytes_transferred==10)?'h3FF:
                      (bytes_transferred==9)?'h1FF:
                      (bytes_transferred==8)?'hFF:
                      (bytes_transferred==7)?'h7F:
                      (bytes_transferred==6)?'h3F:
                      (bytes_transferred==5)?'h1F:
                      (bytes_transferred==4)?'hF:
                      (bytes_transferred==3)?'h7:
                      (bytes_transferred==2)?'h3:
                      (bytes_transferred==1)?'h1:
                      0;

assign bytes_transferred_residue_count  =(axi_wlast &  axi_wvalid & axi_wready)?(64-bytes_transferred):'d0;
assign alignment_reqd=temp_addr[5:0] !=0;
assign axi_wstrb = temp_axi_wstrb;
always@(*)
begin
temp_axi_wstrb_shifted=0;
case(temp_addr[5:0])
  0 :temp_axi_wstrb_shifted = temp_axi_wstrb << 0;
  1 :temp_axi_wstrb_shifted = temp_axi_wstrb << 1;
  2 :temp_axi_wstrb_shifted = temp_axi_wstrb << 2;
  3 :temp_axi_wstrb_shifted = temp_axi_wstrb << 3;
  4 :temp_axi_wstrb_shifted = temp_axi_wstrb << 4;
  5 :temp_axi_wstrb_shifted = temp_axi_wstrb << 5;
  6 :temp_axi_wstrb_shifted = temp_axi_wstrb << 6;
  7 :temp_axi_wstrb_shifted = temp_axi_wstrb << 7;
  8 :temp_axi_wstrb_shifted = temp_axi_wstrb << 8;
  9 :temp_axi_wstrb_shifted = temp_axi_wstrb << 9;
  10 :temp_axi_wstrb_shifted = temp_axi_wstrb << 10;
  11 :temp_axi_wstrb_shifted = temp_axi_wstrb << 11;
  12 :temp_axi_wstrb_shifted = temp_axi_wstrb << 12;
  13 :temp_axi_wstrb_shifted = temp_axi_wstrb << 13;
  14 :temp_axi_wstrb_shifted = temp_axi_wstrb << 14;
  15 :temp_axi_wstrb_shifted = temp_axi_wstrb << 15;
  16 :temp_axi_wstrb_shifted = temp_axi_wstrb << 16;
  17 :temp_axi_wstrb_shifted = temp_axi_wstrb << 17;
  18 :temp_axi_wstrb_shifted = temp_axi_wstrb << 18;
  19 :temp_axi_wstrb_shifted = temp_axi_wstrb << 19;
  20 :temp_axi_wstrb_shifted = temp_axi_wstrb << 20;
  21 :temp_axi_wstrb_shifted = temp_axi_wstrb << 21;
  22 :temp_axi_wstrb_shifted = temp_axi_wstrb << 22;
  23 :temp_axi_wstrb_shifted = temp_axi_wstrb << 23;
  24 :temp_axi_wstrb_shifted = temp_axi_wstrb << 24;
  25 :temp_axi_wstrb_shifted = temp_axi_wstrb << 25;
  26 :temp_axi_wstrb_shifted = temp_axi_wstrb << 26;
  27 :temp_axi_wstrb_shifted = temp_axi_wstrb << 27;
  28 :temp_axi_wstrb_shifted = temp_axi_wstrb << 28;
  29 :temp_axi_wstrb_shifted = temp_axi_wstrb << 29;
  30 :temp_axi_wstrb_shifted = temp_axi_wstrb << 30;
  31 :temp_axi_wstrb_shifted = temp_axi_wstrb << 31;
  32 :temp_axi_wstrb_shifted = temp_axi_wstrb << 32;
  33 :temp_axi_wstrb_shifted = temp_axi_wstrb << 33;
  34 :temp_axi_wstrb_shifted = temp_axi_wstrb << 34;
  35 :temp_axi_wstrb_shifted = temp_axi_wstrb << 35;
  36 :temp_axi_wstrb_shifted = temp_axi_wstrb << 36;
  37 :temp_axi_wstrb_shifted = temp_axi_wstrb << 37;
  38 :temp_axi_wstrb_shifted = temp_axi_wstrb << 38;
  39 :temp_axi_wstrb_shifted = temp_axi_wstrb << 39;
  40 :temp_axi_wstrb_shifted = temp_axi_wstrb << 40;
  41 :temp_axi_wstrb_shifted = temp_axi_wstrb << 41;
  42 :temp_axi_wstrb_shifted = temp_axi_wstrb << 42;
  43 :temp_axi_wstrb_shifted = temp_axi_wstrb << 43;
  44 :temp_axi_wstrb_shifted = temp_axi_wstrb << 44;
  45 :temp_axi_wstrb_shifted = temp_axi_wstrb << 45;
  46 :temp_axi_wstrb_shifted = temp_axi_wstrb << 46;
  47 :temp_axi_wstrb_shifted = temp_axi_wstrb << 47;
  48 :temp_axi_wstrb_shifted = temp_axi_wstrb << 48;
  49 :temp_axi_wstrb_shifted = temp_axi_wstrb << 49;
  50 :temp_axi_wstrb_shifted = temp_axi_wstrb << 50;
  51 :temp_axi_wstrb_shifted = temp_axi_wstrb << 51;
  52 :temp_axi_wstrb_shifted = temp_axi_wstrb << 52;
  53 :temp_axi_wstrb_shifted = temp_axi_wstrb << 53;
  54 :temp_axi_wstrb_shifted = temp_axi_wstrb << 54;
  55 :temp_axi_wstrb_shifted = temp_axi_wstrb << 55;
  56 :temp_axi_wstrb_shifted = temp_axi_wstrb << 56;
  57 :temp_axi_wstrb_shifted = temp_axi_wstrb << 57;
  58 :temp_axi_wstrb_shifted = temp_axi_wstrb << 58;
  59 :temp_axi_wstrb_shifted = temp_axi_wstrb << 59;
  60 :temp_axi_wstrb_shifted = temp_axi_wstrb << 60;
  61 :temp_axi_wstrb_shifted = temp_axi_wstrb << 61;
  62 :temp_axi_wstrb_shifted = temp_axi_wstrb << 62;
  63 :temp_axi_wstrb_shifted = temp_axi_wstrb << 63;
  
endcase
end

assign bytecount_reached = ~(|tot_bytecount);
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    tot_bytecount <= 0;
  else if(pstate == IDLE_ST & !fifo_empty)
    tot_bytecount <= bytecount ;
  else if(pstate == DATA_ST & axi_wready)
    begin
      if(tot_bytecount <= 'd64)
        tot_bytecount <= 0;
      else
        tot_bytecount <= tot_bytecount - 'd64; 
    end

/*always@(*)
begin
space_available=0;
       case(temp_addr[5:0])
           0 :space_available = 64;
           1 :space_available = 63;
           2 :space_available = 62;
           3 :space_available = 61;
           4 :space_available = 60;
           5 :space_available = 59;
           6 :space_available = 58;
           7 :space_available = 57;
           8 :space_available = 56;
           9 :space_available = 55;
           10 :space_available = 54;
           11 :space_available = 53;
           12 :space_available = 52;
           13 :space_available = 51;
           14 :space_available = 50;
           15 :space_available = 49;
           16 :space_available = 48;
           17 :space_available = 47;
           18 :space_available = 46;
           19 :space_available = 45;
           20 :space_available = 44;
           21 :space_available = 43;
           22 :space_available = 42;
           23 :space_available = 41;
           24 :space_available = 40;
           25 :space_available = 39;
           26 :space_available = 38;
           27 :space_available = 37;
           28 :space_available = 36;
           29 :space_available = 35;
           30 :space_available = 34;
           31 :space_available = 33;
           32 :space_available = 32;
           33 :space_available = 31;
           34 :space_available = 30;
           35 :space_available = 29;
           36 :space_available = 28;
           37 :space_available = 27;
           38 :space_available = 26;
           39 :space_available = 25;
           40 :space_available = 24;
           41 :space_available = 23;
           42 :space_available = 22;
           43 :space_available = 21;
           44 :space_available = 20;
           45 :space_available = 19;
           46 :space_available = 18;
           47 :space_available = 17;
           48 :space_available = 16;
           49 :space_available = 15;
           50 :space_available = 14;
           51 :space_available = 13;
           52 :space_available = 12;
           53 :space_available = 11;
           54 :space_available = 10;
           55 :space_available = 9;
           56 :space_available = 8;
           57 :space_available = 7;
           58 :space_available = 6;
           59 :space_available = 5;
           60 :space_available = 4;
           61 :space_available = 3;
           62 :space_available = 2;
           63 :space_available = 1;
       endcase
end
*/

assign bytes_transferred = (tot_bytecount >= 'd64 )? 'd64:tot_bytecount;


assign axi_wraddr= ram4k_rddata[63:0];
assign axi_awcache= 0;/////
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    axi_bvalid_lat <= 'd0;
  else if(axi_bvalid)
    axi_bvalid_lat <= 'd1;
  else if(pstate == RESP_ST)
    axi_bvalid_lat <= 'd0;

always@(posedge clk or negedge reset_n)
     if(!reset_n)
       ip_data_d <= 'd0;
     else if(axi_wvalid & axi_wready )
       ip_data_d <= ip_data;
always@(posedge clk or negedge reset_n)
     if(!reset_n)
       ip_data_residue <= 'd0;
      else if( axi_wvalid & axi_wready & axi_wlast)
       begin
         if(bytes_transferred_residue_count[5:0] == 'd0)
            ip_data_residue <= 'd0;
         else if(bytes_transferred_residue_count == 'd1)

            ip_data_residue <= {504,ip_data[511:504] };
         else if(bytes_transferred_residue_count == 'd2)

            ip_data_residue <= {496,ip_data[511:496] };
         else if(bytes_transferred_residue_count == 'd3)

            ip_data_residue <= {488,ip_data[511:488] };
         else if(bytes_transferred_residue_count == 'd4)

            ip_data_residue <= {480,ip_data[511:480] };
         else if(bytes_transferred_residue_count == 'd5)

            ip_data_residue <= {472,ip_data[511:472] };
         else if(bytes_transferred_residue_count == 'd6)

            ip_data_residue <= {464,ip_data[511:464] };
         else if(bytes_transferred_residue_count == 'd7)

            ip_data_residue <= {456,ip_data[511:456] };
         else if(bytes_transferred_residue_count == 'd8)

            ip_data_residue <= {448,ip_data[511:448] };
         else if(bytes_transferred_residue_count == 'd9)

            ip_data_residue <= {440,ip_data[511:440] };
         else if(bytes_transferred_residue_count == 'd10)

            ip_data_residue <= {432,ip_data[511:432] };
         else if(bytes_transferred_residue_count == 'd11)

            ip_data_residue <= {424,ip_data[511:424] };
         else if(bytes_transferred_residue_count == 'd12)

            ip_data_residue <= {416,ip_data[511:416] };
         else if(bytes_transferred_residue_count == 'd13)

            ip_data_residue <= {408,ip_data[511:408] };
         else if(bytes_transferred_residue_count == 'd14)

            ip_data_residue <= {400,ip_data[511:400] };
         else if(bytes_transferred_residue_count == 'd15)

            ip_data_residue <= {392,ip_data[511:392] };
         else if(bytes_transferred_residue_count == 'd16)

            ip_data_residue <= {384,ip_data[511:384] };
         else if(bytes_transferred_residue_count == 'd17)

            ip_data_residue <= {376,ip_data[511:376] };
         else if(bytes_transferred_residue_count == 'd18)

            ip_data_residue <= {368,ip_data[511:368] };
         else if(bytes_transferred_residue_count == 'd19)

            ip_data_residue <= {360,ip_data[511:360] };
         else if(bytes_transferred_residue_count == 'd20)

            ip_data_residue <= {352,ip_data[511:352] };
         else if(bytes_transferred_residue_count == 'd21)

            ip_data_residue <= {344,ip_data[511:344] };
         else if(bytes_transferred_residue_count == 'd22)

            ip_data_residue <= {336,ip_data[511:336] };
         else if(bytes_transferred_residue_count == 'd23)

            ip_data_residue <= {328,ip_data[511:328] };
         else if(bytes_transferred_residue_count == 'd24)

            ip_data_residue <= {320,ip_data[511:320] };
         else if(bytes_transferred_residue_count == 'd25)

            ip_data_residue <= {312,ip_data[511:312] };
         else if(bytes_transferred_residue_count == 'd26)

            ip_data_residue <= {304,ip_data[511:304] };
         else if(bytes_transferred_residue_count == 'd27)

            ip_data_residue <= {296,ip_data[511:296] };
         else if(bytes_transferred_residue_count == 'd28)

            ip_data_residue <= {288,ip_data[511:288] };
         else if(bytes_transferred_residue_count == 'd29)

            ip_data_residue <= {280,ip_data[511:280] };
         else if(bytes_transferred_residue_count == 'd30)

            ip_data_residue <= {272,ip_data[511:272] };
         else if(bytes_transferred_residue_count == 'd31)

            ip_data_residue <= {264,ip_data[511:264] };
         else if(bytes_transferred_residue_count == 'd32)

            ip_data_residue <= {256,ip_data[511:256] };
         else if(bytes_transferred_residue_count == 'd33)

            ip_data_residue <= {248,ip_data[511:248] };
         else if(bytes_transferred_residue_count == 'd34)

            ip_data_residue <= {240,ip_data[511:240] };
         else if(bytes_transferred_residue_count == 'd35)

            ip_data_residue <= {232,ip_data[511:232] };
         else if(bytes_transferred_residue_count == 'd36)

            ip_data_residue <= {224,ip_data[511:224] };
         else if(bytes_transferred_residue_count == 'd37)

            ip_data_residue <= {216,ip_data[511:216] };
         else if(bytes_transferred_residue_count == 'd38)

            ip_data_residue <= {208,ip_data[511:208] };
         else if(bytes_transferred_residue_count == 'd39)

            ip_data_residue <= {200,ip_data[511:200] };
         else if(bytes_transferred_residue_count == 'd40)

            ip_data_residue <= {192,ip_data[511:192] };
         else if(bytes_transferred_residue_count == 'd41)

            ip_data_residue <= {184,ip_data[511:184] };
         else if(bytes_transferred_residue_count == 'd42)

            ip_data_residue <= {176,ip_data[511:176] };
         else if(bytes_transferred_residue_count == 'd43)

            ip_data_residue <= {168,ip_data[511:168] };
         else if(bytes_transferred_residue_count == 'd44)

            ip_data_residue <= {160,ip_data[511:160] };
         else if(bytes_transferred_residue_count == 'd45)

            ip_data_residue <= {152,ip_data[511:152] };
         else if(bytes_transferred_residue_count == 'd46)

            ip_data_residue <= {144,ip_data[511:144] };
         else if(bytes_transferred_residue_count == 'd47)

            ip_data_residue <= {136,ip_data[511:136] };
         else if(bytes_transferred_residue_count == 'd48)

            ip_data_residue <= {128,ip_data[511:128] };
         else if(bytes_transferred_residue_count == 'd49)

            ip_data_residue <= {120,ip_data[511:120] };
         else if(bytes_transferred_residue_count == 'd50)

            ip_data_residue <= {112,ip_data[511:112] };
         else if(bytes_transferred_residue_count == 'd51)

            ip_data_residue <= {104,ip_data[511:104] };
         else if(bytes_transferred_residue_count == 'd52)

            ip_data_residue <= {96,ip_data[511:96] };
         else if(bytes_transferred_residue_count == 'd53)

            ip_data_residue <= {88,ip_data[511:88] };
         else if(bytes_transferred_residue_count == 'd54)

            ip_data_residue <= {80,ip_data[511:80] };
         else if(bytes_transferred_residue_count == 'd55)

            ip_data_residue <= {72,ip_data[511:72] };
         else if(bytes_transferred_residue_count == 'd56)

            ip_data_residue <= {64,ip_data[511:64] };
         else if(bytes_transferred_residue_count == 'd57)

            ip_data_residue <= {56,ip_data[511:56] };
         else if(bytes_transferred_residue_count == 'd58)

            ip_data_residue <= {48,ip_data[511:48] };
         else if(bytes_transferred_residue_count == 'd59)

            ip_data_residue <= {40,ip_data[511:40] };
         else if(bytes_transferred_residue_count == 'd60)

            ip_data_residue <= {32,ip_data[511:32] };
         else if(bytes_transferred_residue_count == 'd61)

            ip_data_residue <= {24,ip_data[511:24] };
         else if(bytes_transferred_residue_count == 'd62)

            ip_data_residue <= {16,ip_data[511:16] };
         else if(bytes_transferred_residue_count == 'd63)

            ip_data_residue <= {8,ip_data[511:8] };
       end  
     else if( axi_wvalid & axi_wready)
       begin
         if(residue_count[5:0] == 'd0)
            ip_data_residue <= 'd0;
         else if(residue_count == 'd1)

            ip_data_residue <= {504,ip_data[511:504] };
         else if(residue_count == 'd2)

            ip_data_residue <= {496,ip_data[511:496] };
         else if(residue_count == 'd3)

            ip_data_residue <= {488,ip_data[511:488] };
         else if(residue_count == 'd4)

            ip_data_residue <= {480,ip_data[511:480] };
         else if(residue_count == 'd5)

            ip_data_residue <= {472,ip_data[511:472] };
         else if(residue_count == 'd6)

            ip_data_residue <= {464,ip_data[511:464] };
         else if(residue_count == 'd7)

            ip_data_residue <= {456,ip_data[511:456] };
         else if(residue_count == 'd8)

            ip_data_residue <= {448,ip_data[511:448] };
         else if(residue_count == 'd9)

            ip_data_residue <= {440,ip_data[511:440] };
         else if(residue_count == 'd10)

            ip_data_residue <= {432,ip_data[511:432] };
         else if(residue_count == 'd11)

            ip_data_residue <= {424,ip_data[511:424] };
         else if(residue_count == 'd12)

            ip_data_residue <= {416,ip_data[511:416] };
         else if(residue_count == 'd13)

            ip_data_residue <= {408,ip_data[511:408] };
         else if(residue_count == 'd14)

            ip_data_residue <= {400,ip_data[511:400] };
         else if(residue_count == 'd15)

            ip_data_residue <= {392,ip_data[511:392] };
         else if(residue_count == 'd16)

            ip_data_residue <= {384,ip_data[511:384] };
         else if(residue_count == 'd17)

            ip_data_residue <= {376,ip_data[511:376] };
         else if(residue_count == 'd18)

            ip_data_residue <= {368,ip_data[511:368] };
         else if(residue_count == 'd19)

            ip_data_residue <= {360,ip_data[511:360] };
         else if(residue_count == 'd20)

            ip_data_residue <= {352,ip_data[511:352] };
         else if(residue_count == 'd21)

            ip_data_residue <= {344,ip_data[511:344] };
         else if(residue_count == 'd22)

            ip_data_residue <= {336,ip_data[511:336] };
         else if(residue_count == 'd23)

            ip_data_residue <= {328,ip_data[511:328] };
         else if(residue_count == 'd24)

            ip_data_residue <= {320,ip_data[511:320] };
         else if(residue_count == 'd25)

            ip_data_residue <= {312,ip_data[511:312] };
         else if(residue_count == 'd26)

            ip_data_residue <= {304,ip_data[511:304] };
         else if(residue_count == 'd27)

            ip_data_residue <= {296,ip_data[511:296] };
         else if(residue_count == 'd28)

            ip_data_residue <= {288,ip_data[511:288] };
         else if(residue_count == 'd29)

            ip_data_residue <= {280,ip_data[511:280] };
         else if(residue_count == 'd30)

            ip_data_residue <= {272,ip_data[511:272] };
         else if(residue_count == 'd31)

            ip_data_residue <= {264,ip_data[511:264] };
         else if(residue_count == 'd32)

            ip_data_residue <= {256,ip_data[511:256] };
         else if(residue_count == 'd33)

            ip_data_residue <= {248,ip_data[511:248] };
         else if(residue_count == 'd34)

            ip_data_residue <= {240,ip_data[511:240] };
         else if(residue_count == 'd35)

            ip_data_residue <= {232,ip_data[511:232] };
         else if(residue_count == 'd36)

            ip_data_residue <= {224,ip_data[511:224] };
         else if(residue_count == 'd37)

            ip_data_residue <= {216,ip_data[511:216] };
         else if(residue_count == 'd38)

            ip_data_residue <= {208,ip_data[511:208] };
         else if(residue_count == 'd39)

            ip_data_residue <= {200,ip_data[511:200] };
         else if(residue_count == 'd40)

            ip_data_residue <= {192,ip_data[511:192] };
         else if(residue_count == 'd41)

            ip_data_residue <= {184,ip_data[511:184] };
         else if(residue_count == 'd42)

            ip_data_residue <= {176,ip_data[511:176] };
         else if(residue_count == 'd43)

            ip_data_residue <= {168,ip_data[511:168] };
         else if(residue_count == 'd44)

            ip_data_residue <= {160,ip_data[511:160] };
         else if(residue_count == 'd45)

            ip_data_residue <= {152,ip_data[511:152] };
         else if(residue_count == 'd46)

            ip_data_residue <= {144,ip_data[511:144] };
         else if(residue_count == 'd47)

            ip_data_residue <= {136,ip_data[511:136] };
         else if(residue_count == 'd48)

            ip_data_residue <= {128,ip_data[511:128] };
         else if(residue_count == 'd49)

            ip_data_residue <= {120,ip_data[511:120] };
         else if(residue_count == 'd50)

            ip_data_residue <= {112,ip_data[511:112] };
         else if(residue_count == 'd51)

            ip_data_residue <= {104,ip_data[511:104] };
         else if(residue_count == 'd52)

            ip_data_residue <= {96,ip_data[511:96] };
         else if(residue_count == 'd53)

            ip_data_residue <= {88,ip_data[511:88] };
         else if(residue_count == 'd54)

            ip_data_residue <= {80,ip_data[511:80] };
         else if(residue_count == 'd55)

            ip_data_residue <= {72,ip_data[511:72] };
         else if(residue_count == 'd56)

            ip_data_residue <= {64,ip_data[511:64] };
         else if(residue_count == 'd57)

            ip_data_residue <= {56,ip_data[511:56] };
         else if(residue_count == 'd58)

            ip_data_residue <= {48,ip_data[511:48] };
         else if(residue_count == 'd59)

            ip_data_residue <= {40,ip_data[511:40] };
         else if(residue_count == 'd60)

            ip_data_residue <= {32,ip_data[511:32] };
         else if(residue_count == 'd61)

            ip_data_residue <= {24,ip_data[511:24] };
         else if(residue_count == 'd62)

            ip_data_residue <= {16,ip_data[511:16] };
         else if(residue_count == 'd63)

            ip_data_residue <= {8,ip_data[511:8] };
       end















     
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    bytes_transferred_lat <= 'd0;
  else if(bytes_transferred < 'd64) 
    bytes_transferred_lat <= bytes_transferred;
/*
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    residue_count <= 'd0;
  else if(xfer_done)
    residue_count <= 'd0;
  else if(axi_wvalid & axi_wlast & bytes_transferred < 'd64)
    residue_count <= bytes_transferred;
  else if(axi_wvalid & axi_wready & residue_count!='d0)
    residue_count <= 'd64-residue_count;
*/

assign residue_count_sig=(pstate == DATA_ST & bytecount_reached & axi_wready )?(64 - (bytecount % 64)):residue_count;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    residue_count <= 'd0;
  else if(xfer_done)
    residue_count <= 'd0;
  else if(pstate== DATA_ST &  bytecount_reached & axi_wready )
    residue_count <= residue_count_sig;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    rd_transfer_count <= 'd0;
  else if(xfer_done)
    rd_transfer_count <= 'd0;
  else if(rd_submaster_wrfifo)
    rd_transfer_count <= rd_transfer_count+'d64;


always@(posedge clk or negedge reset_n)
  if(!reset_n)
    tot_transfer_count <= 'd0;
  else if(xfer_done)
    tot_transfer_count <= 'd0;
  else if(pstate == IDLE_ST & !fifo_empty)
    tot_transfer_count <= tot_transfer_count+bytecount;
assign fifo_rd_blk= (((rd_transfer_count+'d64) > tot_transfer_count & ((tot_transfer_count+'d64) % 'd64 == 0)) | (tot_transfer_count ==rd_transfer_count ));
assign rd_transfifo_wr = axi_awvalid & axi_awready;
assign io_transfifo_wrdata={ram4k_rddata[82:79],bytecount_axi_rd,axi_awsize,axi_awlen,axi_awid,axi_wraddr};
endmodule