module submaster_wr_arb(
input clk,
input start_0,
output grant_0,
input xfer_done0,
output processing_submaster_0,
input start_1,
output grant_1,
input xfer_done1,
output processing_submaster_1,
input start_2,
output grant_2,
input xfer_done2,
output processing_submaster_2,
input reset_n
);
reg[6:0] pstate ,nstate;
parameter[6:0] 
       PROCESS_START_0 = 0,
       PROCESS_START_1 = 1,
       PROCESS_START_2 = 2,
       WAIT_0_ST=3,
       WAIT_1_ST=4,
       WAIT_2_ST=5,
       IDLE_ST=6;
always@(posedge clk or negedge reset_n)
 if(!reset_n)
  pstate <= IDLE_ST;
 else
  pstate <= nstate;

assign processing_submaster_0 = pstate == PROCESS_START_0 | pstate == WAIT_0_ST;
assign processing_submaster_1 = pstate == PROCESS_START_1 | pstate == WAIT_1_ST;
assign processing_submaster_2 = pstate == PROCESS_START_2 | pstate == WAIT_2_ST;
always@(*)
begin
nstate = IDLE_ST;
case(pstate)
  IDLE_ST:
          if(start_0)
            nstate = PROCESS_START_0;
          else if(start_1)
            nstate = PROCESS_START_1;
          else if(start_2)
            nstate = PROCESS_START_2;
          else
            nstate = IDLE_ST;

  PROCESS_START_0:
          nstate = WAIT_0_ST;
  PROCESS_START_1:
          nstate = WAIT_1_ST;
  PROCESS_START_2:
          nstate = WAIT_2_ST;
  WAIT_0_ST:
          if(xfer_done0)
            nstate = IDLE_ST;
          else
            nstate = WAIT_0_ST;
  WAIT_1_ST:
          if(xfer_done1)
            nstate = IDLE_ST;
          else
            nstate = WAIT_1_ST;
  WAIT_2_ST:
          if(xfer_done2)
            nstate = IDLE_ST;
          else
            nstate = WAIT_2_ST;
endcase
end
assign grant_0 = pstate == PROCESS_START_0;
assign grant_1 = pstate == PROCESS_START_1;
assign grant_2 = pstate == PROCESS_START_2;
endmodule