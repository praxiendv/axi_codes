class axi_slave_monitor extends uvm_monitor;

`uvm_component_utils(axi_slave_monitor)

  virtual axi_interface.SL_MON axi_s_mon_vif;
  
  axi_slave_agent_config axi_s_agnt_cfg;
  
  uvm_analysis_port#(axi_slave_trans)monitor_port;

  axi_slave_trans axi_s_xtn_h;


  
  extern function new(string name="axi_slave_monitor", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);     
  extern task collect_data();
  extern task  write_data();
  extern task read_data();
  extern function void report_phase(uvm_phase phase); 
  
endclass

function axi_slave_monitor::new(string name="axi_slave_monitor", uvm_component parent);
  super.new(name,parent);
  
	monitor_port=new("monitor_port",this);  

endfunction

function void axi_slave_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
    if(!uvm_config_db #(axi_slave_agent_config)::get(this,"","axi_slave_agent_config",axi_s_agnt_cfg))
    `uvm_info("SLAVE_DRIVER_CONFIG","cannot get config handle in slave monitor ",UVM_LOW);
  
endfunction

function void axi_slave_monitor::end_of_elaboration_phase(uvm_phase phase);
    axi_s_mon_vif=axi_s_agnt_cfg.axi_s_agt_cfg_vif;
endfunction

task axi_slave_monitor::run_phase(uvm_phase phase);
 
	  // 		collect_data();  

endtask

task axi_slave_monitor::collect_data();
  
			forever
						begin

								if(axi_s_agnt_cfg.write_read_flag==2'b00)
											begin
															write_data();
											end
											
								else if(axi_s_agnt_cfg.write_read_flag==2'b01)
											begin
											
														read_data();
											end
											
								else if(axi_s_agnt_cfg.write_read_flag==2'b10)
											begin
                                              fork
														write_data();
                                              			read_data();
                                              join
											end

						end
  
 endtask

   
   
task axi_slave_monitor::write_data();


  	axi_s_xtn_h=axi_slave_trans::type_id::create("axi_s_xtn_h",this); 

     fork 
      //write address
      begin
        @(axi_s_mon_vif.slave_monitor);
		wait(axi_s_mon_vif.slave_monitor.AWVALID && axi_s_mon_vif.slave_monitor.AWREADY)
	   	axi_s_xtn_h.AWADDR=axi_s_mon_vif.slave_monitor.AWADDR;
	   	axi_s_xtn_h.AWID=axi_s_mon_vif.slave_monitor.AWID;
       	axi_s_xtn_h.AWADDR=axi_s_mon_vif.slave_monitor.AWADDR;
       	axi_s_xtn_h.AWLEN=axi_s_mon_vif.slave_monitor.AWLEN;
       	axi_s_xtn_h.AWSIZE=axi_s_mon_vif.slave_monitor.AWSIZE;
       	axi_s_xtn_h.AWBURST=axi_s_mon_vif.slave_monitor.AWBURST;
      end
      
      //write data
      begin
        for(int i=0; i<=axi_s_xtn_h.AWLEN ;i++)
    	begin
	    	@(axi_s_mon_vif.slave_monitor)         
      	 	wait(axi_s_mon_vif.slave_monitor.WVALID && axi_s_mon_vif.slave_monitor.WREADY)
      
       		@(axi_s_mon_vif.slave_monitor) 
		   	axi_s_xtn_h.WID=axi_s_mon_vif.slave_monitor.WID;
	      	axi_s_xtn_h.WDATA[i]=axi_s_mon_vif.slave_monitor.WDATA;
     // `uvm_info(get_type_name(),$sformatf("axi_s_mon_vif.slave_monitor.WDATA=%d",axi_s_mon_vif.slave_monitor.WDATA),UVM_HIGH);
      
      //`uvm_info(get_type_name(),$sformatf("axi_s_xtn_h.WDATA[%0d]=%d",i,axi_s_xtn_h.WDATA[i]),UVM_LOW);
      
	      	axi_s_xtn_h.WSTRB[i]=axi_s_mon_vif.slave_monitor.WSTRB;
	 	end
      end
      
      //write response
     begin
	    @(axi_s_mon_vif.slave_monitor)         
       	wait(axi_s_mon_vif.slave_monitor.BREADY && axi_s_mon_vif.slave_monitor.BREADY)
	    axi_s_xtn_h.BID=axi_s_mon_vif.slave_monitor.BID;
     end
       
     join
       
     	monitor_port.write(axi_s_xtn_h);  
     
      
       `uvm_info("SLAVE_MONITOR_WRITE",$sformatf("***SLAVE_MONITOR_WRITE***printing from slave monitor_WRITE \n %s",axi_s_xtn_h.sprint()),UVM_LOW);
     
      axi_s_agnt_cfg.s_cfg_mon_count++;	

endtask

    
    
    
task axi_slave_monitor::read_data();

		axi_s_xtn_h=axi_slave_trans::type_id::create("axi_s_xtn_h",this); 

    
      
     // read address
  repeat(2)  
  @(axi_s_mon_vif.slave_monitor);
  		wait(axi_s_mon_vif.slave_monitor.ARVALID && axi_s_mon_vif.slave_monitor.ARREADY)
	   axi_s_xtn_h.ARADDR=axi_s_mon_vif.slave_monitor.ARADDR;
	   axi_s_xtn_h.ARID=axi_s_mon_vif.slave_monitor.ARID;
       axi_s_xtn_h.ARLEN=axi_s_mon_vif.slave_monitor.ARLEN;
       axi_s_xtn_h.ARSIZE=axi_s_mon_vif.slave_monitor.ARSIZE;
       axi_s_xtn_h.ARBURST=axi_s_mon_vif.slave_monitor.ARBURST;
	        
     
     //read data
     
   for(int i=0; i<=axi_s_xtn_h.ARLEN ;i++)
    begin
      repeat(2)
	    @(axi_s_mon_vif.slave_monitor)         
      wait(axi_s_mon_vif.slave_monitor.RREADY && axi_s_mon_vif.slave_monitor.RVALID )
		  axi_s_xtn_h.RID=axi_s_mon_vif.slave_monitor.RID;
	      axi_s_xtn_h.RDATA[i]=axi_s_mon_vif.slave_monitor.RDATA;
	 end

		monitor_port.write(axi_s_xtn_h);  

       `uvm_info("SLAVE_MONITOR_READ",$sformatf("***SLAVE_MONITOR_READ***printing from slave monitor_READ \n %s",axi_s_xtn_h.sprint()),UVM_LOW);
     
      axi_s_agnt_cfg.s_cfg_mon_count++;
endtask

   
 
function void axi_slave_monitor::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(), $sformatf("Report: slave_Monitor_Sent %0d transactions",axi_s_agnt_cfg.s_cfg_mon_count),UVM_LOW);
endfunction

