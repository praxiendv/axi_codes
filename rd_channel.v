module rd_channel(
input clk,
input reset_n,
input rvalid,
input [7:0] rid,
input [511:0] rdata,
input [1:0]resp,
input rlast, 
output ready,
output [511:0] ip_fifo_wrdata,
output ip_fifo_wr_0,
output axi_rd_err0,
output xfer_done_0,
output ip_fifo_wr_1,
output axi_rd_err1,
output xfer_done_1,
output ip_fifo_wr_2,
output axi_rd_err2,
output xfer_done_2,
output ip_fifo_wr_3,
output axi_rd_err3,
output xfer_done_3,
output fifo_rd_0,//to read axi converted fifo
input fifo_empty_0,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_0,
output fifo_rd_1,//to read axi converted fifo
input fifo_empty_1,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_1,
output fifo_rd_2,//to read axi converted fifo
input fifo_empty_2,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_2,
output fifo_rd_3,//to read axi converted fifo
input fifo_empty_3,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_3,
output fifo_rd_4,//to read axi converted fifo
input fifo_empty_4,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_4,
output fifo_rd_5,//to read axi converted fifo
input fifo_empty_5,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_5,
output fifo_rd_6,//to read axi converted fifo
input fifo_empty_6,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_6,
output fifo_rd_7,//to read axi converted fifo
input fifo_empty_7,//axi converter fifo status
input [96:0]axi_conv_fifo_rddata_7,
output id_mismatch_err,
output bytecount_mismatch//tbd
);
reg xfer_done_0_lat;
reg xfer_done_1_lat;
reg xfer_done_2_lat;
reg xfer_done_3_lat;

wire xfer_done;
reg [511:0] rdata_residue;
wire  [7:0] matched_fifo_empty_rid;
wire [4:0]fifo_rid;
wire valid;
wire[63:0] axi_addr;
reg[63:0] axi_addr_lat;
wire aligned_transfer;
reg[11:0] tot_bytes;
reg[11:0] tot_bytes_to_transfer;
reg[11:0] vld_bytes_in_prev_transfer;
wire[11:0] vld_bytes_in_this_transfer;
reg[11:0] vld_bytes_in_this_transfer_d;
reg[511:0] shifted_data;
wire [63:0]aligned_address;
wire [63:0] diff_addr_alignment;
reg rvalid_d;
wire pos_rvalid;
reg [3 :0] submaster_num_lat;
wire [3 :0] submaster_num;
reg [6:0] residue_count;
wire [7:0] tot_count_in_curr_transfer;
wire no_addr_alignment;
reg xfer_done_lat;
reg xfer_done_d;
reg residue_data_new_data_st_d;
reg[11:0]bytes_prev,prev_bytes;//TBD remove hardcode
reg[8:0] pstate,nstate;
parameter[8:0]
    TRANSFER_ST_0=2,
    TRANSFER_ST_1=3,
    TRANSFER_ST_2=4,
    TRANSFER_ST_3=5,
    TRANSFER_ST_4=6,
    TRANSFER_ST_5=7,
    TRANSFER_ST_6=8,
    TRANSFER_ST_7=9,
    ID_MISMATCH_ST=1,
    IDLE_ST=0;
reg[1:0]p_state,n_state;
parameter[1:0]
   IDLE_P_ST=0,
   PROCESS_NEW_DATA_ST=1,
   RESIDUE_DATA_NEW_DATA_ST=2,
   FIFO_WR_ST=3;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    pstate <= IDLE_ST;
  else
    pstate <= nstate;

always@(*)
begin
  nstate = IDLE_ST;
  case(pstate)
    IDLE_ST:
            if(rvalid)
              begin
               if(fifo_rid == 9)
                nstate = ID_MISMATCH_ST;
               else if(fifo_rid == 'd0)
                nstate = TRANSFER_ST_0;
               else if(fifo_rid == 'd1)
                nstate = TRANSFER_ST_1;
               else if(fifo_rid == 'd2)
                nstate = TRANSFER_ST_2;
               else if(fifo_rid == 'd3)
                nstate = TRANSFER_ST_3;
               else if(fifo_rid == 'd4)
                nstate = TRANSFER_ST_4;
               else if(fifo_rid == 'd5)
                nstate = TRANSFER_ST_5;
               else if(fifo_rid == 'd6)
                nstate = TRANSFER_ST_6;
               else if(fifo_rid == 'd7)
                nstate = TRANSFER_ST_7;
              end
            else
            nstate = IDLE_ST;
         TRANSFER_ST_0:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_0;

         TRANSFER_ST_1:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_1;

         TRANSFER_ST_2:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_2;

         TRANSFER_ST_3:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_3;

         TRANSFER_ST_4:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_4;

         TRANSFER_ST_5:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_5;

         TRANSFER_ST_6:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_6;

         TRANSFER_ST_7:
           if(tot_bytes_to_transfer <= 'd64)
             nstate = IDLE_ST;
           else
             nstate = TRANSFER_ST_7;


        
     ID_MISMATCH_ST:
          if(!rvalid)
            nstate = IDLE_ST;
          else
            nstate = ID_MISMATCH_ST;
  endcase
end

assign ready = p_state != IDLE_P_ST;
assign aligned_transfer=(|axi_addr_lat);
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    p_state <= IDLE_P_ST;
  else 
    p_state <= n_state;
always@(*)
begin
  n_state = IDLE_P_ST;
  case(p_state)
      IDLE_P_ST:
               if(pstate != IDLE_ST & pstate != ID_MISMATCH_ST)
                 begin
                   if(no_addr_alignment)
                     n_state = RESIDUE_DATA_NEW_DATA_ST;
                   else
                     n_state = PROCESS_NEW_DATA_ST;
                 end
               else
                 n_state = IDLE_P_ST;
      RESIDUE_DATA_NEW_DATA_ST://this will always have unaligned bytes
                 n_state = PROCESS_NEW_DATA_ST;
      PROCESS_NEW_DATA_ST://this will always have aligned data to write to IP
               if(rvalid & rlast)
                 n_state = IDLE_P_ST;
               else
                 n_state = PROCESS_NEW_DATA_ST;
endcase                 
end

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    axi_addr_lat <= 'd0;
  else if(pstate == IDLE_ST)
   begin
     if(matched_fifo_empty_rid == 'd0)
      axi_addr_lat <= axi_conv_fifo_rddata_0[63:0];
     else if(matched_fifo_empty_rid == 'd0)
      axi_addr_lat <= axi_conv_fifo_rddata_0[63:0];
     else if(matched_fifo_empty_rid == 'd1)
      axi_addr_lat <= axi_conv_fifo_rddata_1[63:0];
     else if(matched_fifo_empty_rid == 'd2)
      axi_addr_lat <= axi_conv_fifo_rddata_2[63:0];
     else if(matched_fifo_empty_rid == 'd3)
      axi_addr_lat <= axi_conv_fifo_rddata_3[63:0];
     else if(matched_fifo_empty_rid == 'd4)
      axi_addr_lat <= axi_conv_fifo_rddata_4[63:0];
     else if(matched_fifo_empty_rid == 'd5)
      axi_addr_lat <= axi_conv_fifo_rddata_5[63:0];
     else if(matched_fifo_empty_rid == 'd6)
      axi_addr_lat <= axi_conv_fifo_rddata_6[63:0];
     else if(matched_fifo_empty_rid == 'd7)
      axi_addr_lat <= axi_conv_fifo_rddata_7[63:0];
   end
  else if(rvalid & ready)//add condition for rlast
      axi_addr_lat <= 'd0;

/*
assign axi_addr=
                    (matched_fifo_empty_rid == 'd0)? axi_conv_fifo_rddata_0[63:0] : 

                    (matched_fifo_empty_rid == 'd1)? axi_conv_fifo_rddata_1[63:0] : 

                    (matched_fifo_empty_rid == 'd2)? axi_conv_fifo_rddata_2[63:0] : 

                    (matched_fifo_empty_rid == 'd3)? axi_conv_fifo_rddata_3[63:0] : 

                    (matched_fifo_empty_rid == 'd4)? axi_conv_fifo_rddata_4[63:0] : 

                    (matched_fifo_empty_rid == 'd5)? axi_conv_fifo_rddata_5[63:0] : 

                    (matched_fifo_empty_rid == 'd6)? axi_conv_fifo_rddata_6[63:0] : 

                    (matched_fifo_empty_rid == 'd7)? axi_conv_fifo_rddata_7[63:0] : 

'd0;
*/
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    tot_bytes <= 0;
  else if((matched_fifo_empty_rid == 'd0) )
    tot_bytes <= axi_conv_fifo_rddata_0[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd1) )
    tot_bytes <= axi_conv_fifo_rddata_1[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd2) )
    tot_bytes <= axi_conv_fifo_rddata_2[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd3) )
    tot_bytes <= axi_conv_fifo_rddata_3[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd4) )
    tot_bytes <= axi_conv_fifo_rddata_4[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd5) )
    tot_bytes <= axi_conv_fifo_rddata_5[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd6) )
    tot_bytes <= axi_conv_fifo_rddata_6[89 : 78 ];
  else if((matched_fifo_empty_rid == 'd7) )
    tot_bytes <= axi_conv_fifo_rddata_7[89 : 78 ];

always@(posedge clk or negedge reset_n)
  if(!reset_n)
   residue_data_new_data_st_d <= 'd0;
  else 
   residue_data_new_data_st_d <= p_state == RESIDUE_DATA_NEW_DATA_ST;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    tot_bytes_to_transfer <= 0;
  else if(p_state == IDLE_P_ST) 
    tot_bytes_to_transfer <= tot_bytes;
  else if( rvalid & ready)
   begin
    if(tot_bytes_to_transfer > 'd64)
       tot_bytes_to_transfer <= tot_bytes_to_transfer - vld_bytes_in_this_transfer;
    else
       tot_bytes_to_transfer <= 'd0;
   end
assign aligned_address = {axi_addr_lat[63:6],6'b0};
assign diff_addr_alignment = (axi_addr_lat - aligned_address);
assign vld_bytes_in_this_transfer = diff_addr_alignment == 0 ? 'd64 : ('d64-diff_addr_alignment);
assign no_addr_alignment=|axi_addr_lat[5:0];
always@(*)
begin
shifted_data=0;
case(vld_bytes_in_this_transfer)
    'd0:shifted_data=rdata >> 0 * 8;
    'd1:shifted_data=rdata >> 1 * 8;
    'd2:shifted_data=rdata >> 2 * 8;
    'd3:shifted_data=rdata >> 3 * 8;
    'd4:shifted_data=rdata >> 4 * 8;
    'd5:shifted_data=rdata >> 5 * 8;
    'd6:shifted_data=rdata >> 6 * 8;
    'd7:shifted_data=rdata >> 7 * 8;
    'd8:shifted_data=rdata >> 8 * 8;
    'd9:shifted_data=rdata >> 9 * 8;
    'd10:shifted_data=rdata >> 10 * 8;
    'd11:shifted_data=rdata >> 11 * 8;
    'd12:shifted_data=rdata >> 12 * 8;
    'd13:shifted_data=rdata >> 13 * 8;
    'd14:shifted_data=rdata >> 14 * 8;
    'd15:shifted_data=rdata >> 15 * 8;
    'd16:shifted_data=rdata >> 16 * 8;
    'd17:shifted_data=rdata >> 17 * 8;
    'd18:shifted_data=rdata >> 18 * 8;
    'd19:shifted_data=rdata >> 19 * 8;
    'd20:shifted_data=rdata >> 20 * 8;
    'd21:shifted_data=rdata >> 21 * 8;
    'd22:shifted_data=rdata >> 22 * 8;
    'd23:shifted_data=rdata >> 23 * 8;
    'd24:shifted_data=rdata >> 24 * 8;
    'd25:shifted_data=rdata >> 25 * 8;
    'd26:shifted_data=rdata >> 26 * 8;
    'd27:shifted_data=rdata >> 27 * 8;
    'd28:shifted_data=rdata >> 28 * 8;
    'd29:shifted_data=rdata >> 29 * 8;
    'd30:shifted_data=rdata >> 30 * 8;
    'd31:shifted_data=rdata >> 31 * 8;
    'd32:shifted_data=rdata >> 32 * 8;
    'd33:shifted_data=rdata >> 33 * 8;
    'd34:shifted_data=rdata >> 34 * 8;
    'd35:shifted_data=rdata >> 35 * 8;
    'd36:shifted_data=rdata >> 36 * 8;
    'd37:shifted_data=rdata >> 37 * 8;
    'd38:shifted_data=rdata >> 38 * 8;
    'd39:shifted_data=rdata >> 39 * 8;
    'd40:shifted_data=rdata >> 40 * 8;
    'd41:shifted_data=rdata >> 41 * 8;
    'd42:shifted_data=rdata >> 42 * 8;
    'd43:shifted_data=rdata >> 43 * 8;
    'd44:shifted_data=rdata >> 44 * 8;
    'd45:shifted_data=rdata >> 45 * 8;
    'd46:shifted_data=rdata >> 46 * 8;
    'd47:shifted_data=rdata >> 47 * 8;
    'd48:shifted_data=rdata >> 48 * 8;
    'd49:shifted_data=rdata >> 49 * 8;
    'd50:shifted_data=rdata >> 50 * 8;
    'd51:shifted_data=rdata >> 51 * 8;
    'd52:shifted_data=rdata >> 52 * 8;
    'd53:shifted_data=rdata >> 53 * 8;
    'd54:shifted_data=rdata >> 54 * 8;
    'd55:shifted_data=rdata >> 55 * 8;
    'd56:shifted_data=rdata >> 56 * 8;
    'd57:shifted_data=rdata >> 57 * 8;
    'd58:shifted_data=rdata >> 58 * 8;
    'd59:shifted_data=rdata >> 59 * 8;
    'd60:shifted_data=rdata >> 60 * 8;
    'd61:shifted_data=rdata >> 61 * 8;
    'd62:shifted_data=rdata >> 62 * 8;
    'd63:shifted_data=rdata >> 63 * 8;
endcase
end
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    vld_bytes_in_this_transfer_d <= 0;
  else
    vld_bytes_in_this_transfer_d <= vld_bytes_in_this_transfer;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    vld_bytes_in_prev_transfer <= 0;
  else
    vld_bytes_in_prev_transfer <= tot_bytes_to_transfer;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    residue_count <= 'd0;
  else if(xfer_done_d)
    residue_count <= 'd0;
  else if(rvalid & !ready & no_addr_alignment)
    residue_count <= vld_bytes_in_this_transfer;
    
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   xfer_done_d <= 'd0;
  else
   xfer_done_d <= xfer_done;

assign tot_count_in_curr_transfer = (residue_count + vld_bytes_in_this_transfer) & rvalid & ready;
always@(posedge clk or negedge reset_n)
     if(!reset_n)
       rdata_residue <= 'd0;
     else if(p_state==RESIDUE_DATA_NEW_DATA_ST | p_state == PROCESS_NEW_DATA_ST)
       begin
         if(residue_count[5:0] == 'd0)
            rdata_residue <= 'd0;
         else if(residue_count == 'd1)

            rdata_residue <= {504'd0,rdata[511:504] };
         else if(residue_count == 'd2)

            rdata_residue <= {496'd0,rdata[511:496] };
         else if(residue_count == 'd3)

            rdata_residue <= {488'd0,rdata[511:488] };
         else if(residue_count == 'd4)

            rdata_residue <= {480'd0,rdata[511:480] };
         else if(residue_count == 'd5)

            rdata_residue <= {472'd0,rdata[511:472] };
         else if(residue_count == 'd6)

            rdata_residue <= {464'd0,rdata[511:464] };
         else if(residue_count == 'd7)

            rdata_residue <= {456'd0,rdata[511:456] };
         else if(residue_count == 'd8)

            rdata_residue <= {448'd0,rdata[511:448] };
         else if(residue_count == 'd9)

            rdata_residue <= {440'd0,rdata[511:440] };
         else if(residue_count == 'd10)

            rdata_residue <= {432'd0,rdata[511:432] };
         else if(residue_count == 'd11)

            rdata_residue <= {424'd0,rdata[511:424] };
         else if(residue_count == 'd12)

            rdata_residue <= {416'd0,rdata[511:416] };
         else if(residue_count == 'd13)

            rdata_residue <= {408'd0,rdata[511:408] };
         else if(residue_count == 'd14)

            rdata_residue <= {400'd0,rdata[511:400] };
         else if(residue_count == 'd15)

            rdata_residue <= {392'd0,rdata[511:392] };
         else if(residue_count == 'd16)

            rdata_residue <= {384'd0,rdata[511:384] };
         else if(residue_count == 'd17)

            rdata_residue <= {376'd0,rdata[511:376] };
         else if(residue_count == 'd18)

            rdata_residue <= {368'd0,rdata[511:368] };
         else if(residue_count == 'd19)

            rdata_residue <= {360'd0,rdata[511:360] };
         else if(residue_count == 'd20)

            rdata_residue <= {352'd0,rdata[511:352] };
         else if(residue_count == 'd21)

            rdata_residue <= {344'd0,rdata[511:344] };
         else if(residue_count == 'd22)

            rdata_residue <= {336'd0,rdata[511:336] };
         else if(residue_count == 'd23)

            rdata_residue <= {328'd0,rdata[511:328] };
         else if(residue_count == 'd24)

            rdata_residue <= {320'd0,rdata[511:320] };
         else if(residue_count == 'd25)

            rdata_residue <= {312'd0,rdata[511:312] };
         else if(residue_count == 'd26)

            rdata_residue <= {304'd0,rdata[511:304] };
         else if(residue_count == 'd27)

            rdata_residue <= {296'd0,rdata[511:296] };
         else if(residue_count == 'd28)

            rdata_residue <= {288'd0,rdata[511:288] };
         else if(residue_count == 'd29)

            rdata_residue <= {280'd0,rdata[511:280] };
         else if(residue_count == 'd30)

            rdata_residue <= {272'd0,rdata[511:272] };
         else if(residue_count == 'd31)

            rdata_residue <= {264'd0,rdata[511:264] };
         else if(residue_count == 'd32)

            rdata_residue <= {256'd0,rdata[511:256] };
         else if(residue_count == 'd33)

            rdata_residue <= {248'd0,rdata[511:248] };
         else if(residue_count == 'd34)

            rdata_residue <= {240'd0,rdata[511:240] };
         else if(residue_count == 'd35)

            rdata_residue <= {232'd0,rdata[511:232] };
         else if(residue_count == 'd36)

            rdata_residue <= {224'd0,rdata[511:224] };
         else if(residue_count == 'd37)

            rdata_residue <= {216'd0,rdata[511:216] };
         else if(residue_count == 'd38)

            rdata_residue <= {208'd0,rdata[511:208] };
         else if(residue_count == 'd39)

            rdata_residue <= {200'd0,rdata[511:200] };
         else if(residue_count == 'd40)

            rdata_residue <= {192'd0,rdata[511:192] };
         else if(residue_count == 'd41)

            rdata_residue <= {184'd0,rdata[511:184] };
         else if(residue_count == 'd42)

            rdata_residue <= {176'd0,rdata[511:176] };
         else if(residue_count == 'd43)

            rdata_residue <= {168'd0,rdata[511:168] };
         else if(residue_count == 'd44)

            rdata_residue <= {160'd0,rdata[511:160] };
         else if(residue_count == 'd45)

            rdata_residue <= {152'd0,rdata[511:152] };
         else if(residue_count == 'd46)

            rdata_residue <= {144'd0,rdata[511:144] };
         else if(residue_count == 'd47)

            rdata_residue <= {136'd0,rdata[511:136] };
         else if(residue_count == 'd48)

            rdata_residue <= {128'd0,rdata[511:128] };
         else if(residue_count == 'd49)

            rdata_residue <= {120'd0,rdata[511:120] };
         else if(residue_count == 'd50)

            rdata_residue <= {112'd0,rdata[511:112] };
         else if(residue_count == 'd51)

            rdata_residue <= {104'd0,rdata[511:104] };
         else if(residue_count == 'd52)

            rdata_residue <= {96'd0,rdata[511:96] };
         else if(residue_count == 'd53)

            rdata_residue <= {88'd0,rdata[511:88] };
         else if(residue_count == 'd54)

            rdata_residue <= {80'd0,rdata[511:80] };
         else if(residue_count == 'd55)

            rdata_residue <= {72'd0,rdata[511:72] };
         else if(residue_count == 'd56)

            rdata_residue <= {64'd0,rdata[511:64] };
         else if(residue_count == 'd57)

            rdata_residue <= {56'd0,rdata[511:56] };
         else if(residue_count == 'd58)

            rdata_residue <= {48'd0,rdata[511:48] };
         else if(residue_count == 'd59)

            rdata_residue <= {40'd0,rdata[511:40] };
         else if(residue_count == 'd60)

            rdata_residue <= {32'd0,rdata[511:32] };
         else if(residue_count == 'd61)

            rdata_residue <= {24'd0,rdata[511:24] };
         else if(residue_count == 'd62)

            rdata_residue <= {16'd0,rdata[511:16] };
         else if(residue_count == 'd63)

            rdata_residue <= {8'd0,rdata[511:8] };
       end

/*
      else if( rvalid & ready & rlast)
       begin
         if(vld_bytes_in_this_transfer == 'd0)
            rdata_residue <= 'd0;
         else if(vld_bytes_in_this_transfer == 'd1)

            rdata_residue <= {504'd0,rdata[511:504] };
         else if(vld_bytes_in_this_transfer == 'd2)

            rdata_residue <= {496'd0,rdata[511:496] };
         else if(vld_bytes_in_this_transfer == 'd3)

            rdata_residue <= {488'd0,rdata[511:488] };
         else if(vld_bytes_in_this_transfer == 'd4)

            rdata_residue <= {480'd0,rdata[511:480] };
         else if(vld_bytes_in_this_transfer == 'd5)

            rdata_residue <= {472'd0,rdata[511:472] };
         else if(vld_bytes_in_this_transfer == 'd6)

            rdata_residue <= {464'd0,rdata[511:464] };
         else if(vld_bytes_in_this_transfer == 'd7)

            rdata_residue <= {456'd0,rdata[511:456] };
         else if(vld_bytes_in_this_transfer == 'd8)

            rdata_residue <= {448'd0,rdata[511:448] };
         else if(vld_bytes_in_this_transfer == 'd9)

            rdata_residue <= {440'd0,rdata[511:440] };
         else if(vld_bytes_in_this_transfer == 'd10)

            rdata_residue <= {432'd0,rdata[511:432] };
         else if(vld_bytes_in_this_transfer == 'd11)

            rdata_residue <= {424'd0,rdata[511:424] };
         else if(vld_bytes_in_this_transfer == 'd12)

            rdata_residue <= {416'd0,rdata[511:416] };
         else if(vld_bytes_in_this_transfer == 'd13)

            rdata_residue <= {408'd0,rdata[511:408] };
         else if(vld_bytes_in_this_transfer == 'd14)

            rdata_residue <= {400'd0,rdata[511:400] };
         else if(vld_bytes_in_this_transfer == 'd15)

            rdata_residue <= {392'd0,rdata[511:392] };
         else if(vld_bytes_in_this_transfer == 'd16)

            rdata_residue <= {384'd0,rdata[511:384] };
         else if(vld_bytes_in_this_transfer == 'd17)

            rdata_residue <= {376'd0,rdata[511:376] };
         else if(vld_bytes_in_this_transfer == 'd18)

            rdata_residue <= {368'd0,rdata[511:368] };
         else if(vld_bytes_in_this_transfer == 'd19)

            rdata_residue <= {360'd0,rdata[511:360] };
         else if(vld_bytes_in_this_transfer == 'd20)

            rdata_residue <= {352'd0,rdata[511:352] };
         else if(vld_bytes_in_this_transfer == 'd21)

            rdata_residue <= {344'd0,rdata[511:344] };
         else if(vld_bytes_in_this_transfer == 'd22)

            rdata_residue <= {336'd0,rdata[511:336] };
         else if(vld_bytes_in_this_transfer == 'd23)

            rdata_residue <= {328'd0,rdata[511:328] };
         else if(vld_bytes_in_this_transfer == 'd24)

            rdata_residue <= {320'd0,rdata[511:320] };
         else if(vld_bytes_in_this_transfer == 'd25)

            rdata_residue <= {312'd0,rdata[511:312] };
         else if(vld_bytes_in_this_transfer == 'd26)

            rdata_residue <= {304'd0,rdata[511:304] };
         else if(vld_bytes_in_this_transfer == 'd27)

            rdata_residue <= {296'd0,rdata[511:296] };
         else if(vld_bytes_in_this_transfer == 'd28)

            rdata_residue <= {288'd0,rdata[511:288] };
         else if(vld_bytes_in_this_transfer == 'd29)

            rdata_residue <= {280'd0,rdata[511:280] };
         else if(vld_bytes_in_this_transfer == 'd30)

            rdata_residue <= {272'd0,rdata[511:272] };
         else if(vld_bytes_in_this_transfer == 'd31)

            rdata_residue <= {264'd0,rdata[511:264] };
         else if(vld_bytes_in_this_transfer == 'd32)

            rdata_residue <= {256'd0,rdata[511:256] };
         else if(vld_bytes_in_this_transfer == 'd33)

            rdata_residue <= {248'd0,rdata[511:248] };
         else if(vld_bytes_in_this_transfer == 'd34)

            rdata_residue <= {240'd0,rdata[511:240] };
         else if(vld_bytes_in_this_transfer == 'd35)

            rdata_residue <= {232'd0,rdata[511:232] };
         else if(vld_bytes_in_this_transfer == 'd36)

            rdata_residue <= {224'd0,rdata[511:224] };
         else if(vld_bytes_in_this_transfer == 'd37)

            rdata_residue <= {216'd0,rdata[511:216] };
         else if(vld_bytes_in_this_transfer == 'd38)

            rdata_residue <= {208'd0,rdata[511:208] };
         else if(vld_bytes_in_this_transfer == 'd39)

            rdata_residue <= {200'd0,rdata[511:200] };
         else if(vld_bytes_in_this_transfer == 'd40)

            rdata_residue <= {192'd0,rdata[511:192] };
         else if(vld_bytes_in_this_transfer == 'd41)

            rdata_residue <= {184'd0,rdata[511:184] };
         else if(vld_bytes_in_this_transfer == 'd42)

            rdata_residue <= {176'd0,rdata[511:176] };
         else if(vld_bytes_in_this_transfer == 'd43)

            rdata_residue <= {168'd0,rdata[511:168] };
         else if(vld_bytes_in_this_transfer == 'd44)

            rdata_residue <= {160'd0,rdata[511:160] };
         else if(vld_bytes_in_this_transfer == 'd45)

            rdata_residue <= {152'd0,rdata[511:152] };
         else if(vld_bytes_in_this_transfer == 'd46)

            rdata_residue <= {144'd0,rdata[511:144] };
         else if(vld_bytes_in_this_transfer == 'd47)

            rdata_residue <= {136'd0,rdata[511:136] };
         else if(vld_bytes_in_this_transfer == 'd48)

            rdata_residue <= {128'd0,rdata[511:128] };
         else if(vld_bytes_in_this_transfer == 'd49)

            rdata_residue <= {120'd0,rdata[511:120] };
         else if(vld_bytes_in_this_transfer == 'd50)

            rdata_residue <= {112'd0,rdata[511:112] };
         else if(vld_bytes_in_this_transfer == 'd51)

            rdata_residue <= {104'd0,rdata[511:104] };
         else if(vld_bytes_in_this_transfer == 'd52)

            rdata_residue <= {96'd0,rdata[511:96] };
         else if(vld_bytes_in_this_transfer == 'd53)

            rdata_residue <= {88'd0,rdata[511:88] };
         else if(vld_bytes_in_this_transfer == 'd54)

            rdata_residue <= {80'd0,rdata[511:80] };
         else if(vld_bytes_in_this_transfer == 'd55)

            rdata_residue <= {72'd0,rdata[511:72] };
         else if(vld_bytes_in_this_transfer == 'd56)

            rdata_residue <= {64'd0,rdata[511:64] };
         else if(vld_bytes_in_this_transfer == 'd57)

            rdata_residue <= {56'd0,rdata[511:56] };
         else if(vld_bytes_in_this_transfer == 'd58)

            rdata_residue <= {48'd0,rdata[511:48] };
         else if(vld_bytes_in_this_transfer == 'd59)

            rdata_residue <= {40'd0,rdata[511:40] };
         else if(vld_bytes_in_this_transfer == 'd60)

            rdata_residue <= {32'd0,rdata[511:32] };
         else if(vld_bytes_in_this_transfer == 'd61)

            rdata_residue <= {24'd0,rdata[511:24] };
         else if(vld_bytes_in_this_transfer == 'd62)

            rdata_residue <= {16'd0,rdata[511:16] };
         else if(vld_bytes_in_this_transfer == 'd63)

            rdata_residue <= {8'd0,rdata[511:8] };
       end  
     else if( rvalid & ready)
       begin
         if(vld_bytes_in_this_transfer_d == 'd0)
            rdata_residue <= 'd0;
         else if(vld_bytes_in_this_transfer_d == 'd1)

            rdata_residue <= {504'd0,rdata[511:504] };
         else if(vld_bytes_in_this_transfer_d == 'd2)

            rdata_residue <= {496'd0,rdata[511:496] };
         else if(vld_bytes_in_this_transfer_d == 'd3)

            rdata_residue <= {488'd0,rdata[511:488] };
         else if(vld_bytes_in_this_transfer_d == 'd4)

            rdata_residue <= {480'd0,rdata[511:480] };
         else if(vld_bytes_in_this_transfer_d == 'd5)

            rdata_residue <= {472'd0,rdata[511:472] };
         else if(vld_bytes_in_this_transfer_d == 'd6)

            rdata_residue <= {464'd0,rdata[511:464] };
         else if(vld_bytes_in_this_transfer_d == 'd7)

            rdata_residue <= {456'd0,rdata[511:456] };
         else if(vld_bytes_in_this_transfer_d == 'd8)

            rdata_residue <= {448'd0,rdata[511:448] };
         else if(vld_bytes_in_this_transfer_d == 'd9)

            rdata_residue <= {440'd0,rdata[511:440] };
         else if(vld_bytes_in_this_transfer_d == 'd10)

            rdata_residue <= {432'd0,rdata[511:432] };
         else if(vld_bytes_in_this_transfer_d == 'd11)

            rdata_residue <= {424'd0,rdata[511:424] };
         else if(vld_bytes_in_this_transfer_d == 'd12)

            rdata_residue <= {416'd0,rdata[511:416] };
         else if(vld_bytes_in_this_transfer_d == 'd13)

            rdata_residue <= {408'd0,rdata[511:408] };
         else if(vld_bytes_in_this_transfer_d == 'd14)

            rdata_residue <= {400'd0,rdata[511:400] };
         else if(vld_bytes_in_this_transfer_d == 'd15)

            rdata_residue <= {392'd0,rdata[511:392] };
         else if(vld_bytes_in_this_transfer_d == 'd16)

            rdata_residue <= {384'd0,rdata[511:384] };
         else if(vld_bytes_in_this_transfer_d == 'd17)

            rdata_residue <= {376'd0,rdata[511:376] };
         else if(vld_bytes_in_this_transfer_d == 'd18)

            rdata_residue <= {368'd0,rdata[511:368] };
         else if(vld_bytes_in_this_transfer_d == 'd19)

            rdata_residue <= {360'd0,rdata[511:360] };
         else if(vld_bytes_in_this_transfer_d == 'd20)

            rdata_residue <= {352'd0,rdata[511:352] };
         else if(vld_bytes_in_this_transfer_d == 'd21)

            rdata_residue <= {344'd0,rdata[511:344] };
         else if(vld_bytes_in_this_transfer_d == 'd22)

            rdata_residue <= {336'd0,rdata[511:336] };
         else if(vld_bytes_in_this_transfer_d == 'd23)

            rdata_residue <= {328'd0,rdata[511:328] };
         else if(vld_bytes_in_this_transfer_d == 'd24)

            rdata_residue <= {320'd0,rdata[511:320] };
         else if(vld_bytes_in_this_transfer_d == 'd25)

            rdata_residue <= {312'd0,rdata[511:312] };
         else if(vld_bytes_in_this_transfer_d == 'd26)

            rdata_residue <= {304'd0,rdata[511:304] };
         else if(vld_bytes_in_this_transfer_d == 'd27)

            rdata_residue <= {296'd0,rdata[511:296] };
         else if(vld_bytes_in_this_transfer_d == 'd28)

            rdata_residue <= {288'd0,rdata[511:288] };
         else if(vld_bytes_in_this_transfer_d == 'd29)

            rdata_residue <= {280'd0,rdata[511:280] };
         else if(vld_bytes_in_this_transfer_d == 'd30)

            rdata_residue <= {272'd0,rdata[511:272] };
         else if(vld_bytes_in_this_transfer_d == 'd31)

            rdata_residue <= {264'd0,rdata[511:264] };
         else if(vld_bytes_in_this_transfer_d == 'd32)

            rdata_residue <= {256'd0,rdata[511:256] };
         else if(vld_bytes_in_this_transfer_d == 'd33)

            rdata_residue <= {248'd0,rdata[511:248] };
         else if(vld_bytes_in_this_transfer_d == 'd34)

            rdata_residue <= {240'd0,rdata[511:240] };
         else if(vld_bytes_in_this_transfer_d == 'd35)

            rdata_residue <= {232'd0,rdata[511:232] };
         else if(vld_bytes_in_this_transfer_d == 'd36)

            rdata_residue <= {224'd0,rdata[511:224] };
         else if(vld_bytes_in_this_transfer_d == 'd37)

            rdata_residue <= {216'd0,rdata[511:216] };
         else if(vld_bytes_in_this_transfer_d == 'd38)

            rdata_residue <= {208'd0,rdata[511:208] };
         else if(vld_bytes_in_this_transfer_d == 'd39)

            rdata_residue <= {200'd0,rdata[511:200] };
         else if(vld_bytes_in_this_transfer_d == 'd40)

            rdata_residue <= {192'd0,rdata[511:192] };
         else if(vld_bytes_in_this_transfer_d == 'd41)

            rdata_residue <= {184'd0,rdata[511:184] };
         else if(vld_bytes_in_this_transfer_d == 'd42)

            rdata_residue <= {176'd0,rdata[511:176] };
         else if(vld_bytes_in_this_transfer_d == 'd43)

            rdata_residue <= {168'd0,rdata[511:168] };
         else if(vld_bytes_in_this_transfer_d == 'd44)

            rdata_residue <= {160'd0,rdata[511:160] };
         else if(vld_bytes_in_this_transfer_d == 'd45)

            rdata_residue <= {152'd0,rdata[511:152] };
         else if(vld_bytes_in_this_transfer_d == 'd46)

            rdata_residue <= {144'd0,rdata[511:144] };
         else if(vld_bytes_in_this_transfer_d == 'd47)

            rdata_residue <= {136'd0,rdata[511:136] };
         else if(vld_bytes_in_this_transfer_d == 'd48)

            rdata_residue <= {128'd0,rdata[511:128] };
         else if(vld_bytes_in_this_transfer_d == 'd49)

            rdata_residue <= {120'd0,rdata[511:120] };
         else if(vld_bytes_in_this_transfer_d == 'd50)

            rdata_residue <= {112'd0,rdata[511:112] };
         else if(vld_bytes_in_this_transfer_d == 'd51)

            rdata_residue <= {104'd0,rdata[511:104] };
         else if(vld_bytes_in_this_transfer_d == 'd52)

            rdata_residue <= {96'd0,rdata[511:96] };
         else if(vld_bytes_in_this_transfer_d == 'd53)

            rdata_residue <= {88'd0,rdata[511:88] };
         else if(vld_bytes_in_this_transfer_d == 'd54)

            rdata_residue <= {80'd0,rdata[511:80] };
         else if(vld_bytes_in_this_transfer_d == 'd55)

            rdata_residue <= {72'd0,rdata[511:72] };
         else if(vld_bytes_in_this_transfer_d == 'd56)

            rdata_residue <= {64'd0,rdata[511:64] };
         else if(vld_bytes_in_this_transfer_d == 'd57)

            rdata_residue <= {56'd0,rdata[511:56] };
         else if(vld_bytes_in_this_transfer_d == 'd58)

            rdata_residue <= {48'd0,rdata[511:48] };
         else if(vld_bytes_in_this_transfer_d == 'd59)

            rdata_residue <= {40'd0,rdata[511:40] };
         else if(vld_bytes_in_this_transfer_d == 'd60)

            rdata_residue <= {32'd0,rdata[511:32] };
         else if(vld_bytes_in_this_transfer_d == 'd61)

            rdata_residue <= {24'd0,rdata[511:24] };
         else if(vld_bytes_in_this_transfer_d == 'd62)

            rdata_residue <= {16'd0,rdata[511:16] };
         else if(vld_bytes_in_this_transfer_d == 'd63)

            rdata_residue <= {8'd0,rdata[511:8] };
       end
*/
assign valid_transfer = tot_count_in_curr_transfer >= 'd64;


assign ip_fifo_wrdata = 
                     (residue_count[5:0] == 'd0)?rdata:

                     (residue_count == 1)?{rdata[503:0],rdata_residue[7:0]}:

                     (residue_count == 2)?{rdata[495:0],rdata_residue[15:0]}:

                     (residue_count == 3)?{rdata[487:0],rdata_residue[23:0]}:

                     (residue_count == 4)?{rdata[479:0],rdata_residue[31:0]}:

                     (residue_count == 5)?{rdata[471:0],rdata_residue[39:0]}:

                     (residue_count == 6)?{rdata[463:0],rdata_residue[47:0]}:

                     (residue_count == 7)?{rdata[455:0],rdata_residue[55:0]}:

                     (residue_count == 8)?{rdata[447:0],rdata_residue[63:0]}:

                     (residue_count == 9)?{rdata[439:0],rdata_residue[71:0]}:

                     (residue_count == 10)?{rdata[431:0],rdata_residue[79:0]}:

                     (residue_count == 11)?{rdata[423:0],rdata_residue[87:0]}:

                     (residue_count == 12)?{rdata[415:0],rdata_residue[95:0]}:

                     (residue_count == 13)?{rdata[407:0],rdata_residue[103:0]}:

                     (residue_count == 14)?{rdata[399:0],rdata_residue[111:0]}:

                     (residue_count == 15)?{rdata[391:0],rdata_residue[119:0]}:

                     (residue_count == 16)?{rdata[383:0],rdata_residue[127:0]}:

                     (residue_count == 17)?{rdata[375:0],rdata_residue[135:0]}:

                     (residue_count == 18)?{rdata[367:0],rdata_residue[143:0]}:

                     (residue_count == 19)?{rdata[359:0],rdata_residue[151:0]}:

                     (residue_count == 20)?{rdata[351:0],rdata_residue[159:0]}:

                     (residue_count == 21)?{rdata[343:0],rdata_residue[167:0]}:

                     (residue_count == 22)?{rdata[335:0],rdata_residue[175:0]}:

                     (residue_count == 23)?{rdata[327:0],rdata_residue[183:0]}:

                     (residue_count == 24)?{rdata[319:0],rdata_residue[191:0]}:

                     (residue_count == 25)?{rdata[311:0],rdata_residue[199:0]}:

                     (residue_count == 26)?{rdata[303:0],rdata_residue[207:0]}:

                     (residue_count == 27)?{rdata[295:0],rdata_residue[215:0]}:

                     (residue_count == 28)?{rdata[287:0],rdata_residue[223:0]}:

                     (residue_count == 29)?{rdata[279:0],rdata_residue[231:0]}:

                     (residue_count == 30)?{rdata[271:0],rdata_residue[239:0]}:

                     (residue_count == 31)?{rdata[263:0],rdata_residue[247:0]}:

                     (residue_count == 32)?{rdata[255:0],rdata_residue[255:0]}:

                     (residue_count == 33)?{rdata[247:0],rdata_residue[263:0]}:

                     (residue_count == 34)?{rdata[239:0],rdata_residue[271:0]}:

                     (residue_count == 35)?{rdata[231:0],rdata_residue[279:0]}:

                     (residue_count == 36)?{rdata[223:0],rdata_residue[287:0]}:

                     (residue_count == 37)?{rdata[215:0],rdata_residue[295:0]}:

                     (residue_count == 38)?{rdata[207:0],rdata_residue[303:0]}:

                     (residue_count == 39)?{rdata[199:0],rdata_residue[311:0]}:

                     (residue_count == 40)?{rdata[191:0],rdata_residue[319:0]}:

                     (residue_count == 41)?{rdata[183:0],rdata_residue[327:0]}:

                     (residue_count == 42)?{rdata[175:0],rdata_residue[335:0]}:

                     (residue_count == 43)?{rdata[167:0],rdata_residue[343:0]}:

                     (residue_count == 44)?{rdata[159:0],rdata_residue[351:0]}:

                     (residue_count == 45)?{rdata[151:0],rdata_residue[359:0]}:

                     (residue_count == 46)?{rdata[143:0],rdata_residue[367:0]}:

                     (residue_count == 47)?{rdata[135:0],rdata_residue[375:0]}:

                     (residue_count == 48)?{rdata[127:0],rdata_residue[383:0]}:

                     (residue_count == 49)?{rdata[119:0],rdata_residue[391:0]}:

                     (residue_count == 50)?{rdata[111:0],rdata_residue[399:0]}:

                     (residue_count == 51)?{rdata[103:0],rdata_residue[407:0]}:

                     (residue_count == 52)?{rdata[95:0],rdata_residue[415:0]}:

                     (residue_count == 53)?{rdata[87:0],rdata_residue[423:0]}:

                     (residue_count == 54)?{rdata[79:0],rdata_residue[431:0]}:

                     (residue_count == 55)?{rdata[71:0],rdata_residue[439:0]}:

                     (residue_count == 56)?{rdata[63:0],rdata_residue[447:0]}:

                     (residue_count == 57)?{rdata[55:0],rdata_residue[455:0]}:

                     (residue_count == 58)?{rdata[47:0],rdata_residue[463:0]}:

                     (residue_count == 59)?{rdata[39:0],rdata_residue[471:0]}:

                     (residue_count == 60)?{rdata[31:0],rdata_residue[479:0]}:

                     (residue_count == 61)?{rdata[23:0],rdata_residue[487:0]}:

                     (residue_count == 62)?{rdata[15:0],rdata_residue[495:0]}:

                     (residue_count == 63)?{rdata[7:0],rdata_residue[503:0]}:
                     0;
//(i=0;i<8;i++)
//assign ip_fifo_wr_ = (rid == 'd63)?valid_transfer:'d0;
// 

assign  ip_fifo_wr_0 = (p_state == PROCESS_NEW_DATA_ST & submaster_num == 'd0);
assign  ip_fifo_wr_1 = (p_state == PROCESS_NEW_DATA_ST & submaster_num == 'd1);
assign  ip_fifo_wr_2 = (p_state == PROCESS_NEW_DATA_ST & submaster_num == 'd2);
assign  ip_fifo_wr_3 = (p_state == PROCESS_NEW_DATA_ST & submaster_num == 'd3);
assign matched_fifo_empty_rid = 
                                (rid == 'd0 & !fifo_empty_0)?0:
                                (rid == 'd1 & !fifo_empty_1)?1:
                                (rid == 'd2 & !fifo_empty_2)?2:
                                (rid == 'd3 & !fifo_empty_3)?3:
                                (rid == 'd4 & !fifo_empty_4)?4:
                                (rid == 'd5 & !fifo_empty_5)?5:
                                (rid == 'd6 & !fifo_empty_6)?6:
                                (rid == 'd7 & !fifo_empty_7)?7:
                                1'b1;

assign fifo_rd_0 = (rvalid & rid==8'd0 & !fifo_empty_0 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_1 = (rvalid & rid==8'd1 & !fifo_empty_1 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_2 = (rvalid & rid==8'd2 & !fifo_empty_2 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_3 = (rvalid & rid==8'd3 & !fifo_empty_3 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_4 = (rvalid & rid==8'd4 & !fifo_empty_4 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_5 = (rvalid & rid==8'd5 & !fifo_empty_5 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_6 = (rvalid & rid==8'd6 & !fifo_empty_6 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rd_7 = (rvalid & rid==8'd7 & !fifo_empty_7 & p_state == PROCESS_NEW_DATA_ST & tot_bytes_to_transfer <= 'd64);

assign fifo_rid =  
                   (fifo_rd_0 == 0)?8'd0:
                   (fifo_rd_1 == 1)?8'd1:
                   (fifo_rd_2 == 2)?8'd2:
                   (fifo_rd_3 == 3)?8'd3:
                   (fifo_rd_4 == 4)?8'd4:
                   (fifo_rd_5 == 5)?8'd5:
                   (fifo_rd_6 == 6)?8'd6:
                   (fifo_rd_7 == 7)?8'd7:
                   'd17;//this is invalid value which indicates there is id_mismatch_err
assign id_mismatch_err = fifo_rid == 'd17;


always@(posedge clk or negedge reset_n)
  if(!reset_n)
    rvalid_d <= 0;
  else 
    rvalid_d <= rvalid & ready;
assign pos_rvalid = rvalid & !rvalid_d;
assign submaster_num = 0;//
//(i=0;i<8;i++)
//                    (matched_fifo_empty_rid == 'd7)? axi_conv_fifo_rddata_7[89 : 97] : 

//
//    submaster_num_lat;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    submaster_num_lat <= 0;
  else if(pstate == IDLE_ST)
    submaster_num_lat <= submaster_num;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    xfer_done_0_lat <= 0;
  else if(rvalid & rlast & ready & submaster_num == 'd0)
    xfer_done_0_lat <= 1;
  else 
    xfer_done_0_lat <= 0;

assign xfer_done_0=xfer_done_0_lat & fifo_empty_0;
assign axi_rd_err0 = resp != 'd0; 
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    xfer_done_1_lat <= 0;
  else if(rvalid & rlast & ready & submaster_num == 'd1)
    xfer_done_1_lat <= 1;
  else 
    xfer_done_1_lat <= 0;

assign xfer_done_1=xfer_done_1_lat & fifo_empty_1;
assign axi_rd_err1 = resp != 'd0; 
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    xfer_done_2_lat <= 0;
  else if(rvalid & rlast & ready & submaster_num == 'd2)
    xfer_done_2_lat <= 1;
  else 
    xfer_done_2_lat <= 0;

assign xfer_done_2=xfer_done_2_lat & fifo_empty_2;
assign axi_rd_err2 = resp != 'd0; 
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    xfer_done_3_lat <= 0;
  else if(rvalid & rlast & ready & submaster_num == 'd3)
    xfer_done_3_lat <= 1;
  else 
    xfer_done_3_lat <= 0;

assign xfer_done_3=xfer_done_3_lat & fifo_empty_3;
assign axi_rd_err3 = resp != 'd0; 
assign xfer_done= 
                   xfer_done_0 |
                   xfer_done_1 |
                   xfer_done_2 |
                   xfer_done_3 |
                   'd0; 
endmodule