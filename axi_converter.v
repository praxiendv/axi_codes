//given address , this module will create AXI transfer size,length,address out,axi id to be written to ram
module axi_converter(
input clk,
input reset_n,
input fifo_empty,//this is 4K address fifo empty signal which has 4K aligned address and bytecounts
input [82:0]ram4k_rddata,

output ram_4k_rd,
output ram_axi_conv_wr,
output [96:0]ram_wrdata//bytecount,axi_asize,axi_alen,axi_id,axi_addr_out
);
wire [2:0] axi_asize;
reg [2:0] axi_len;
wire[7:0] axi_id;
wire remaining_byte_count_reached;
wire[63:0] addr;
parameter [9:0] MAXBYTES = 1024;
reg[2:0] alen;
reg[2:0] asize;
reg [11:0]bytes_transferred;//remove hardcoding..TBD
reg [11:0]bytes_to_be_transferred;//remove hardcoding..TBD

wire [11:0]bytecount;
reg[4:0] pstate,nstate;
parameter[4:0] 
               PROCESS_ST_0=0,
               PROCESS_ST_1=1,
               PROCESS_ST_2=2,
               PROCESS_ST_3=3,
               PROCESS_ST_4=4,
               PROCESS_ST_5=5,
               PROCESS_ST_6=6,
               PROCESS_ST_7=7,
               PROCESS_ST_8=8,
               PROCESS_ST_9=9,
               PROCESS_ST_10=10,
               PROCESS_ST_11=11,
               PROCESS_ST_12=12,
               PROCESS_ST_13=13,
               PROCESS_ST_14=14,
               PROCESS_ST_15=15,
               IDLE_ST=16;

//16 process states are added, since maximum AXI IDs are 16
always@(*)
begin
  nstate  = IDLE_ST;
  case(pstate)
  IDLE_ST:
     if(!fifo_empty)
       nstate = PROCESS_ST_0;
     else
       nstate = IDLE_ST;
  PROCESS_ST_0:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_0;
      else
       nstate = IDLE_ST;
  PROCESS_ST_1:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_1;
      else
       nstate = IDLE_ST;
  PROCESS_ST_2:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_2;
      else
       nstate = IDLE_ST;
  PROCESS_ST_3:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_3;
      else
       nstate = IDLE_ST;
  PROCESS_ST_4:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_4;
      else
       nstate = IDLE_ST;
  PROCESS_ST_5:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_5;
      else
       nstate = IDLE_ST;
  PROCESS_ST_6:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_6;
      else
       nstate = IDLE_ST;
  PROCESS_ST_7:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_7;
      else
       nstate = IDLE_ST;
  PROCESS_ST_8:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_8;
      else
       nstate = IDLE_ST;
  PROCESS_ST_9:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_9;
      else
       nstate = IDLE_ST;
  PROCESS_ST_10:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_10;
      else
       nstate = IDLE_ST;
  PROCESS_ST_11:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_11;
      else
       nstate = IDLE_ST;
  PROCESS_ST_12:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_12;
      else
       nstate = IDLE_ST;
  PROCESS_ST_13:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_13;
      else
       nstate = IDLE_ST;
  PROCESS_ST_14:
      if(!remaining_byte_count_reached)
       nstate = PROCESS_ST_14;
      else
       nstate = IDLE_ST;
  PROCESS_ST_15:
       nstate = IDLE_ST;
endcase
end
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    pstate <= IDLE_ST;
  else
    pstate <= nstate;
assign addr=ram4k_rddata[63:0];
assign remaining_byte_count_reached=1;
assign ram_axi_conv_wr=pstate == PROCESS_ST_0;
assign ram_4k_rd=ram_axi_conv_wr;
assign ram_wrdata={bytecount,axi_asize,axi_len,axi_id,addr};
assign axi_id=0;

assign bytecount=ram4k_rddata[82:64];
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    axi_len <= 0;
  else
    begin
      if(bytecount > 64) 
        axi_len <= (bytecount >> 6) -1;//64 is due to 512bit datawidth
      else
        axi_len <= 0;
    end
assign axi_asize=6;
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   begin
    bytes_to_be_transferred <= 'd0;
   end
  else if(!fifo_empty & pstate == IDLE_ST)
   begin
    bytes_to_be_transferred <= ram4k_rddata[82:64];//TBD
   end
  else if(pstate != IDLE_ST)
   begin
    bytes_to_be_transferred <= bytes_transferred;
   end
always@(posedge clk or negedge reset_n)
  if(!reset_n)
   begin
    bytes_transferred <= 'd0;
    alen <= 'd0;
    asize <= 'd0;
   end
  else if(pstate != IDLE_ST)
   begin
	if(bytes_to_be_transferred >= MAXBYTES)
		begin
			if(addr[4:0] == 'd0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,0);	
			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,MAXBYTES,127);
			end
                        	
					
   end
	else if(bytes_to_be_transferred >= 64 & MAXBYTES == 128 & bytes_to_be_transferred < 128)
	begin
			if(addr[4:0] == 0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,0);	
			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,64,127);
			end
end
	else if(bytes_to_be_transferred >= 32 & MAXBYTES == 64 & bytes_to_be_transferred < 64)
	begin
			if(addr[4:0] == 0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,0);
		
			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,32,127);
			end
end
	else if(bytes_to_be_transferred >= 16 & MAXBYTES == 32 & bytes_to_be_transferred < 32)
	begin
			if(addr[4:0] == 0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,0);

			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,16,127);
			end
end
	else if(bytes_to_be_transferred >= 8 & MAXBYTES == 16 & bytes_to_be_transferred < 16)
	begin
			if(addr[4:0] == 0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,0);
	
			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,8,127);
			end
 end
	else if(bytes_to_be_transferred >= 4 & MAXBYTES == 8 & bytes_to_be_transferred < 8)
	begin
			if(addr[4:0] == 0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,0);
	
			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,4,127);
			end
 end
	else if(bytes_to_be_transferred >= 2 & MAXBYTES == 4 & bytes_to_be_transferred <4)
begin
			if(addr[4:0] == 0)
			begin	
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,0);
	
			end
			else if(addr[4:0] == 1)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,1);
			end		
			else if(addr[4:0] == 2)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,2);
			end	
			else if(addr[4:0] == 3)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,3);
			end	
			else if(addr[4:0] == 4)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,4);
			end
			else if(addr[4:0] == 5)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,5);
			end
			else if(addr[4:0] == 6)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,6);
			end
			else if(addr[4:0] == 7)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,7);
			end
			else if(addr[4:0] == 8)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,8);
			end
			else if(addr[4:0] == 9)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,9);
			end
			else if(addr[4:0] == 10)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,10);
			end
			else if(addr[4:0] == 11)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,11);
			end
			else if(addr[4:0] == 12)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,12);
			end
			else if(addr[4:0] == 13)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,13);
			end
			else if(addr[4:0] == 14)
			begin		
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,14);
			end
			else if(addr[4:0] == 15)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,15);
			end
			else if(addr[4:0] == 16)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,16);
			end
			else if(addr[4:0] == 17)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,17);
			end
			else if(addr[4:0] == 18)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,18);
			end
			else if(addr[4:0] == 19)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,19);
			end
			else if(addr[4:0] == 20)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,20);
			end	
			else if(addr[4:0] == 21)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,21);
			end	
			else if(addr[4:0] == 22)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,22);
			end	
			else if(addr[4:0] == 23)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,23);
			end	
			else if(addr[4:0] == 24)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,24);
			end												
			else if(addr[4:0] == 25)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,25);
			end	
			else if(addr[4:0] == 26)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,26);
			end				
			else if(addr[4:0] == 27)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,27);
			end	
			else if(addr[4:0] == 28)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,28);
			end	
			else if(addr[4:0] == 29)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,29);
			end	
			else if(addr[4:0] == 30)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,30);
			end	
			else if(addr[4:0] == 31)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,31);
			end	
			else if(addr[4:0] == 32)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,32);
			end	
			else if(addr[4:0] == 33)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,33);
			end			
			else if(addr[4:0] == 34)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,34);
			end	
			else if(addr[4:0] == 35)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,35);
			end	
			else if(addr[4:0] == 36)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,36);
			end	
			else if(addr[4:0] == 37)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,37);
			end	
			else if(addr[4:0] == 38)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,38);
			end	
			else if(addr[4:0] == 39)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,39);
			end	
			else if(addr[4:0] == 40)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,40);
			end	
			else if(addr[4:0] == 41)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,41);
			end	
			else if(addr[4:0] == 42)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,42);
			end	
			else if(addr[4:0] == 43)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,43);
			end	
			else if(addr[4:0] == 44)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,44);
			end	
			else if(addr[4:0] == 45)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,45);
			end	
			else if(addr[4:0] == 46)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,46);
			end	
			else if(addr[4:0] == 47)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,47);
			end	
			else if(addr[4:0] == 48)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,48);
			end	
			else if(addr[4:0] == 49)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,49);
			end	
			else if(addr[4:0] == 50)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,50);
			end	
			else if(addr[4:0] == 51)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,51);
			end	
			else if(addr[4:0] == 52)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,52);
			end	
			else if(addr[4:0] == 53)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,53);
			end	
			else if(addr[4:0] == 54)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,54);
			end	
			else if(addr[4:0] == 55)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,55);
			end	
			else if(addr[4:0] == 56)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,56);
			end	
			else if(addr[4:0] == 57)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,57);
			end	
			else if(addr[4:0] == 58)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,58);
			end	
			else if(addr[4:0] == 59)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,59);
			end	
			else if(addr[4:0] == 60)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,60);
			end	
			else if(addr[4:0] == 61)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,61);
			end	
			else if(addr[4:0] == 62)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,62);
			end	
			else if(addr[4:0] == 63)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,63);
			end	
			else if(addr[4:0] == 64)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,64);
			end	
			else if(addr[4:0] == 65)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,65);
			end	
			else if(addr[4:0] == 66)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,66);
			end	
			else if(addr[4:0] == 67)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,67);
			end	
			else if(addr[4:0] == 68)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,68);
			end	
			else if(addr[4:0] == 69)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,69);
			end	
			else if(addr[4:0] == 70)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,70);
			end	
			else if(addr[4:0] == 71)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,71);
			end	
			else if(addr[4:0] == 72)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,72);
			end	
			else if(addr[4:0] == 73)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,73);
			end	
			else if(addr[4:0] == 74)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,74);
			end	
			else if(addr[4:0] == 75)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,75);
			end	
			else if(addr[4:0] == 76)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,76);
			end	
			else if(addr[4:0] == 77)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,77);
			end	
			else if(addr[4:0] == 78)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,78);
			end	
			else if(addr[4:0] == 79)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,79);
			end	
			else if(addr[4:0] == 80)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,80);
			end	
			else if(addr[4:0] == 81)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,81);
			end	
			else if(addr[4:0] == 82)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,82);
			end	
			else if(addr[4:0] == 83)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,83);
			end	
			else if(addr[4:0] == 84)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,84);
			end	
			else if(addr[4:0] == 85)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,85);
			end	
			else if(addr[4:0] == 86)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,86);
			end	
			else if(addr[4:0] == 87)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,87);
			end	
			else if(addr[4:0] == 88)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,88);
			end	
			else if(addr[4:0] == 89)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,89);
			end	
			else if(addr[4:0] == 90)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,90);
			end	
			else if(addr[4:0] == 91)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,91);
			end	
			else if(addr[4:0] == 92)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,92);
			end	
			else if(addr[4:0] == 93)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,93);
			end		
			else if(addr[4:0] == 94)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,94);
			end	
			else if(addr[4:0] == 95)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,95);
			end	
			else if(addr[4:0] == 96)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,96);
			end	
			else if(addr[4:0] == 97)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,97);
			end	
			else if(addr[4:0] == 98)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,98);
			end	
			else if(addr[4:0] == 99)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,99);
			end	
			else if(addr[4:0] == 100)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,100);
			end	
			else if(addr[4:0] == 101)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,101);
			end	
			else if(addr[4:0] == 102)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,102);
			end	
			else if(addr[4:0] == 103)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,103);
			end	
			else if(addr[4:0] == 104)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,104);
			end	
			else if(addr[4:0] == 105)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,105);
			end	
			else if(addr[4:0] == 106)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,106);
			end	
			else if(addr[4:0] == 107)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,107);
			end	
			else if(addr[4:0] == 108)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,108);
			end	
			else if(addr[4:0] == 109)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,109);
			end	
			else if(addr[4:0] == 110)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,110);
			end	
			else if(addr[4:0] == 111)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,111);
			end	
			else if(addr[4:0] == 112)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,112);
			end	
			else if(addr[4:0] == 113)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,113);
			end	
			else if(addr[4:0] == 114)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,114);
			end	
			else if(addr[4:0] == 115)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,115);
			end	
			else if(addr[4:0] == 116)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,116);
			end	
			else if(addr[4:0] == 117)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,117);
			end	
			else if(addr[4:0] == 118)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,118);
			end	
			else if(addr[4:0] == 119)
			begin			
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,119);
			end	
			else if(addr[4:0] == 120)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,120);
			end	
			else if(addr[4:0] == 121)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,121);
			end	
			else if(addr[4:0] == 122)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,122);
			end	
			else if(addr[4:0] == 123)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,123);
			end		
			else if(addr[4:0] == 124)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,124);
			end	
			else if(addr[4:0] == 125)
			begin
				
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,125);
			end		
			else if(addr[4:0] == 126)
			begin
			
				{alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,126);
			end	
			else if(addr[4:0] == 127)
			begin

                                {alen,asize,bytes_transferred}<=calc_alen_asize_bytestransferred(bytes_to_be_transferred,2,127);
			end
end	
end	

assign unaligned_address = addr[5:0] % 64 > 'd0;


function calc_alen_asize_bytestransferred;
input [11:0] bytes_to_be_transferred;
input [11:0] maxbytes;
input [11:0] bytecount;
begin 
/*wire[2:0] asize;
case(maxbytes)
  'd1:asize='d0;
  'd2:asize='d1;
  'd4:asize='d2;
  'd8:asize='d3;
  'd16:asize='d4;
  'd32:asize='d5;
  'd64:asize='d6;
  'd128:asize='d7;
endcase
*/
//calc_alen_asize_bytestransferred={(bytes_to_be_transferred / maxbytes),asize, ((alen * maxbytes) - bytecount)};
//calc_alen_asize_bytestransferred={(bytes_to_be_transferred / maxbytes), ((alen * maxbytes) - bytecount)};
end
endfunction
endmodule