class axi_master_agent_config1 extends uvm_object;

       `uvm_object_utils(axi_master_agent_config1)
		
		static int axi_mon_count_h;
		static int  axi_drv_count_h;
  
        bit [1:0]	write_read_flag;
		bit driver_mode=0;
        bit [4:0]delay_cycle=1;
  
    int no_seq_xtn;
  
  		int m_write_interleave;
  		int m_write_out_order_resp;
  
    	int m_read_interleave;
  		int m_read_out_order_resp;

        // virtual interface 
        virtual axi_interface axi_m_agt_cfg_vif;
  
        uvm_active_passive_enum is_active; 
		
  function new(string name = "axi_master_agent_config1");
    super.new(name);
  endfunction

endclass: axi_master_agent_config1


