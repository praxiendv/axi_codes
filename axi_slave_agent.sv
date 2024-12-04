class axi_slave_agent extends uvm_agent;

        `uvm_component_utils(axi_slave_agent)

    axi_slave_agent_config axi_s_agt_cfg_h;


        axi_slave_monitor axi_s_mon_h;
        axi_slave_sequencer axi_s_seqrh_h;
        axi_slave_driver axi_s_drvh_h;

        extern function new(string name = "axi_slave_agent", uvm_component parent = null);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);

endclass : axi_slave_agent

function axi_slave_agent::new(string name = "axi_slave_agent",
                           uvm_component parent = null);
        super.new(name, parent);
endfunction

function void axi_slave_agent::build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db #(axi_slave_agent_config)::get(this,"","axi_slave_agent_config",axi_s_agt_cfg_h))
                `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
          
       axi_s_mon_h=axi_slave_monitor::type_id::create("axi_s_mon_h",this);
  
        if(axi_s_agt_cfg_h.is_active==UVM_ACTIVE)
                begin
                       axi_s_drvh_h=axi_slave_driver::type_id::create("axi_s_drvh_h",this);
                        axi_s_seqrh_h=axi_slave_sequencer::type_id::create("axi_s_seqrh_h",this);
                end

endfunction

function void axi_slave_agent::connect_phase(uvm_phase phase);
        if(axi_s_agt_cfg_h.is_active==UVM_ACTIVE)
                begin
                      axi_s_drvh_h.seq_item_port.connect(axi_s_seqrh_h.seq_item_export);
                end
endfunction
