module mem_with_controller
#(
parameter DEPTH=8,
parameter ADDR_WIDTH=3,
parameter DATA_WIDTH=64 
)
(
input clk,
input reset_n,
input wr,
input rd,
input [DATA_WIDTH-1:0] datain,
output [DATA_WIDTH-1:0] dataout,
output  empty
);

integer i;
reg [ADDR_WIDTH-1:0] wraddr;
reg [ADDR_WIDTH-1:0] rdaddr;
reg [DATA_WIDTH-1:0] mem[DEPTH-1:0];
assign dataout = mem[rdaddr];
assign empty=(!reset_n)?1:(rdaddr == wraddr);
/*
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    empty <= 1'b1;
  else if(rdaddr != wraddr)
    empty <= 1'b0;
  else
    empty <= 1'b1;
*/
always@(posedge clk or negedge reset_n)
  if(!reset_n)
    rdaddr <= 0;
  else if(rd)
    rdaddr <= rdaddr +1;


always@(posedge clk or negedge reset_n)
  if(!reset_n)
    wraddr <= 0;
  else if(wr)
    wraddr <= wraddr +1;

always@(posedge clk or negedge reset_n)
  if(!reset_n)
    for(i=0;i<DEPTH;i=i+1)
        mem[i] <= 0;
  else if(wr)
        mem[wraddr] <= datain;
        
  
endmodule