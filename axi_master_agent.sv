class axi_master_agent extends uvm_agent;

        `uvm_component_utils(axi_master_agent)

        axi_master_agent_config axi_m_agt_cfg_h;

        axi_master_monitor axi_m_mon_h;
        axi_master_sequencer axi_m_seqr_h;
        axi_master_driver axi_m_drv_h;

        extern function new(string name = "axi_master_agent", uvm_component parent = null);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);

endclass : axi_master_agent

function axi_master_agent::new(string name = "axi_master_agent",
                           uvm_component parent = null);
        super.new(name, parent);
endfunction

function void axi_master_agent::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(axi_master_agent_config)::get(this,"","axi_master_agent_config",axi_m_agt_cfg_h))
                `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
        axi_m_mon_h=axi_master_monitor::type_id::create("axi_m_mon_h",this);
        if(axi_m_agt_cfg_h.is_active==UVM_ACTIVE)
                begin
                    axi_m_drv_h=axi_master_driver::type_id::create("axi_m_drv_h",this);
                    axi_m_seqr_h=axi_master_sequencer::type_id::create("axi_m_seqr_h",this);
                end

endfunction

function void axi_master_agent::connect_phase(uvm_phase phase);
  
        if(axi_m_agt_cfg_h.is_active==UVM_ACTIVE)
                begin  
                  axi_m_drv_h.seq_item_port.connect(axi_m_seqr_h.seq_item_export);
                end
endfunction
