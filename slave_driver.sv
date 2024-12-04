class axi_slave_driver extends uvm_driver #(axi_slave_trans);

`uvm_component_utils(axi_slave_driver)

virtual axi_interface.SL_DRV axi_s_drv_vif;

axi_slave_agent_config axi_s_agnt_cfg;

//axi_slave_trans axi_s_xtn_h;
  
   bit [31:0]wr_rd_mem[4095:0];
  
  	int start_address;
	int number_bytes;
	int aligned_address;
	int burst_length;
	int wrap_boundary;
	int address_1;
	int address_[];
	int wrap_limit;
    int i;
  
  int AWLEN,ARLEN,AWADDR,ARADDR,ARID,ARID1,AWSIZE,ARSIZE,AWBURST,ARBURST,AWID,AWID1;


extern function new(string name="axi_slave_driver", uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void end_of_elaboration_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
  
extern task siginal_initilization(); 
extern task get_data_port(); 
  
extern task Next_addr_cal(int ADDR,int LEN,int SIZE,int BURST); 
  
  
extern task send_to_dut_write(axi_slave_trans axi_s_xtn_h);
extern task send_to_dut_read(axi_slave_trans axi_s_xtn_h);
    
  
extern function void report_phase(uvm_phase phase);
endclass

function axi_slave_driver ::new(string name="axi_slave_driver", uvm_component parent);
super.new(name,parent);
  //  axi_s_xtn_h=axi_slave_trans::type_id::create("axi_s_xtn_h",this);
endfunction

function void axi_slave_driver::build_phase(uvm_phase phase);
super.build_phase(phase);
 
 if(!uvm_config_db #(axi_slave_agent_config)::get(this,"","axi_slave_agent_config",axi_s_agnt_cfg))
   $fatal("SLAVE_CONFIG","SLAVE_DRIVER_CONFIG","cannot get config handle in slave driver ");

endfunction

function void axi_slave_driver::end_of_elaboration_phase(uvm_phase phase);
  
axi_s_drv_vif=axi_s_agnt_cfg.axi_s_agt_cfg_vif;
 
  
endfunction


task axi_slave_driver::run_phase(uvm_phase phase);
super.run_phase(phase);
 	
begin
     	siginal_initilization();   
		get_data_port(); 
end


endtask

task axi_slave_driver::siginal_initilization();

     
   axi_s_drv_vif.slave_driver.AWREADY<=0;
   axi_s_drv_vif.slave_driver.WREADY<=0;
  
   axi_s_drv_vif.slave_driver.BID<=0;
   axi_s_drv_vif.slave_driver.BRESP<=0;
   axi_s_drv_vif.slave_driver.BVALID<=0;
  
  
   axi_s_drv_vif.slave_driver.ARREADY<=0;
  
   axi_s_drv_vif.slave_driver.RID<=0;
   axi_s_drv_vif.slave_driver.RDATA<=0;

     axi_s_drv_vif.slave_driver.RRESP<=0;
   axi_s_drv_vif.slave_driver.RLAST<=0;
  axi_s_drv_vif.slave_driver.RVALID<=0;
  
endtask 
  

task axi_slave_driver::get_data_port(); ;
 


	 forever 
	   begin


              
	    seq_item_port.get_next_item(req);
         
         //checking_tb_env(req);
         
         case(axi_s_agnt_cfg.write_read_flag)//case(req.write_read_flag)
			2'b00 : begin
          
              send_to_dut_write(req);
              
            	   end
           	2'b01 : begin
              		send_to_dut_read(req);
            	   end
            2'b10 : begin
              fork
                 send_to_dut_write(req);
                send_to_dut_read(req);
              join
              
              		//send_to_dut_write_read(req);
  
            	   end
         endcase

         seq_item_port.item_done();
             
           end    
         
         axi_s_agnt_cfg.s_cfg_drv_count++; 
 


endtask 
  

  
task axi_slave_driver::send_to_dut_write(axi_slave_trans axi_s_xtn_h);
  if(axi_s_agnt_cfg.write_read_flag==2'b00)
`uvm_info("SLAVE_DRIVER_WRITE_CHANNLE",$sformatf("***SLAVE_DRIVER_WRITE_CHANNLE***printing from driver \n %s",axi_s_xtn_h.sprint()),UVM_HIGH);
  if(axi_s_agnt_cfg.write_read_flag==2'b10)
    `uvm_info("SLAVE_DRIVER_WRITE_READ_CHANNLE**",$sformatf("***SLAVE_DRIVER_WRITE_READ_CHANNLE***printing from driver \n %s",axi_s_xtn_h.sprint()),UVM_LOW);
  
  //write_address
fork
  begin
         @(axi_s_drv_vif.slave_driver);    		
	    axi_s_drv_vif.slave_driver.AWREADY<=1;
  
		@(axi_s_drv_vif.slave_driver);
 		//wait(axi_s_drv_vif.slave_driver.AWVALID);
			AWLEN=axi_s_drv_vif.slave_driver.AWLEN;
  			AWSIZE=axi_s_drv_vif.slave_driver.AWSIZE;
  			AWADDR=axi_s_drv_vif.slave_driver.AWADDR;
 			AWBURST=axi_s_drv_vif.slave_driver.AWBURST;
   			AWID=axi_s_drv_vif.slave_driver.AWID;
 
 		 Next_addr_cal(AWADDR,AWLEN,AWSIZE,AWBURST);
  
  		 foreach(address_[i])
 		 `uvm_info(get_type_name(),$sformatf("address_[%0d]=%0d",i,address_[i]),UVM_HIGH);
     
    if(axi_s_agnt_cfg.s_write_interleave) 
      begin
         @(axi_s_drv_vif.slave_driver); 
         @(axi_s_drv_vif.slave_driver);
           AWID1=axi_s_drv_vif.slave_driver.AWID;
      end
    
    if(axi_s_agnt_cfg.s_write_multiple_outstanding_addr) 
      begin
         @(axi_s_drv_vif.slave_driver); 
         @(axi_s_drv_vif.slave_driver);
           AWID1=axi_s_drv_vif.slave_driver.AWID;
      end
  end
  
   //write data
  
	begin
          	 @(axi_s_drv_vif.slave_driver);
	  		 axi_s_drv_vif.slave_driver.WREADY<=1;
  
			@(axi_s_drv_vif.slave_driver);  
  			for( int i=0;i<=AWLEN;i++)
	   			begin         
          
        			@(axi_s_drv_vif.slave_driver);
          			wr_rd_mem[address_[i]]=axi_s_drv_vif.slave_driver.WDATA;
          `uvm_info(get_type_name(),$sformatf("wr_rd_mem[address_[%0h]]=%0d",i,wr_rd_mem[address_[i]]),UVM_HIGH);
                        
				 end 
		 
end
  
   //write response
  
	begin	
      //repeat(6)
      //@(axi_s_drv_vif.slave_driver);
      
        wait(axi_s_drv_vif.slave_driver.WLAST)
          begin
            
            int a=axi_s_agnt_cfg.s_write_interleave?6:1;
            
            repeat(a)
            @(axi_s_drv_vif.slave_driver);
            axi_s_drv_vif.slave_driver.BID<=(axi_s_agnt_cfg.s_write_interleave)?AWID1:AWID;
		     axi_s_drv_vif.slave_driver.BRESP<=2'b11;
		     axi_s_drv_vif.slave_driver.BVALID<=1'b1;
          end
       	 //@(axi_s_drv_vif.slave_driver);
           	
  		
  		wait(axi_s_drv_vif.slave_driver.BREADY);
     	 @(axi_s_drv_vif.slave_driver);
  		axi_s_drv_vif.slave_driver.BVALID<=0;
		axi_s_drv_vif.slave_driver.BRESP<=0;
         
           	 @(axi_s_drv_vif.slave_driver);
      
      
      if(axi_s_agnt_cfg.s_write_interleave) 
      begin
        //wait(axi_s_drv_vif.slave_driver.WLAST)
          begin
            @(axi_s_drv_vif.slave_driver);
            axi_s_drv_vif.slave_driver.BID<=(axi_s_agnt_cfg.s_write_interleave)?AWID:AWID1;
		     axi_s_drv_vif.slave_driver.BRESP<=2'b11;
		     axi_s_drv_vif.slave_driver.BVALID<=1'b1;
          end
       	 //@(axi_s_drv_vif.slave_driver);
           	
  		
  		wait(axi_s_drv_vif.slave_driver.BREADY);
     	 @(axi_s_drv_vif.slave_driver);
  		axi_s_drv_vif.slave_driver.BVALID<=0;
		axi_s_drv_vif.slave_driver.BRESP<=0;
         
           	 @(axi_s_drv_vif.slave_driver);
        
        if(axi_s_agnt_cfg.s_write_multiple_outstanding_addr)
          begin
            if(i==AWLEN+1 || i<AWLEN+1)
              begin
            	@(axi_s_drv_vif.slave_driver);
            	axi_s_drv_vif.slave_driver.BID<=axi_s_xtn_h.BID;
            	axi_s_drv_vif.slave_driver.BRESP<=2'b10;
              end
          end
      end
    end 
  
  
join
  
endtask
  
  task axi_slave_driver::send_to_dut_read(axi_slave_trans axi_s_xtn_h);
    if(axi_s_agnt_cfg.write_read_flag==2'b01) 
`uvm_info("SLAVE_DRIVER_READ_CHANNLE",$sformatf("***SLAVE_DRIVER_READ_CHANNLE***printing from driver \n %s",axi_s_xtn_h.sprint()),UVM_HIGH);
 
      //read_address

   
   begin
        
		@(axi_s_drv_vif.slave_driver);
	     axi_s_drv_vif.slave_driver.ARREADY<=1;
     
     
       	 repeat(2)
		 @(axi_s_drv_vif.slave_driver);
     		ARID=axi_s_drv_vif.slave_driver.ARID;
			ARLEN=axi_s_drv_vif.slave_driver.ARLEN;
  			ARSIZE=axi_s_drv_vif.slave_driver.ARSIZE;
  			ARADDR=axi_s_drv_vif.slave_driver.ARADDR;
 			ARBURST=axi_s_drv_vif.slave_driver.ARBURST;
 
  			
 		   Next_addr_cal(ARADDR,ARLEN,ARSIZE,ARBURST);
    
      foreach(address_[i])
        `uvm_info(get_type_name(),$sformatf("read ++++address_[%0d]=%0d",i,address_[i]),UVM_HIGH);
     
    if(axi_s_agnt_cfg.s_read_interleave) 
      begin
        repeat(2)
        		 @(axi_s_drv_vif.slave_driver);
     			ARID1=axi_s_drv_vif.slave_driver.ARID;
      end
    	
   end
      
      //read_data

  begin
   // @(axi_s_drv_vif.slave_driver);
    
   		 for( int i=0;i<=ARLEN;i++)
	   		begin
              
              fork
	 				begin
					 @(axi_s_drv_vif.slave_driver);
            		 axi_s_drv_vif.slave_driver.RID<=(axi_s_agnt_cfg.s_read_out_order_resp)?ARID1:ARID; 
                     axi_s_drv_vif.slave_driver.RDATA<=axi_s_xtn_h.RDATA[i];//wr_rd_mem[address_[i]];
		  			 axi_s_drv_vif.slave_driver.RVALID<=1;
              		`uvm_info(get_type_name(),$sformatf("axi_slave_xtn_h.RDATA[i]=%0d",axi_s_xtn_h.RDATA[i]),UVM_HIGH);
                      
                    end
                begin
			 		  	if(i==ARLEN)
                    		begin
                              	@(axi_s_drv_vif.slave_driver);
				  				axi_s_drv_vif.slave_driver.RLAST<=1;
				   				axi_s_drv_vif.slave_driver.RRESP<=2'b00;
				 			 end
	           			else
			     		 	axi_s_drv_vif.slave_driver.RLAST<=0;
                end
              join
             
			 wait(axi_s_drv_vif.slave_driver.RREADY );
            	   @(axi_s_drv_vif.slave_driver); 
			     axi_s_drv_vif.slave_driver.RVALID<=0;
				 axi_s_drv_vif.slave_driver.RLAST<=0;
				 axi_s_drv_vif.slave_driver.RRESP<=2'bz;

	
    
        if(axi_s_agnt_cfg.s_read_interleave) 
     	 begin
        
               fork
	 				begin
					 @(axi_s_drv_vif.slave_driver);
                      axi_s_drv_vif.slave_driver.RID<=(axi_s_agnt_cfg.s_read_out_order_resp)?ARID:ARID1;  
                      axi_s_drv_vif.slave_driver.RDATA<=axi_s_xtn_h.RDATA[i]+1;//wr_rd_mem[address_[i]];
		  			 axi_s_drv_vif.slave_driver.RVALID<=1;
              		`uvm_info(get_type_name(),$sformatf("axi_slave_xtn_h.RDATA[i]=%0d",axi_s_xtn_h.RDATA[i]),UVM_HIGH);
                      
                    end
                begin
			 		  	if(i==ARLEN)
                    		begin
                              	@(axi_s_drv_vif.slave_driver);
				  				axi_s_drv_vif.slave_driver.RLAST<=1;
				   				axi_s_drv_vif.slave_driver.RRESP<=2'b00;
				 			 end
	           			else
			     		 	axi_s_drv_vif.slave_driver.RLAST<=0;
                end
              join
             
			 wait(axi_s_drv_vif.slave_driver.RREADY );
            	   @(axi_s_drv_vif.slave_driver); 
			     axi_s_drv_vif.slave_driver.RVALID<=0;
				 axi_s_drv_vif.slave_driver.RLAST<=0;
				 axi_s_drv_vif.slave_driver.RRESP<=2'bz;

       
     	 end
    
    
   end
    
    
  end 

	
endtask
    
  task axi_slave_driver::Next_addr_cal(int ADDR,int LEN,int SIZE,int BURST);
  
      
      
  address_=new[LEN+1'b1];
  start_address=ADDR;
  number_bytes=2**SIZE;
  burst_length=LEN+1'b1;
  aligned_address=(int'(start_address/number_bytes))*number_bytes;
  address_1=start_address;
    
	if(BURST==2'b00)
			for(int i=0; i<burst_length; i++)
					address_[i]=start_address; 

	if(BURST==2'b01)
				for(int i=0; i<burst_length; i++)
							address_[i] = aligned_address + (i * number_bytes);

	if(BURST==2'b10)
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
  

	endtask 
  
  
  
  

function void axi_slave_driver::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Report: Slave_Driver_Sent %0d transactions",axi_s_agnt_cfg.s_cfg_drv_count),UVM_LOW);
endfunction


