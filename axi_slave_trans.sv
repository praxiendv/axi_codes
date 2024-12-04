class axi_slave_trans extends uvm_sequence_item;

 `uvm_object_utils(axi_slave_trans)

	//Write address channel signals
	 bit [3:0] AWID;
	 bit [31:0] AWADDR;
	 bit [3:0] AWLEN;
	 bit [2:0] AWSIZE;
	 bit [1:0] AWBURST;
	
	 bit [1:0] AWLOCK;
	 bit [3:0] AWCACHE;
	 bit [2:0] AWPROT;
	
	//Write data channel signals
  rand int len;
  
	 bit [3:0] WID;
  bit [31:0] WDATA[16];
  bit [3:0] WSTRB[16];
	
	//write response
	bit [3:0] BID;
	bit [1:0] BRESP;

	//Read address channel signals
	
	 bit [3:0] ARID;
	 bit [31:0] ARADDR;
	rand bit [3:0] ARLEN;
	 bit [2:0] ARSIZE;
	 bit [1:0] ARBURST;
	
	 bit [1:0] ARLOCK;
	 bit [3:0] ARCACHE;
	 bit [2:0] ARPROT;
	
	//Read data channel
	bit [3:0] RID;
	bit [1:0] RRESP;
  int RDATA[8]={4,5,8,7,9,1,3,2};
		  
//bit [1:0]	write_read_flag;
  
  
  //constraint wdata_size{WDATA.size==8;}
 //constraint wstrb_size{WSTRB.size==8;}
	
  
  //constraint rdata_size{RDATA.size==5;}
  
 // constraint rdata11{foreach(RDATA[i]){RDATA[i]==4;}}
  
  
	//siginals
	
	int start_address;
	int number_bytes;
	int aligned_address;
	int burst_length;
	int wrap_boundary;
	int address_1;
	int address_[];
	int wrap_limit;
 
        extern function new(string name = "axi_slave_trans");
        extern function void address_cal(uvm_object rhs);
		 extern function void do_print(uvm_printer printer);

endclass



function axi_slave_trans::new(string name = "axi_slave_trans");
        super.new(name);
endfunction:new
   
 
function void axi_slave_trans::address_cal (uvm_object rhs);

    axi_slave_trans rhs_;

    if(!$cast(rhs_,rhs))
                begin
                        `uvm_fatal("address_cal","cast of the rhs object failed")
                end
				


  address_=new[rhs_.AWLEN+1'b1];
  start_address=rhs_.AWADDR;
  number_bytes=2**(rhs_.AWSIZE);
  burst_length=(rhs_.AWLEN)+1'b1;
  aligned_address=(int'(start_address/number_bytes))*number_bytes;
  address_1=start_address;
    
	if(rhs_.AWBURST==2'b00)
			for(int i=0; i<burst_length; i++)
					address_[i]=start_address; 

	if(rhs_.AWBURST==2'b01)
				for(int i=0; i<burst_length; i++)
							address_[i] = aligned_address + (i * number_bytes);

	if(rhs_.AWBURST==2'b10)
		begin
			start_address=aligned_address;
			wrap_boundary=(int'(start_address/(number_bytes*burst_length))) * (number_bytes*burst_length);
			wrap_limit = wrap_boundary+(number_bytes*burst_length);
     
			for(int i=0; i<burst_length; i++)
				begin
						address_[i] = aligned_address + (i * number_bytes);
           
						if(address_[i]==wrap_boundary+(number_bytes*burst_length))
								begin
								address_[i]=wrap_boundary;
          
									for(int j=i+1; j<burst_length; j++)
										begin
											address_[j]=start_address+(j*number_bytes)-(number_bytes*burst_length);
										end
										break;
                                end
                end
		end

endfunction


function void  axi_slave_trans::do_print (uvm_printer printer);
        super.do_print(printer);


    //                  srting name          	bitstream value     size    radix for printing
    printer.print_field( "AWID",             this.AWID,              4,           UVM_HEX );
    printer.print_field( "AWADDR",       this.AWADDR,       32,          UVM_HEX);
    printer.print_field( "AWLEN",          this.AWLEN,           4,           UVM_HEX);
    printer.print_field( "AWSIZE",         this.AWSIZE,  	       3,           UVM_HEX);
    printer.print_field( "AWBURST",     this.AWBURST,      2,           UVM_HEX);

   	foreach(WDATA[i])
	begin
		printer.print_field($sformatf("WDATA[%0d]",i),this.WDATA[i],32,UVM_HEX);
	end
	
	foreach(WSTRB[i])
	begin
		printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_BIN);
	end
	
	
	printer.print_field( "WID",           	this.WID,                4,          UVM_HEX);

	
	printer.print_field( "ARID",             this.ARID,              4,           UVM_HEX);
    printer.print_field( "ARADDR",       this.ARADDR,       32,          UVM_HEX);
    printer.print_field( "ARLEN",          this.ARLEN,        	  4,          UVM_HEX);
    printer.print_field( "ARSIZE",        	this.ARSIZE,  		  3,          UVM_HEX);
    printer.print_field( "ARBURST",     this.ARBURST,       2,          UVM_HEX);
    	foreach(RDATA[i])
	begin
		printer.print_field($sformatf("RDATA[%0d]",i),this.RDATA[i],32,UVM_HEX);
	end

	

endfunction
           
           
           
           
           /*
           	foreach(WDATA[i])
	begin
		printer.print_field($sformatf("WDATA[%0d]",i),this.WDATA[i],32,UVM_HEX);
	end
	
	foreach(WSTRB[i])
	begin
		printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_BIN);
	end
    
    	foreach(RDATA[i])
	begin
		printer.print_field($sformatf("RDATA[%0d]",i),this.RDATA[i],32,UVM_HEX);
	end
           
           */