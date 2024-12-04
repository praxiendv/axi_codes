class axi_slave_agent_config extends uvm_object;

        `uvm_object_utils(axi_slave_agent_config)
		
		static int s_cfg_mon_count;

		static int s_cfg_drv_count;
		
        uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  bit [1:0]	write_read_flag;
  int no_seq_xtn;
  
    		int s_write_interleave;
  			int s_write_out_order_resp;
  			int s_write_multiple_outstanding_addr;
  
      		int s_read_interleave;
  			int s_read_out_order_resp;
  			int s_read_multiple_outstanding_addr;

        // virtual interface 
        virtual axi_interface axi_s_agt_cfg_vif;

function new(string name = "axi_slave_agent_config");
  super.new(name);
endfunction

endclass: axi_slave_agent_config


