antecedent has to be sequence, consequent can be a sequence or property
we should not use "not" with implication operators as it might give false results.
not(a |-> b) == a && !b, a |-> !b == !(a && b)

b[*3] ##1 c--- consecutively
b[=3] ##1 c --- non-consecutive (no restriction on number of cycles between b and c
b[->3] ##1 c --- non-consecutive (last occurence of b must be followed by c)

a ##1 b[=2:5] ##1 c; // After a is high, after 1 clk cycle simulator will start checking for b to be high "for" 2/3/4/5 clk cycles

a -> b[*1:3] ##1 C; //If b is high == a -> ##[1:3]c, after  a is high, if b is high in the same clk cycle, c will be high after 1 clk cycle. If b is high for 2 clk cycles, c will be high after 2 clk cycle...

a ##[2:5]b; 

B ##1 C[*1:4] //Repetition operator "FOR"

B ##[1:4] C //Timing window "AFTER"

[*n] //consecutive
[=n] //non-consecutive
[->n] //non-consecutive, c must follow b

//Immediate assertions
always @(posedge clk)

begin: Fifo_counter
	PuspPopTest: 
	
	if(push && !pop)
	begin
		a_fifomax: assert(fifo_count < MAXCOUNT)
					else
						$display("");
		
	fifo_count <= fifo_count + 1;
	end
	
	else if(!push && pop)
	begin
		a_fifomin: assert(fifo_count > 0)
					else
						$display("");
	
	fifo_count <= fifo_count -1;
	end
end

Assertions can be specified in always/initial/program block/interface/module

assert - checker to ensure that the property holds for the design

assume - to specify property as an assumption for the environment

cover - to monitor property evaluation for coverage

//example
property p_handshake;
	@(posedge clk) disable iff(!reset)
	req |=> ##[0:4]ack ##1 bus_enable[*1:10] ##1 !ack ##1 hold[*2];
	//bus_enable is repeated from 1 to 10 times until !ack is TRUE
endproperty


//example
sequence qReq;
	@(posedge clk) bus_req ##1 `true;
endsequence

bus_ack |-> qReq.ended;
//if bus_ack is TRUE, then the endpoint of bus_req followed by a dont care cycle occured in the same cycle as bus_ack

//Sequence operators

concatenation - seq1 ##1 seq2 
//seq2 begins on the clk after seq1 completes

overlap - seq1 ##0 seq2
//seq2 begins on the same clk on which seq1 completes

Ended detection - seq1 ##1 seq2.ended
//seq2 completes on the clk after seq1 completes, regardless of when seq2 started

Repetition - seq1[*n:m]
//resuts in multiple matching sequences

first_match (seq1)
//if seq1 has multiple matches, use the first match and ignore the rest

seq1 or seq2

seq1 and seq2

seq1 intersect seq2

cond throughout seq 
//cond is TRUE for every cycle of seq

seq1 within seq2
//seq1 starts on or after seq 2 & ends on or before the end of seq2

//example
sequence qAbort;
	@(posedge clk) reset or (illegal_xtn ##1 cancle);
endsequence
 //at any clk cycle either a reset or illegal_xtn followed by a cancle must occured
 
 //example
parameter LENGTH = 8;
sequence qData(ack, enb, done);
	ack ##1 enb[*LENGTH] ##1;
endsequence
//ack followed by 8 occurences of enb followed by done

//Local variables within a sequence enable information to be stored within the thread of a sequence & then tested at a later cycle

sequence qMemData (ready, done, mem_bus, x_bus);
	int v_data;
	(ready, v_data = mem_bus) ##[5:10] (done && x_bus == v_data);
endsequence
//if ready is true, then v_data gets assigned to mem_bus. Within 5-10 cycles later, when done is TRUE then x_bus should be equal to contents of v_data. Seq fails if ready is FALSE or "done && x_bus == v_data" fails to be TRUE within the range of 5-10 cycles after ready.

//formal arguments and usage
parameter WIDTH = 32;
property aASSERT (test, enable = 1'b1);
	enable && (test != {WIDTH{1'b1}}) |->
	(~test == {WIDTH{1'b0}}) || (~test & ...
	
endproperty 

aASSERT_ONE: assert property aASSERT(.test(a_bus), .enable(enb))
//named notation, no default

aASSERT_ONE: assert property aASSERT(.test(a_bus));
//named notation with default

aASSERT_ONE: assert property aASSERT(a_bus, enb);
//positional notation, no default

aASSERT_ONE: assert property aASSERT(b_bus);
//positional notation, with default

//example
property p_req2send;
	logic [15:0] v_data;
	@(posedge clk) ($rose(req_data), v_data = data) |=> ##[0:3] (ready && d == v_data, v_data = data) |=> ##[0:5] done && q == v_data;
	
	//if a new req_data, store data into local variable v_data, then read should occur after 1/2/3 cycles, at which time register d should be equal to the stored data i.e. v_data. In the last cycle, local variable v_data stores a new value of signal data. Thereafter, from the next cycle, up to 5 cycles later done should be active and register q should be equal to the newly captured data stored in variable v_data
	
endproperty

($rose(a), v = b) |=> ##[0:v]c; //illegal use of variable in range




