class axi_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item) ;


        `uvm_component_utils(axi_virtual_sequencer)



        axi_master_sequencer master_seqrh_h[];
  		axi_master_sequencer1 master_seqrh_h1[];
        axi_slave_sequencer slave_seqrh_h[];


         axi_env_config axi_env_cfg_h;



        extern function new(string name = "axi_virtual_sequencer",uvm_component parent);
        extern function void build_phase(uvm_phase phase);
endclass


function axi_virtual_sequencer::new(string name="axi_virtual_sequencer",uvm_component parent);
        super.new(name,parent);
endfunction


function void axi_virtual_sequencer::build_phase(uvm_phase phase);
  
        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg_h))
        `uvm_fatal("CONFIG","cannot get() axi_env_cfg_h from uvm_config_db. Have you set() it?")
    super.build_phase(phase);


    master_seqrh_h = new[axi_env_cfg_h.no_of_duts];
  	master_seqrh_h1 = new[axi_env_cfg_h.no_of_duts];
    slave_seqrh_h = new[axi_env_cfg_h.no_of_duts];
endfunction

