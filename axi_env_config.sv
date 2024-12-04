class axi_env_config extends uvm_object;

        `uvm_object_utils(axi_env_config)
			

		//  various agents 	
        bit has_magent = 1;
  		bit has_magent1 = 1;
        bit has_sagent = 1;
		bit has_virtual_sequencer = 1;
  		bit [1:0] write_read_flag=0;
  		
  		bit has_mcollector;
  		bit has_mcollector1;
 	 	bit has_scollector;
  
		//sb
		bit has_scoreboard = 1;
		
        //dynamic array Configuration handles for the sub_components
		
        axi_master_agent_config m_agent_cfg_h[];
  		axi_master_agent_config1 m_agent_cfg_h1[];
        axi_slave_agent_config s_agent_cfg_h[];

		   int no_of_duts=1;

function new(string name = "axi_env_config");
  super.new(name);
endfunction

endclass: axi_env_config



class axi_env_config_seq extends uvm_object;

        `uvm_object_utils(axi_env_config_seq)
			

 int no_seq_xtn;

function new(string name = "axi_env_config_seq");
  super.new(name);
endfunction

endclass

