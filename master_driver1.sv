class axi_master_driver1 extends uvm_driver #(axi_master_trans1);

`uvm_component_utils(axi_master_driver1)

virtual axi_interface.MR_DRV axi_m_drv_vif;

axi_master_agent_config1 axi_m_agnt_cfg;
  
 

  /*
parameter WRITE=2'b00,
  			READ=2'b01,
  			WRITE_READ=2'b11;*/
  			

bit [7:0]data=0;
  int len,len1;

extern function new(string name="axi_master_driver1", uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void end_of_elaboration_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
  
extern task siginal_initilization(); 
extern task get_data_port(); 
  
  extern task send_to_dut_write(axi_master_trans1 axi_m_xtn_h);
    extern task send_to_dut_read(axi_master_trans1 axi_m_xtn_h);
extern function void report_phase(uvm_phase phase);
endclass

function axi_master_driver1::new(string name="axi_master_driver1", uvm_component parent);
  super.new(name,parent);
endfunction

function void axi_master_driver1::build_phase(uvm_phase phase);
  super.build_phase(phase);
 if(!uvm_config_db #(axi_master_agent_config1)::get(this,"","axi_master_agent_config1",axi_m_agnt_cfg))
   $fatal("MASTER_CONFIG","axi_m_agnt_cfg can not get in master driver class");
endfunction

function void axi_master_driver1 ::end_of_elaboration_phase(uvm_phase phase);
 axi_m_drv_vif=axi_m_agnt_cfg.axi_m_agt_cfg_vif;
endfunction


task axi_master_driver1::run_phase(uvm_phase phase);
  super.run_phase(phase);

  

   begin
       
       siginal_initilization();
  
		get_data_port(); 
     
   end

  
endtask

  
task axi_master_driver1::siginal_initilization();
 
  
    axi_m_drv_vif.master_driver.AWID<=0;
  //`uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.AWID=%d",axi_m_drv_vif.master_driver.AWID),UVM_HIGH);  
  axi_m_drv_vif.master_driver.AWADDR<=0; 
   // `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.AWADDR=%d",axi_m_drv_vif.master_driver.AWADDR),UVM_HIGH);
  axi_m_drv_vif.master_driver.AWLEN<=0;
   // `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.AWLEN=%d",axi_m_drv_vif.master_driver.AWLEN),UVM_HIGH);
  axi_m_drv_vif.master_driver.AWSIZE<=0;
  //  `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.AWSIZE=%d",axi_m_drv_vif.master_driver.AWSIZE),UVM_HIGH);
  axi_m_drv_vif.master_driver.AWBURST<=0;
 //   `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.AWBURST=%d",axi_m_drv_vif.master_driver.AWBURST),UVM_HIGH);
  axi_m_drv_vif.master_driver.AWVALID<=0;
 //   `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.AWVALID=%d",axi_m_drv_vif.master_driver.AWVALID),UVM_HIGH);

  
  axi_m_drv_vif.master_driver.WID<=0;
//  `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.WID=%d",axi_m_drv_vif.master_driver.WID),UVM_HIGH);
  axi_m_drv_vif.master_driver.WSTRB<=0;
 // `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.WSTRB=%d",axi_m_drv_vif.master_driver.WSTRB),UVM_HIGH);
  axi_m_drv_vif.master_driver.WDATA<=0;
//  `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.WDATA=%d",axi_m_drv_vif.master_driver.WDATA),UVM_HIGH);
  axi_m_drv_vif.master_driver.WLAST<=0;
//  `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.WLAST=%d",axi_m_drv_vif.master_driver.WLAST),UVM_HIGH);
  axi_m_drv_vif.master_driver.WVALID<=0;
 // `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.WVALID=%d",axi_m_drv_vif.master_driver.WVALID),UVM_HIGH);
   
  axi_m_drv_vif.master_driver.BREADY<=0;
 // `uvm_info(get_type_name(),$sformatf(" axi_m_drv_vif.master_driver.BREADY=%d",axi_m_drv_vif.master_driver.BREADY),UVM_HIGH);

  axi_m_drv_vif.master_driver.ARID<=0;
  axi_m_drv_vif.master_driver.ARADDR<=0; 
  axi_m_drv_vif.master_driver.ARLEN<=0;
  axi_m_drv_vif.master_driver.ARSIZE<=0;
  axi_m_drv_vif.master_driver.ARBURST<=0;
  axi_m_drv_vif.master_driver.ARVALID<=0;
  
  axi_m_drv_vif.master_driver.RREADY<=0;


  
  
endtask 
  
  
task axi_master_driver1::get_data_port(); 
  


	 forever 
       
	   begin
            
         
         
         $display("master driver axi_m_agnt_cfg.write_read_flag=%b",axi_m_agnt_cfg.write_read_flag);
                
         
	    seq_item_port.get_next_item(req);
         
         

         case(axi_m_agnt_cfg.write_read_flag)  
			2'b00 : begin
              		send_to_dut_write(req);
            	   end
           	2'b01 : begin
              	//	send_to_dut_read(req);
            	   end
            2'b10 : begin
              
              fork
               //send_to_dut_write(req);
               // send_to_dut_read(req);
              join
              
             		//send_to_dut_write_read(req);
            	   end
         endcase
           
       /* $display("master driver req.action_h=%b",req.action_h);
              case(req.action_h)
			WRITE : begin
              		send_to_dut_write(req);
            	   end
           	READ : begin
              		send_to_dut_read(req);
            	   end
           WRITE_READ : begin
              		send_to_dut_write_read(req);
            	   end
         endcase*/
         seq_item_port.item_done();
         

         axi_m_agnt_cfg.axi_drv_count_h++;
        end
         
      

endtask 
  

  
  task axi_master_driver1::send_to_dut_write(axi_master_trans1 axi_m_xtn_h);
    if(axi_m_agnt_cfg.write_read_flag==2'b00)
    `uvm_info("MASTER_DRIVER_WRITE_CHANNLE",$sformatf("***MASTER_DRIVER_WRITE_CHANNLE***printing from driver \n %s",axi_m_xtn_h.sprint()),UVM_HIGH);
    if(axi_m_agnt_cfg.write_read_flag==2'b10)
      `uvm_info("MASTER_DRIVER_WRITE_READ_CHANNLE**",$sformatf("***MASTER_DRIVER_WRITE_READ_CHANNLE**printing from driver \n %s",axi_m_xtn_h.sprint()),UVM_HIGH);
      
    len=axi_m_xtn_h.AWLEN+1;
    
	fork
    //write_address
	           begin     				

					@(axi_m_drv_vif.master_driver);
					axi_m_drv_vif.master_driver.AWID<=axi_m_xtn_h.AWID;
					axi_m_drv_vif.master_driver.AWADDR<=axi_m_xtn_h.AWADDR;
					axi_m_drv_vif.master_driver.AWLEN<=axi_m_xtn_h.AWLEN;
					axi_m_drv_vif.master_driver.AWSIZE<=axi_m_xtn_h.AWSIZE;
					axi_m_drv_vif.master_driver.AWBURST<=axi_m_xtn_h.AWBURST;
					
					//@(axi_m_drv_vif.master_driver);
					axi_m_drv_vif.master_driver.AWVALID<=1;
                  
          
					
					wait(axi_m_drv_vif.master_driver.AWREADY);
                 	@(axi_m_drv_vif.master_driver);
					axi_m_drv_vif.master_driver.AWVALID<=0;	
                 
                 if(axi_m_agnt_cfg.m_write_interleave)
                   begin
                     	@(axi_m_drv_vif.master_driver);
						axi_m_drv_vif.master_driver.AWID<=axi_m_xtn_h.AWID+2;
						axi_m_drv_vif.master_driver.AWADDR<=axi_m_xtn_h.AWADDR+4;
						axi_m_drv_vif.master_driver.AWLEN<=axi_m_xtn_h.AWLEN;
						axi_m_drv_vif.master_driver.AWSIZE<=axi_m_xtn_h.AWSIZE;
						axi_m_drv_vif.master_driver.AWBURST<=axi_m_xtn_h.AWBURST;
					
						//@(axi_m_drv_vif.master_driver);
						axi_m_drv_vif.master_driver.AWVALID<=1;
                  
          
					
						wait(axi_m_drv_vif.master_driver.AWREADY);
                 		@(axi_m_drv_vif.master_driver);
						axi_m_drv_vif.master_driver.AWVALID<=0;	
                   end
               end
    
    
	
	//write_data
	begin
			
		
         for( int i=0;i<len;i++)
			begin
																		
				@(axi_m_drv_vif.master_driver);						
				axi_m_drv_vif.master_driver.WID<=axi_m_xtn_h.WID;
                axi_m_drv_vif.master_driver.WDATA<=axi_m_xtn_h.WDATA[i];
				//axi_m_drv_vif.master_driver.WSTRB<=axi_m_xtn_h.WSTRB[i];
				axi_m_drv_vif.master_driver.WLAST<= (i == len-1) ? 1:0;
                                          										
				axi_m_drv_vif.master_driver.WVALID<=1;
																				
				#2;
				wait(axi_m_drv_vif.master_driver.WREADY);			 
				axi_m_drv_vif.master_driver.WLAST<=0;
				axi_m_drv_vif.master_driver.WVALID<=0;
																												@(axi_m_drv_vif.master_driver);	
              	
              
              if(axi_m_agnt_cfg.m_write_interleave)
                begin
                 @(axi_m_drv_vif.master_driver);
              	axi_m_drv_vif.master_driver.WID<=axi_m_xtn_h.WID+2;
              axi_m_drv_vif.master_driver.WDATA<=axi_m_xtn_h.WDATA[i]+4;
              				axi_m_drv_vif.master_driver.WLAST<= (i == len-1) ? 1:0;
                                          										
				axi_m_drv_vif.master_driver.WVALID<=1;
																				
				#2;
				wait(axi_m_drv_vif.master_driver.WREADY);			 
				axi_m_drv_vif.master_driver.WLAST<=0;
				axi_m_drv_vif.master_driver.WVALID<=0;
                  
                end
              @(axi_m_drv_vif.master_driver);
			end
      
      
      end	
      
    		//write_response
     		begin
					@(axi_m_drv_vif.master_driver);
					axi_m_drv_vif.master_driver.BREADY<=1;
     		end
    join


  endtask
  
  task axi_master_driver1::send_to_dut_read(axi_master_trans1 axi_m_xtn_h);
      if(axi_m_agnt_cfg.write_read_flag==2'b01)
	 `uvm_info("MASTER_DRIVER_READ_CHANNLE",$sformatf("***MASTER_DRIVER_READ_CHANNLE***printing from driver \n %s",axi_m_xtn_h.sprint()),UVM_HIGH);

          							@(axi_m_drv_vif.master_driver);												
								axi_m_drv_vif.master_driver.RREADY<=1;
	
	//read address
							begin
   
									@(axi_m_drv_vif.master_driver);
									axi_m_drv_vif.master_driver.ARID<=axi_m_xtn_h.ARID;
									axi_m_drv_vif.master_driver.ARADDR<=axi_m_xtn_h.ARADDR;
									axi_m_drv_vif.master_driver.ARLEN<=axi_m_xtn_h.ARLEN;
									axi_m_drv_vif.master_driver.ARSIZE<=axi_m_xtn_h.ARSIZE;
									axi_m_drv_vif.master_driver.ARBURST<=axi_m_xtn_h.ARBURST;
									
									axi_m_drv_vif.master_driver.ARVALID<=1;
	 
									
									wait(axi_m_drv_vif.master_driver.ARREADY);
                              		@(axi_m_drv_vif.master_driver);
								    axi_m_drv_vif.master_driver.ARVALID<=0;
                              
                              if(axi_m_agnt_cfg.m_read_interleave)
                                begin
                              		@(axi_m_drv_vif.master_driver);
									axi_m_drv_vif.master_driver.ARID<=axi_m_xtn_h.ARID+2;
									axi_m_drv_vif.master_driver.ARADDR<=axi_m_xtn_h.ARADDR+4;
									axi_m_drv_vif.master_driver.ARLEN<=axi_m_xtn_h.ARLEN;
									axi_m_drv_vif.master_driver.ARSIZE<=axi_m_xtn_h.ARSIZE;
									axi_m_drv_vif.master_driver.ARBURST<=axi_m_xtn_h.ARBURST;
									
									axi_m_drv_vif.master_driver.ARVALID<=1;
	 
									
									wait(axi_m_drv_vif.master_driver.ARREADY);
                              		@(axi_m_drv_vif.master_driver);
								    axi_m_drv_vif.master_driver.ARVALID<=0;
                                end
                              
                            end   
		
							
	//read data
      				begin
      							@(axi_m_drv_vif.master_driver);												
								//axi_m_drv_vif.master_driver.RREADY<=1;
   
							
								for(int i=0;i<=axi_m_xtn_h.ARLEN;i++)
									begin
 

                                        @(axi_m_drv_vif.master_driver);
										axi_m_xtn_h.RDATA[i]=axi_m_drv_vif.master_driver.RDATA;
                                        axi_m_xtn_h.RID<=axi_m_drv_vif.master_driver.RID;
                                        // $display("axi_m_drv_vif.master_driver.RDATA=%0d",axi_m_drv_vif.master_driver.RDATA);
                            	 		`uvm_info(get_type_name(),$sformatf("axi_m_xtn_h.RDATA[%0d]=%0d",i,axi_m_xtn_h.RDATA[i]),UVM_HIGH);
											  
											  
                                        //axi_m_xtn_h.RRESP<=axi_m_drv_vif.master_driver.RRESP;
										//axi_m_xtn_h.RLAST<=axi_m_drv_vif.master_driver.RLAST;										
									
									end 
                      
                      
                     if(axi_m_agnt_cfg.m_read_interleave)
                                begin
                                  
                                  
                                  	for(int i=0;i<=axi_m_xtn_h.ARLEN;i++)
									begin
 

                                        @(axi_m_drv_vif.master_driver);
										axi_m_xtn_h.RDATA[i]=axi_m_drv_vif.master_driver.RDATA;
                                        axi_m_xtn_h.RID<=axi_m_drv_vif.master_driver.RID;
                                        // $display("axi_m_drv_vif.master_driver.RDATA=%0d",axi_m_drv_vif.master_driver.RDATA);
                            	 		`uvm_info(get_type_name(),$sformatf("axi_m_xtn_h.RDATA[%0d]=%0d",i,axi_m_xtn_h.RDATA[i]),UVM_HIGH);
											  
											  
                                        //axi_m_xtn_h.RRESP<=axi_m_drv_vif.master_driver.RRESP;
										//axi_m_xtn_h.RLAST<=axi_m_drv_vif.master_driver.RLAST;										
									
									end
                                  
                                end
                      
        			end
   
  //repeat(2)
  //@(axi_m_drv_vif.master_driver);
					
      
  endtask


function void axi_master_driver1::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Report: Master_Driver_Sent %0d transactions",axi_m_agnt_cfg.axi_drv_count_h),UVM_LOW)
endfunction

