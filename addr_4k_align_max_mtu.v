//this module takes input of the address and number of words to transfer and gives output of 4k aligned address and bytecount<MAX_MTU_WIDTH
module addr_4k_align_max_mtu(
input clk,
input reset_n,
input submaster_rd_grant_0,
input submaster_wr_grant_0,
input process_address_decoding,//this signal ..next decoding should start after acknowledgement...when no conversion is required, state should move immediately
output address_decoding_done,//assert this signal immediately if no conversion is required
input [63:0] addrin,
input [11:0] total_bytes,
// i= 64 + MAX_MTU_WIDTH
output ram4k_wr,
output [82:0] ram4k_wrdata//[63:0]addr,remaining will be bytes
);
wire address_decoding_required;
wire tot_byte_converted_counter_reached;
reg process_address_decoding_d;
wire tot_address_to_be_converted_reached;
reg[63:0] addr;
wire[63:0] addr1;
reg[63:0] addr_lat;
wire[63:0] addr2;
reg[63:0] addr2_d;
wire[63:0] base_addr;
wire[63:0] baseaddr_4k_aligned;
reg [11:0]remaining_bytes;
wire  [11:0]bytecount1;
reg  [11:0]bytecount2_d;
wire  [11:0]bytecount2;
reg  [11:0]bytecount_lat;
wire [11:0]aligned_4k_bytes_to_be_transferred;
reg ram4k_wr_d;
reg address_decoding_required_lat;
reg [9:0]tot_address_to_be_converted;
reg submaster_rd_grant_0_d;
reg submaster_wr_grant_0_d;
parameter [1:0] IDLE_ST=0,
                WR_PROCESS_ST=1;
reg [1:0] pstate,nstate;

always@(*)
begin
nstate=IDLE_ST;
  case(pstate)
     IDLE_ST:
             if(address_decoding_required)
                nstate = WR_PROCESS_ST;
             else
                nstate = IDLE_ST;
     WR_PROCESS_ST:
             if(tot_byte_converted_counter_reached)
               nstate = IDLE_ST;
             else
               nstate = WR_PROCESS_ST; 
      
endcase
end

always@(posedge clk or negedge reset_n)
  if(!reset_n)
   pstate <= IDLE_ST;
  else
   pstate <= nstate;
assign baseaddr_4k_aligned=base_addr+'h1000;
assign base_addr={addrin[63:12],12'b0};
assign addr1=addrin;
assign bytecount1=(baseaddr_4k_aligned > addrin & address_decoding_required)?(baseaddr_4k_aligned-addrin):total_bytes;
assign addr2=baseaddr_4k_aligned;
assign bytecount2=(total_bytes>bytecount1)?total_bytes-bytecount1:'d0;


assign address_decoding_required=(addrin+total_bytes)>(baseaddr_4k_aligned);

assign aligned_4k_bytes_to_be_transferred = 'd1024-addrin[11:0];
//assign total_bytes=total_bytes - aligned_4k_bytes_to_be_transferred;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    tot_address_to_be_converted <= 'd0;
  else if(address_decoding_required & pstate ==IDLE_ST)
     begin
       if(~(|aligned_4k_bytes_to_be_transferred))
          tot_address_to_be_converted <= total_bytes/1024 +1;
       else
          tot_address_to_be_converted <= total_bytes/1024 ;
     end
  else if(pstate == WR_PROCESS_ST)
     tot_address_to_be_converted <= tot_address_to_be_converted - 1'b1;



assign tot_byte_converted_counter_reached=~(|tot_address_to_be_converted);
assign address_decoding_done=(process_address_decoding_d & pstate == IDLE_ST ) | (tot_byte_converted_counter_reached & pstate == WR_PROCESS_ST);
assign ram4k_wr=(process_address_decoding_d | (ram4k_wr_d & address_decoding_required_lat)) ;//| pstate ==WR_PROCESS_ST; 
assign ram4k_wrdata=(pstate == IDLE_ST & address_decoding_required)?{
                                                                    submaster_rd_grant_0_d,
                                                                    submaster_wr_grant_0_d,
                                                                    bytecount_lat,addr_lat}:{
                                                                    submaster_rd_grant_0_d,
                                                                    submaster_wr_grant_0_d,
                                                                    bytecount_lat,addr_lat};
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    address_decoding_required_lat <= 'd0;
  else if(address_decoding_required)
    address_decoding_required_lat <= 'd1;
  else if(ram4k_wr_d)
    address_decoding_required_lat <= 'd0;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   ram4k_wr_d <= 'd0;
  else 
   ram4k_wr_d <=  ram4k_wr ;

assign start_trans=
                     submaster_wr_grant_0 |
                     submaster_rd_grant_0 | 
                     'd0;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   addr_lat <= 'd0;
  else if(start_trans) 
   addr_lat <= addr1;
  else
   addr_lat <= addr2_d;
    
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   bytecount_lat <= 'd0;
  else if(start_trans) 
   bytecount_lat <= bytecount1;
  else
   bytecount_lat <= bytecount2_d;
     
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    submaster_rd_grant_0_d <= 0;
  else
    submaster_rd_grant_0_d <= submaster_rd_grant_0;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    submaster_wr_grant_0_d <= 0;
  else
    submaster_wr_grant_0_d <= submaster_wr_grant_0;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    remaining_bytes <= 'd0;
  else if(pstate == IDLE_ST & address_decoding_required)
    remaining_bytes <= total_bytes - aligned_4k_bytes_to_be_transferred;
  else if(pstate == WR_PROCESS_ST)
    begin
      if(!tot_address_to_be_converted_reached)
        begin
          if(remaining_bytes > 10)
            remaining_bytes <= remaining_bytes - 10;
          else
            remaining_bytes <=  10;
        end
      else
        remaining_bytes <= 'd0;
    end
   else
    remaining_bytes <= total_bytes;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
   process_address_decoding_d <= 1'b0;
  else if(pstate == IDLE_ST & process_address_decoding)
   process_address_decoding_d <= 1'b1;
  else
   process_address_decoding_d <= 1'b0;


always@(posedge clk or negedge reset_n)
  if(!reset_n)
    addr <= 'd0;
  else
    addr <= addr1;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    bytecount2_d <= 'd0;
  else
    bytecount2_d <= bytecount2;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    addr2_d <= 'd0;
  else
    addr2_d <= addr2;

endmodule