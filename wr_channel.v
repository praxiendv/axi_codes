module wr_channel(
input clk,
input reset_n,
output rd_ip_fifo_0,
input axi_conv_fifo_empty_0, 
input [96:0]axi_conv_fifo_wrdata_0,
output rd_axi_conv_fifo_0,
input [511:0] ip_wr_data_0,
output rd_ip_fifo_1,
input axi_conv_fifo_empty_1, 
input [96:0]axi_conv_fifo_wrdata_1,
output rd_axi_conv_fifo_1,
input [511:0] ip_wr_data_1,
output rd_ip_fifo_2,
input axi_conv_fifo_empty_2, 
input [96:0]axi_conv_fifo_wrdata_2,
output rd_axi_conv_fifo_2,
input [511:0] ip_wr_data_2,
output rd_ip_fifo_3,
input axi_conv_fifo_empty_3, 
input [96:0]axi_conv_fifo_wrdata_3,
output rd_axi_conv_fifo_3,
input [511:0] ip_wr_data_3,
output rd_ip_fifo_4,
input axi_conv_fifo_empty_4, 
input [96:0]axi_conv_fifo_wrdata_4,
output rd_axi_conv_fifo_4,
input [511:0] ip_wr_data_4,
output rd_ip_fifo_5,
input axi_conv_fifo_empty_5, 
input [96:0]axi_conv_fifo_wrdata_5,
output rd_axi_conv_fifo_5,
input [511:0] ip_wr_data_5,
output rd_ip_fifo_6,
input axi_conv_fifo_empty_6, 
input [96:0]axi_conv_fifo_wrdata_6,
output rd_axi_conv_fifo_6,
input [511:0] ip_wr_data_6,
output rd_ip_fifo_7,
input axi_conv_fifo_empty_7, 
input [96:0]axi_conv_fifo_wrdata_7,
output rd_axi_conv_fifo_7,
input [511:0] ip_wr_data_7,

input [1:0] vcid_vc0,//this is required to select correct base address
input [63:0] tr_base_addr_vc0,//transfer base address based on vc number
input processing_vc0,//current vc under progress
input [1:0] vcid_vc1,//this is required to select correct base address
input [63:0] tr_base_addr_vc1,//transfer base address based on vc number
input processing_vc1,//current vc under progress

input wready,

output wvalid,
output reg [63:0] wstrb,
output [511:0] wdata,
output wlast,
output wid,//this is not valid for AXI4 but valid for AXI3
input bvalid,
input [1:0]bresp,
output bready

 
);
wire[5:0] address;
reg[1:0] p_state,n_state;
reg[11:0]bytes_to_be_transferred,bytes_transferred;//TBD remove hardcode
parameter[1:0] IDLE_P_ST=0,
               WR_TRANSFER_ST=1,
               WAIT_BRESP_ST=2;
wire [7:0] awid;
reg[8:0] pstate,nstate;
parameter[8:0]
    PROCESS_WR_TRANSFER_ST_0=0,
    PROCESS_WR_TRANSFER_ST_1=1,
    PROCESS_WR_TRANSFER_ST_2=2,
    PROCESS_WR_TRANSFER_ST_3=3,
    PROCESS_WR_TRANSFER_ST_4=4,
    PROCESS_WR_TRANSFER_ST_5=5,
    PROCESS_WR_TRANSFER_ST_6=6,
    PROCESS_WR_TRANSFER_ST_7=7,
    IDLE_ST=0;
  
always@(*)
begin
  case(pstate)
      IDLE_ST:
               if(!axi_conv_fifo_empty_0)
                  nstate = PROCESS_WR_TRANSFER_ST_0;
               else if(!axi_conv_fifo_empty_1)
                  nstate = PROCESS_WR_TRANSFER_ST_1;
               else if(!axi_conv_fifo_empty_2)
                  nstate = PROCESS_WR_TRANSFER_ST_2;
               else if(!axi_conv_fifo_empty_3)
                  nstate = PROCESS_WR_TRANSFER_ST_3;
               else if(!axi_conv_fifo_empty_4)
                  nstate = PROCESS_WR_TRANSFER_ST_4;
               else if(!axi_conv_fifo_empty_5)
                  nstate = PROCESS_WR_TRANSFER_ST_5;
               else if(!axi_conv_fifo_empty_6)
                  nstate = PROCESS_WR_TRANSFER_ST_6;
               else if(!axi_conv_fifo_empty_7)
                  nstate = PROCESS_WR_TRANSFER_ST_7;
               else
                  nstate = IDLE_ST;
      PROCESS_WR_TRANSFER_ST_0:
               if(axi_conv_fifo_empty_0)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_0;
      PROCESS_WR_TRANSFER_ST_1:
               if(axi_conv_fifo_empty_1)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_1;
      PROCESS_WR_TRANSFER_ST_2:
               if(axi_conv_fifo_empty_2)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_2;
      PROCESS_WR_TRANSFER_ST_3:
               if(axi_conv_fifo_empty_3)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_3;
      PROCESS_WR_TRANSFER_ST_4:
               if(axi_conv_fifo_empty_4)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_4;
      PROCESS_WR_TRANSFER_ST_5:
               if(axi_conv_fifo_empty_5)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_5;
      PROCESS_WR_TRANSFER_ST_6:
               if(axi_conv_fifo_empty_6)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_6;
      PROCESS_WR_TRANSFER_ST_7:
               if(axi_conv_fifo_empty_7)
                 nstate = IDLE_ST;
               else
                 nstate = PROCESS_WR_TRANSFER_ST_7;
endcase
end


always@(*)
begin
n_state = IDLE_P_ST;
  case(p_state)
    IDLE_P_ST:
     if(pstate != IDLE_P_ST)
        n_state = WR_TRANSFER_ST;
      else
        n_state = IDLE_P_ST;
    WR_TRANSFER_ST:
      if(wlast)
        n_state = WAIT_BRESP_ST;
      else
        n_state = WR_TRANSFER_ST;
    WAIT_BRESP_ST:
      if(bvalid)
        n_state = IDLE_P_ST;
      else
        n_state = WAIT_BRESP_ST;
endcase

end
               
//awsize is 3bit field
//awsize=0=>1
//awsize=1=>2
//awsize=2=>4
//awsize=3=>8
//awsize=4=>16
//awsize=5=>32
//awsize=6=>64
//awsize=7=>128
//awsize=8=>256

//awlen is 8bit field
//awlen=0=>1
//awlen=1=>2
//awlen=2=>3
//awlen=4=>4
//awlen=255=>256
assign num_transfers_0=axi_conv_fifo_wrdata_0[66 : 64] + 1;
assign bytes_in_each_transfer_0 = !(|axi_conv_fifo_wrdata_0[69 : 66])?'d1:axi_conv_fifo_wrdata_0[69 : 66] <<'d2;
assign bytecount_0=num_transfers_0 * bytes_in_each_transfer_0;//multiply len and size to get the bytecount to be transferred
assign num_transfers_1=axi_conv_fifo_wrdata_1[66 : 64] + 1;
assign bytes_in_each_transfer_1 = !(|axi_conv_fifo_wrdata_1[69 : 66])?'d1:axi_conv_fifo_wrdata_1[69 : 66] <<'d2;
assign bytecount_1=num_transfers_1 * bytes_in_each_transfer_1;//multiply len and size to get the bytecount to be transferred
assign num_transfers_2=axi_conv_fifo_wrdata_2[66 : 64] + 1;
assign bytes_in_each_transfer_2 = !(|axi_conv_fifo_wrdata_2[69 : 66])?'d1:axi_conv_fifo_wrdata_2[69 : 66] <<'d2;
assign bytecount_2=num_transfers_2 * bytes_in_each_transfer_2;//multiply len and size to get the bytecount to be transferred
assign num_transfers_3=axi_conv_fifo_wrdata_3[66 : 64] + 1;
assign bytes_in_each_transfer_3 = !(|axi_conv_fifo_wrdata_3[69 : 66])?'d1:axi_conv_fifo_wrdata_3[69 : 66] <<'d2;
assign bytecount_3=num_transfers_3 * bytes_in_each_transfer_3;//multiply len and size to get the bytecount to be transferred
assign num_transfers_4=axi_conv_fifo_wrdata_4[66 : 64] + 1;
assign bytes_in_each_transfer_4 = !(|axi_conv_fifo_wrdata_4[69 : 66])?'d1:axi_conv_fifo_wrdata_4[69 : 66] <<'d2;
assign bytecount_4=num_transfers_4 * bytes_in_each_transfer_4;//multiply len and size to get the bytecount to be transferred
assign num_transfers_5=axi_conv_fifo_wrdata_5[66 : 64] + 1;
assign bytes_in_each_transfer_5 = !(|axi_conv_fifo_wrdata_5[69 : 66])?'d1:axi_conv_fifo_wrdata_5[69 : 66] <<'d2;
assign bytecount_5=num_transfers_5 * bytes_in_each_transfer_5;//multiply len and size to get the bytecount to be transferred
assign num_transfers_6=axi_conv_fifo_wrdata_6[66 : 64] + 1;
assign bytes_in_each_transfer_6 = !(|axi_conv_fifo_wrdata_6[69 : 66])?'d1:axi_conv_fifo_wrdata_6[69 : 66] <<'d2;
assign bytecount_6=num_transfers_6 * bytes_in_each_transfer_6;//multiply len and size to get the bytecount to be transferred
assign num_transfers_7=axi_conv_fifo_wrdata_7[66 : 64] + 1;
assign bytes_in_each_transfer_7 = !(|axi_conv_fifo_wrdata_7[69 : 66])?'d1:axi_conv_fifo_wrdata_7[69 : 66] <<'d2;
assign bytecount_7=num_transfers_7 * bytes_in_each_transfer_7;//multiply len and size to get the bytecount to be transferred
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    bytes_to_be_transferred <= 'd0;
  else
    bytes_to_be_transferred <= 
                              (awid == 'd0)? bytecount_0 :
                              (awid == 'd1)? bytecount_1 :
                              (awid == 'd2)? bytecount_2 :
                              (awid == 'd3)? bytecount_3 :
                              (awid == 'd4)? bytecount_4 :
                              (awid == 'd5)? bytecount_5 :
                              (awid == 'd6)? bytecount_6 :
                              (awid == 'd7)? bytecount_7 :
                              'd0;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    bytes_transferred <= 'd0;
  else if(wvalid & wready)
    bytes_transferred <= bytes_transferred + 
                          wstrb[7] +  wstrb[6] +  wstrb[5] +  wstrb[4] +  wstrb[3] +  wstrb[2] +  wstrb[1] +  wstrb[0];

assign wlast= bytes_to_be_transferred == bytes_transferred;
assign axi_addr=
                    (awid == 'd0)? axi_conv_fifo_wrdata_0[5:0] : 
                    (awid == 'd1)? axi_conv_fifo_wrdata_1[5:0] : 
                    (awid == 'd2)? axi_conv_fifo_wrdata_2[5:0] : 
                    (awid == 'd3)? axi_conv_fifo_wrdata_3[5:0] : 
                    (awid == 'd4)? axi_conv_fifo_wrdata_4[5:0] : 
                    (awid == 'd5)? axi_conv_fifo_wrdata_5[5:0] : 
                    (awid == 'd6)? axi_conv_fifo_wrdata_6[5:0] : 
                    (awid == 'd7)? axi_conv_fifo_wrdata_7[5:0] : 
'd0;
assign awid=
                    (!axi_conv_fifo_empty_0)? axi_conv_fifo_wrdata_0[77 : 70] :
                    (!axi_conv_fifo_empty_1)? axi_conv_fifo_wrdata_1[77 : 70] :
                    (!axi_conv_fifo_empty_2)? axi_conv_fifo_wrdata_2[77 : 70] :
                    (!axi_conv_fifo_empty_3)? axi_conv_fifo_wrdata_3[77 : 70] :
                    (!axi_conv_fifo_empty_4)? axi_conv_fifo_wrdata_4[77 : 70] :
                    (!axi_conv_fifo_empty_5)? axi_conv_fifo_wrdata_5[77 : 70] :
                    (!axi_conv_fifo_empty_6)? axi_conv_fifo_wrdata_6[77 : 70] :
                    (!axi_conv_fifo_empty_7)? axi_conv_fifo_wrdata_7[77 : 70] :
'd0;
//assign aligned_address = !(|axi_addr[5:0]);



always@(*)
begin
wstrb=0;
case(address[5:0])
    'd0:wstrb=64'hFFFF_FFFF_FFFF_FFFF;
    'd1:wstrb=64'hFFFF_FFFF_FFFF_FFFE;
    'd2:wstrb=64'hFFFF_FFFF_FFFF_FFFC;
    'd3:wstrb=64'hFFFF_FFFF_FFFF_FFF8;
    'd4:wstrb=64'hFFFF_FFFF_FFFF_FFF;
    'd5:wstrb=64'hFFFF_FFFF_FFFF_FFE;
    'd6:wstrb=64'hFFFF_FFFF_FFFF_FFC;
    'd7:wstrb=64'hFFFF_FFFF_FFFF_FF8;
    'd8:wstrb=64'hFFFF_FFFF_FFFF_FF;
    'd9:wstrb=64'hFFFF_FFFF_FFFF_FE;
    'd10:wstrb=64'hFFFF_FFFF_FFFF_FC;
    'd11:wstrb=64'hFFFF_FFFF_FFFF_F8;
    'd12:wstrb=64'hFFFF_FFFF_FFFF_F;
    'd13:wstrb=64'hFFFF_FFFF_FFFF_E;
    'd14:wstrb=64'hFFFF_FFFF_FFFF_C;
    'd15:wstrb=64'hFFFF_FFFF_FFFF_8;
    'd16:wstrb=64'hFFFF_FFFF_FFFF;
    'd17:wstrb=64'hFFFF_FFFF_FFFE;
    'd18:wstrb=64'hFFFF_FFFF_FFFC;
    'd19:wstrb=64'hFFFF_FFFF_FFF8;
    'd20:wstrb=64'hFFFF_FFFF_FFF;
    'd21:wstrb=64'hFFFF_FFFF_FFE;
    'd22:wstrb=64'hFFFF_FFFF_FFC;
    'd23:wstrb=64'hFFFF_FFFF_FF8;
    'd24:wstrb=64'hFFFF_FFFF_FF;
    'd25:wstrb=64'hFFFF_FFFF_FE;
    'd26:wstrb=64'hFFFF_FFFF_FC;
    'd27:wstrb=64'hFFFF_FFFF_F8;
    'd28:wstrb=64'hFFFF_FFFF_F;
    'd29:wstrb=64'hFFFF_FFFF_E;
    'd30:wstrb=64'hFFFF_FFFF_C;
    'd31:wstrb=64'hFFFF_FFFF_8;
    'd32:wstrb=64'hFFFF_FFFF;
    'd33:wstrb=64'hFFFF_FFFE;
    'd34:wstrb=64'hFFFF_FFFC;
    'd35:wstrb=64'hFFFF_FFF8;
    'd36:wstrb=64'hFFFF_FFF;
    'd37:wstrb=64'hFFFF_FFE;
    'd38:wstrb=64'hFFFF_FFC;
    'd39:wstrb=64'hFFFF_FF8;
    'd40:wstrb=64'hFFFF_FF;
    'd41:wstrb=64'hFFFF_FE;
    'd42:wstrb=64'hFFFF_FC;
    'd43:wstrb=64'hFFFF_F8;
    'd44:wstrb=64'hFFFF_F;
    'd45:wstrb=64'hFFFF_E;
    'd46:wstrb=64'hFFFF_C;
    'd47:wstrb=64'hFFFF_8;
    'd48:wstrb=64'hFFFF;
    'd49:wstrb=64'hFFFE;
    'd50:wstrb=64'hFFFC;
    'd51:wstrb=64'hFFF8;
    'd52:wstrb=64'hFFF;
    'd53:wstrb=64'hFFE;
    'd54:wstrb=64'hFFC;
    'd55:wstrb=64'hFF8;
    'd56:wstrb=64'hFF;
    'd57:wstrb=64'hFE;
    'd58:wstrb=64'hFC;
    'd59:wstrb=64'hF8;
    'd60:wstrb=64'hF;
    'd61:wstrb=64'hE;
    'd62:wstrb=64'hC;
    'd63:wstrb=64'h8;
endcase
end 

assign rd_ip_fifo_7 = pstate == PROCESS_WR_TRANSFER_ST_7 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_6 = pstate == PROCESS_WR_TRANSFER_ST_6 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_5 = pstate == PROCESS_WR_TRANSFER_ST_5 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_4 = pstate == PROCESS_WR_TRANSFER_ST_4 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_3 = pstate == PROCESS_WR_TRANSFER_ST_3 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_2 = pstate == PROCESS_WR_TRANSFER_ST_2 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_1 = pstate == PROCESS_WR_TRANSFER_ST_1 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign rd_ip_fifo_0 = pstate == PROCESS_WR_TRANSFER_ST_0 & p_state ==  WR_TRANSFER_ST && wready && wvalid;
assign wdata =
               (awid == 7)?ip_wr_data_7 :
               (awid == 6)?ip_wr_data_6 :
               (awid == 5)?ip_wr_data_5 :
               (awid == 4)?ip_wr_data_4 :
               (awid == 3)?ip_wr_data_3 :
               (awid == 2)?ip_wr_data_2 :
               (awid == 1)?ip_wr_data_1 :
               (awid == 0)?ip_wr_data_0 :
'd0;

assign rd_axi_conv_fifo_0 =
                              (pstate ==PROCESS_WR_TRANSFER_ST_7 &  !axi_conv_fifo_empty_7)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_6 &  !axi_conv_fifo_empty_6)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_5 &  !axi_conv_fifo_empty_5)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_4 &  !axi_conv_fifo_empty_4)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_3 &  !axi_conv_fifo_empty_3)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_2 &  !axi_conv_fifo_empty_2)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_1 &  !axi_conv_fifo_empty_1)?1'b1:
                              (pstate ==PROCESS_WR_TRANSFER_ST_0 &  !axi_conv_fifo_empty_0)?1'b1:
1'b0;
assign bready=1'b1; 
endmodule