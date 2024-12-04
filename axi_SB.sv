class axi_SB extends uvm_scoreboard;

        `uvm_component_utils(axi_SB)
		
	//master analysis fifo
	uvm_tlm_analysis_fifo#(axi_master_trans)fifo_master;
  
  uvm_tlm_analysis_fifo#(axi_master_trans1)fifo_master1;

	//slave analysis fifo
	uvm_tlm_analysis_fifo#(axi_slave_trans)fifo_slave;
	
axi_env_config m_cfg;
  
		// xtns_compared : number of xtns compared
		// xtns_dropped : calculates number of xtns failed
		
        int  xtns_compared ,xtns_dropped;

        axi_master_trans xtn_master;
  		axi_master_trans1 xtn_master1;
		axi_slave_trans xtn_slave;


        extern function new(string name,uvm_component parent);
        extern task run_phase(uvm_phase phase);
          extern function void build_phase(uvm_phase phase);
		 extern function void WADDR_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);
		extern function void WDATA_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave); 
		extern function void WRESP_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);
		extern function void RADDR_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);
		extern function void RDATA_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);
        extern function void report_phase(uvm_phase phase);

endclass


function axi_SB::new(string name,uvm_component parent);

        super.new(name,parent);
       
		fifo_master= new("fifo_master", this);	
  		fifo_master1= new("fifo_master1", this);	
		fifo_slave= new("fifo_slave", this);
		
	xtn_master=	axi_master_trans::type_id::create("xtn_master",this);
  	xtn_master1= axi_master_trans1::type_id::create("xtn_master1",this);
	xtn_slave=	axi_slave_trans::type_id::create("xtn_slave",this);
	
endfunction

function void axi_SB::build_phase(uvm_phase phase);
	
        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",m_cfg))
                `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
          
endfunction
          
task axi_SB::run_phase(uvm_phase phase);
  
                forever
                        begin
						
									if(m_cfg.write_read_flag==2'b00)
											begin
													fork														
                                                      fifo_master.get(xtn_master);																											  fifo_master1.get(xtn_master1);
													  fifo_slave.get(xtn_slave);																																													
													join
													
													WADDR_check_data(xtn_master,xtn_slave);
													WDATA_check_data(xtn_master,xtn_slave);
													WRESP_check_data(xtn_master,xtn_slave);

													
											end
								
									else  if(m_cfg.write_read_flag==2'b01)
											begin
													fork
														fifo_master.get(xtn_master);																											fifo_master1.get(xtn_master1);
														fifo_slave.get(xtn_slave);
														
													join
													
													RADDR_check_data(xtn_master,xtn_slave);
													RDATA_check_data(xtn_master,xtn_slave);
											end
								
									else if(m_cfg.write_read_flag==2'b10)
											begin
													fork
															fifo_master.get(xtn_master);
                                                      		fifo_master1.get(xtn_master1);
															fifo_slave.get(xtn_slave);																													
													join
													
													WADDR_check_data(xtn_master,xtn_slave);
													WDATA_check_data(xtn_master,xtn_slave);
													WRESP_check_data(xtn_master,xtn_slave);		
													RADDR_check_data(xtn_master,xtn_slave);
													RDATA_check_data(xtn_master,xtn_slave);													
										 end
							
                        end


endtask

function void axi_SB::WADDR_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);

   begin
				if(xtn_master.AWADDR==xtn_slave.AWADDR)
						begin
                          $display("******************xtn_master.AWADDR=%0d**************xtn_slave.AWADDR=%0d",xtn_master.AWADDR,xtn_slave.AWADDR);
								`uvm_info("SCOREBOARD","COMPARISION for AWADDR is SUCCESSFUL",UVM_LOW)
									xtns_compared++ ;
						end
				else
						begin
								`uvm_error("SCOREBOARD","COMPARISION is MISSMATCH")
								xtns_dropped++ ;
						end
     
     
				if(xtn_master.AWLEN==xtn_slave.AWLEN)
						begin
							`uvm_info("SCOREBOARD","COMPARISION for AWLEN is SUCCESSFUL",UVM_LOW)
								xtns_compared++ ;
						end
				else
						begin
								`uvm_error("SCOREBOARD","COMPARISION is MISSMATCH")
								xtns_dropped++ ;
						end     
     
				if(xtn_master.AWSIZE==xtn_slave.AWSIZE)
						begin
								`uvm_info("SCOREBOARD","COMPARISION for AWSIZE is SUCCESSFUL",UVM_LOW)
								xtns_compared++ ;
						end
				else
						begin
								`uvm_error("SCOREBOARD","COMPARISION is MISSMATCH")
								xtns_dropped++ ;
						end     
     
				if(xtn_master.AWBURST==xtn_slave.AWBURST)
						begin
								`uvm_info("SCOREBOARD","COMPARISION for AWBURST is SUCCESSFUL",UVM_LOW)
								xtns_compared++ ;
						end	
				else
						begin
								`uvm_error("SCOREBOARD","COMPARISION is MISSMATCH")
								xtns_dropped++ ;
						end     

				if(xtn_master.AWID==xtn_slave.AWID)
						begin
							`uvm_info("SCOREBOARD","COMPARISION for AWID is SUCCESSFUL",UVM_LOW)
							xtns_compared++ ;
						end	
				else
						begin
								`uvm_error("SCOREBOARD","COMPARISION is MISSMATCH")
								xtns_dropped++ ;
						end
	end

endfunction

function void axi_SB::WDATA_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);

  begin
                
				for(int i=0;i<=xtn_master.AWLEN;i++)
					begin
					        if(xtn_master.WID==xtn_slave.WID)
								begin
										`uvm_info("SCOREBOARD","COMPARISION for WID is SUCCESSFUL",UVM_LOW)
											xtns_compared++ ;
								end
					
							if(xtn_master.WDATA[i]==xtn_slave.WDATA[i])
								begin
										`uvm_info("SCOREBOARD","COMPARISION for WDATA is SUCCESSFUL",UVM_LOW)
											xtns_compared++ ;
								end
								
							else
								begin
											`uvm_error("SCOREBOARD","COMPARISION of WDATA is MISSMATCH")//uvm_error
											xtns_dropped++ ;
								end
					end
end

endfunction

function void axi_SB::WRESP_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);

     begin
      if(xtn_master.BID==xtn_slave.BID)
       begin
        `uvm_info("SCOREBOARD","COMPARISION for WID is SUCCESSFUL",UVM_LOW)
         xtns_compared++ ;
       end
    else
     begin
      `uvm_error("SCOREBOARD","COMPARISION of WID is MISSMATCH")
       xtns_dropped++ ;
     end
  end

endfunction

function void axi_SB::RADDR_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);

  begin
					if(xtn_master.ARADDR==xtn_slave.ARADDR)
							begin
										$display("************ARADDDDDDDDDDDDDDDRRRRRRRR******%d**************%d",xtn_master.ARADDR,xtn_slave.ARADDR);
										`uvm_info("SCOREBOARD","COMPARISION for ARADDR is SUCCESSFUL",UVM_LOW)
										xtns_compared++ ;
							end
					if(xtn_master.ARLEN==xtn_slave.ARLEN)
							begin
										`uvm_info("SCOREBOARD","COMPARISION for ARLEN is SUCCESSFUL",UVM_LOW)
										xtns_compared++ ;
							end

					if(xtn_master.ARSIZE==xtn_slave.ARSIZE)
							begin
								`uvm_info("SCOREBOARD","COMPARISION for AWSIZE is SUCCESSFUL",UVM_LOW)
									xtns_compared++ ;
							end
					if(xtn_master.ARBURST==xtn_slave.ARBURST)
							begin
									`uvm_info("SCOREBOARD","COMPARISION for AWBURST is SUCCESSFUL",UVM_LOW)
										xtns_compared++ ;
							end	

					if(xtn_master.ARID==xtn_slave.ARID)
							begin
								`uvm_info("SCOREBOARD","COMPARISION for AWID is SUCCESSFUL",UVM_LOW)
								xtns_compared++ ;
							end
	
					else
						begin
								`uvm_error("SCOREBOARD","COMPARISION is MISSMATCH")
									xtns_dropped++ ;
						end
end


endfunction

function void axi_SB::RDATA_check_data(axi_master_trans xtn_master,axi_slave_trans xtn_slave);

  begin
					//for(int i=0;i<=xtn_master.ARLEN;i++)
						//begin
						        if(xtn_master.RID==xtn_slave.RID)
										begin
												`uvm_info("SCOREBOARD","COMPARISION for RID is SUCCESSFUL",UVM_LOW)
												xtns_compared++ ;
										end
							/*	if(xtn_master.RDATA[i]==xtn_slave.RDATA[i])
										begin
												`uvm_info("SCOREBOARD","COMPARISION for RDATA is SUCCESSFUL",UVM_LOW)
												xtns_compared++ ;
										end*/
								else
										begin
												`uvm_error("SCOREBOARD","COMPARISION of RDATA is MISSMATCH")
													xtns_dropped++ ;
										end
						//end
end

endfunction


function void axi_SB::report_phase(uvm_phase phase);
`uvm_info(get_type_name(), $sformatf("\n \n Number of Read Transactions Dropped : %0d \n Number of Read Transactions compared : %0d \n\n",xtns_dropped,xtns_compared), UVM_LOW)
endfunction
