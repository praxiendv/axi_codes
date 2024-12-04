class axi_master_monitor1 extends uvm_monitor;

`uvm_component_utils(axi_master_monitor1)

  virtual axi_interface.MR_MON axi_m_mon_vif;
  
  axi_master_trans1 axi_m_xtn_h;
  
  axi_master_agent_config1 axi_m_agnt_cfg;
  
  //int ie;

  uvm_analysis_port #(axi_master_trans1) monitor_port;
    
  extern function new(string name="axi_master_monitor1", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
   
  extern task collect_data();
  extern task  write_data();
  extern task read_data();
  extern function void report_phase(uvm_phase phase); 
  
endclass

function axi_master_monitor1::new(string name="axi_master_monitor1", uvm_component parent);
  super.new(name,parent);  
		monitor_port=new("monitor_port",this);		 
endfunction

function void axi_master_monitor1::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if(!uvm_config_db #(axi_master_agent_config1)::get(this,"","axi_master_agent_config1",axi_m_agnt_cfg))
  `uvm_fatal("MASTER_MONITOR","can not get() axi_m_agnt_cfg from uvm_config_db")
endfunction

function void axi_master_monitor1::end_of_elaboration_phase(uvm_phase phase);
  axi_m_mon_vif=axi_m_agnt_cfg.axi_m_agt_cfg_vif; 
endfunction

task axi_master_monitor1::run_phase(uvm_phase phase); 

   //   collect_data();    

endtask




task axi_master_monitor1::collect_data();
  
			forever
						begin

								if(axi_m_agnt_cfg.write_read_flag==2'b00)
											begin
															write_data();
											end
											
								else if(axi_m_agnt_cfg.write_read_flag==2'b01)
											begin
											
														read_data();
											end
											
								else if(axi_m_agnt_cfg.write_read_flag==2'b10)
											begin
                                              fork
														write_data();
                                              			read_data();
                                              join
											end

						end
  

 

 endtask

task axi_master_monitor1::write_data();


 	axi_m_xtn_h=axi_master_trans1::type_id::create("axi_m_xtn_h",this);
fork	
  begin
	//write_address
	      @(axi_m_mon_vif.master_monitor)	
     wait(axi_m_mon_vif.master_monitor.AWVALID && axi_m_mon_vif.master_monitor.AWREADY)
  
	axi_m_xtn_h.AWADDR=axi_m_mon_vif.master_monitor.AWADDR;
	axi_m_xtn_h.AWID=axi_m_mon_vif.master_monitor.AWID;
    axi_m_xtn_h.AWLEN=axi_m_mon_vif.master_monitor.AWLEN;
    axi_m_xtn_h.AWSIZE=axi_m_mon_vif.master_monitor.AWSIZE;
    axi_m_xtn_h.AWBURST=axi_m_mon_vif.master_monitor.AWBURST;
  
   `uvm_info(get_type_name(),$sformatf("axi_m_xtn_h.AWLEN=%d",axi_m_xtn_h.AWLEN),UVM_LOW);
	 end
  
  
	//write data
 
  
  begin
	    
   
	  for(int i=0; i<=axi_m_xtn_h.AWLEN ;i++)
       begin
         
	    @(axi_m_mon_vif.master_monitor)  
         wait(axi_m_mon_vif.master_monitor.WVALID && axi_m_mon_vif.master_monitor.WREADY)
      
         @(axi_m_mon_vif.master_monitor)
		 axi_m_xtn_h.WID=axi_m_mon_vif.master_monitor.WID;
	   	axi_m_xtn_h.WDATA[i]=axi_m_mon_vif.master_monitor.WDATA;
	  // axi_m_xtn_h.WSTRB[i]=axi_m_mon_vif.master_monitor.WSTRB;
	   end

  end  
	
	//write response
	begin
	  	   @(axi_m_mon_vif.master_monitor)         
			wait(axi_m_mon_vif.master_monitor.BREADY && axi_m_mon_vif.master_monitor.BVALID)
            
  			@(axi_m_mon_vif.master_monitor)
			axi_m_xtn_h.BID=axi_m_mon_vif.master_monitor.BID;
			axi_m_xtn_h.BRESP=axi_m_mon_vif.master_monitor.BRESP;
    end	
join
			 monitor_port.write(axi_m_xtn_h);
  			`uvm_info("MASTER_MONITOR_WRITE_CHHANLE",$sformatf("printing from MASTER_MONITOR_WRITE_CHHANLE \n %s",axi_m_xtn_h.sprint()),UVM_LOW); 

      axi_m_agnt_cfg.axi_mon_count_h++;  

endtask

task axi_master_monitor1::read_data();


 	axi_m_xtn_h=axi_master_trans1::type_id::create("axi_m_xtn_h",this);
      
	//read_address
  repeat(2)
  @(axi_m_mon_vif.master_monitor);
	 wait(axi_m_mon_vif.master_monitor.ARVALID && axi_m_mon_vif.master_monitor.ARREADY)

	axi_m_xtn_h.ARADDR=axi_m_mon_vif.master_monitor.ARADDR;
	axi_m_xtn_h.ARID=axi_m_mon_vif.master_monitor.ARID;
    axi_m_xtn_h.ARLEN=axi_m_mon_vif.master_monitor.ARLEN;
    axi_m_xtn_h.ARSIZE=axi_m_mon_vif.master_monitor.ARSIZE;
    axi_m_xtn_h.ARBURST=axi_m_mon_vif.master_monitor.ARBURST;

	
	//read data
	    for(int i=0; i<=axi_m_xtn_h.ARLEN ;i++)
    begin
      repeat(2)
	    @(axi_m_mon_vif.master_monitor)   
        wait(axi_m_mon_vif.master_monitor.RREADY && axi_m_mon_vif.master_monitor.RVALID)
	    axi_m_xtn_h.RID=axi_m_mon_vif.master_monitor.RID;
	    axi_m_xtn_h.RDATA[i]=axi_m_mon_vif.master_monitor.RDATA; 
      
     // `uvm_info(get_type_name(),$sformatf("axi_m_xtn_h.RDATA[%0d]=%d",i,axi_m_xtn_h.RDATA[i]),UVM_LOW);
 
      
		axi_m_xtn_h.RRESP=axi_m_mon_vif.master_monitor.RRESP;
	    axi_m_xtn_h.RLAST=axi_m_mon_vif.master_monitor.RLAST;
      
	 end
	 
	  monitor_port.write(axi_m_xtn_h);
 
`uvm_info("MASTER_MONITOR_READ_CHHANLE",$sformatf("printing from MASTER_MONITOR_READ_CHHANLE \n %s",axi_m_xtn_h.sprint()),UVM_LOW); 

      axi_m_agnt_cfg.axi_mon_count_h++;  

endtask


  function void axi_master_monitor1::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: Master_Monitor_Sent %0d transactions",axi_m_agnt_cfg.axi_mon_count_h),UVM_LOW);

  endfunction

