class axi_master_trans1 extends uvm_sequence_item;

  `uvm_object_utils(axi_master_trans1)
  
  typedef enum {READ=1,WRITE=0,WRITE_READ=2}action;
	rand action action_h;


	//Write address channel signals
	rand bit [3:0] AWID;
	rand bit [31:0] AWADDR;
	rand bit [3:0] AWLEN;
	rand bit [2:0] AWSIZE;
	rand bit [1:0] AWBURST;
	
	rand bit [1:0] AWLOCK;
	rand bit [3:0] AWCACHE;
	rand bit [2:0] AWPROT;
	
	//Write data channel signals
	rand bit [3:0] WID;
	rand bit [31:0] WDATA[];
	rand bit [3:0] WSTRB[];
	
	//write response
	bit [3:0] BID;
	bit [1:0] BRESP;

	//Read address channel signals
	bit AWVALID;
	rand bit [3:0] ARID;
	rand bit [31:0] ARADDR;
	rand bit [3:0] ARLEN;
	rand bit [2:0] ARSIZE;
	rand bit [1:0] ARBURST;
	
	rand bit [1:0] ARLOCK;
	rand bit [3:0] ARCACHE;
	rand bit [2:0] ARPROT;
	
	//Read data channel
  		bit [31:0]RDATA[8];
  		bit [3:0]RID;
		bit [1:0]RRESP;
  		bit	RLAST; 
  
 

 
	
	//siginals
	
	//rand bit [1:0]	write_read_flag;


 // constraint read_flag_eee{write_read_flag==1;}// inside{[0:2]};}
 
 constraint AW_SIZE{AWSIZE inside {[0:2]}; AWADDR inside {[1:500]};}
  
  
  
 // constraint AW_SIZE{AWSIZE inside {2}; AWADDR==4;}
										
										
  constraint AR_SIZE{ARSIZE inside {[0:2]}; ARADDR inside {[1:500]};}
 
	constraint f{AWBURST!=2'b11; ARBURST!=2'b11;}
 // constraint f{AWBURST==2'b10; ARBURST==2'b10;}
 
	constraint len_same{AWLEN==ARLEN;}
	  
	constraint AW_LEN_VAL {
				solve AWBURST before AWLEN;
				
				if(AWBURST == 2'b00)
					AWLEN inside { 0, 1 };
				else if(AWBURST == 2'b10)
                  AWLEN inside {1, 3, 7, 15 };}
			
	constraint AR_LEN_VAL {
				solve ARBURST before ARLEN;
				
				if(ARBURST == 2'b00)
					ARLEN inside { 0, 1 };
      else if(ARBURST == 2'b10)
        ARLEN inside { 1, 3, 7, 15 };}
			
	constraint lD_SAME{AWID == WID;}
  
   constraint wdata_size{WDATA.size==AWLEN+1'b1;}
 constraint wstrb_size{WSTRB.size==AWLEN+1'b1;}
  
  //constraint rdata_size{RDATA.size==AWLEN+1'b1;} 
  
  
 // constraint rdata_data{foreach(RDATA[i])RDATA[i]==0;} 
		

  extern function new(string name = "axi_master_trans1");
        extern function void do_copy(uvm_object rhs);
        extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        extern function void do_print(uvm_printer printer);
        

endclass



          function axi_master_trans1::new(string name = "axi_master_trans1");
        super.new(name);
endfunction:new


function void axi_master_trans1::do_copy (uvm_object rhs);

    axi_master_trans rhs_;

    if(!$cast(rhs_,rhs))
                begin
                        `uvm_fatal("do_copy","cast of the rhs object failed")
                end
    super.do_copy(rhs);

	 
	 AWADDR=rhs_.AWADDR;
	 AWLEN=rhs_.AWLEN;
	 AWSIZE=rhs_.AWSIZE;
	 AWBURST=rhs_.AWBURST;
	 AWLOCK=rhs_.AWLOCK;
	 AWCACHE=rhs_.AWCACHE;
	 AWPROT=rhs_.AWPROT;

 	 WDATA=rhs_.WDATA;
	 WSTRB=rhs_.WSTRB;
	 
	ARID=rhs_.ARID;
	ARADDR=rhs_.ARADDR;
	ARLEN=rhs_.ARLEN;
	ARSIZE=rhs_.ARSIZE;
	ARBURST=rhs_.ARBURST;
	
	ARLOCK=rhs_.ARLOCK;
	ARCACHE=rhs_.ARCACHE;
	ARPROT=rhs_.ARPROT;

endfunction

function bit  axi_master_trans1::do_compare (uvm_object rhs,uvm_comparer comparer);


    axi_master_trans rhs_;

    if(!$cast(rhs_,rhs))
                begin
                        `uvm_fatal("do_compare","cast of the rhs object failed")
                        return 0;
                end

        return super.do_compare(rhs,comparer) &&
			AWADDR==rhs_.AWADDR &&
			AWLEN==rhs_.AWLEN &&
			AWSIZE==rhs_.AWSIZE &&
			WDATA==rhs_.WDATA &&
			ARID==rhs_.ARID  &&
			ARADDR==rhs_.ARADDR  &&
			ARLEN==rhs_.ARLEN  &&
			ARSIZE==rhs_.ARSIZE;
			
		
endfunction


function void  axi_master_trans1::do_print (uvm_printer printer);
        super.do_print(printer);


    //                  srting name          	bitstream value     size    radix for printing
    printer.print_field( "AWID",             this.AWID,              4,           UVM_HEX );
    printer.print_field( "AWADDR",       this.AWADDR,       32,          UVM_HEX);
    printer.print_field( "AWLEN",          this.AWLEN,           4,           UVM_HEX);
    printer.print_field( "AWSIZE",         this.AWSIZE,  	       3,           UVM_HEX);
    printer.print_field( "AWBURST",     this.AWBURST,      2,           UVM_HEX);
	printer.print_field( "WID",           	this.WID,                4,          UVM_HEX);

  	foreach(WDATA[i])
	begin
		printer.print_field($sformatf("WDATA[%0d]",i),this.WDATA[i],32,UVM_HEX);
	end
	
	foreach(WSTRB[i])
	begin
		printer.print_field($sformatf("WSTRB[%0d]",i),this.WSTRB[i],4,UVM_BIN);
	end
  
    printer.print_field( "BID",     this.BID,      2,     UVM_HEX);
 	 printer.print_field( "BRESP",  	this.BRESP,    4,      UVM_HEX);
  
    
  
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

	int start_address;
	int number_bytes;
	int aligned_address;
	int burst_length;
	int wrap_boundary;
	int address_1;
	int address_[];
	int wrap_limit;

function void axi_master_trans::post_randomize();


  address_=new[AWLEN+1'b1];
  start_address=AWADDR;
  number_bytes=2**AWSIZE;
  burst_length=AWLEN+1'b1;
  aligned_address=(int'(start_address/number_bytes))*number_bytes;
  address_1=start_address;
    
	if(AWBURST==2'b00)
			for(int i=0; i<burst_length; i++)
					address_[i]=start_address; 

	if(AWBURST==2'b01)
				for(int i=0; i<burst_length; i++)
							address_[i] = aligned_address + (i * number_bytes);

	if(AWBURST==2'b10)
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

endfunction : post_randomize





	    constraint AW_AWADDR_range {
      
					solve b_type before AWADDR;
					solve AWSIZE before AWADDR;
       
					if(AWBURST == 2'b10)
					AWADDR == int'(AWADDR/2**AWSIZE) * 2**AWSIZE;}

			constraint AW_AWADDR_align {
       
					solve AWSIZE before AWADDR;

					AWADDR == int'(AWADDR/2**AWSIZE) * 2**AWSIZE;}

			constraint AW_AWADDR_unalign {
		
					solve AWSIZE before AWADDR;

					AWADDR != int'(AWADDR/2**AWSIZE) * 2**AWSIZE; }

					//Read address constraint
				
		    constraint AR_ARADDR_range {
      
					solve b_type before ARADDR;
					solve ARSIZE before ARADDR;
       
					if(ARBURST == 2'b01)
					ARADDR == int'(ARADDR/2**ARSIZE) * 2**ARSIZE;}

			constraint AR_ARADDR_align {
       
					solve ARSIZE before ARADDR;

					ARADDR == int'(ARADDR/2**ARSIZE) * 2**ARSIZE;}

			constraint AR_ARADDR_unalign {
		
					solve ARSIZE before ARADDR;

					ARADDR != int'(ARADDR/2**ARSIZE) * 2**ARSIZE; }		
*/