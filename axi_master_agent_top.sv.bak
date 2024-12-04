class axi_master_agt_top extends uvm_env;

   `uvm_component_utils(axi_master_agt_top)

    axi_master_agent axi_m_agnt_h;

        extern function new(string name = "axi_master_agt_top" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

endclass
          

function axi_master_agt_top::new(string name = "axi_master_agt_top" , uvm_component parent);
        super.new(name,parent);
endfunction


function void axi_master_agt_top::build_phase(uvm_phase phase);
    super.build_phase(phase);
	
        axi_m_agnt_h=axi_master_agent::type_id::create("axi_m_agnt_h",this);
endfunction

task axi_master_agt_top::run_phase(uvm_phase phase);
        uvm_top.print_topology;
endtask

