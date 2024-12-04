class axi_slave_agt_top extends uvm_env;

        `uvm_component_utils(axi_slave_agt_top)

    axi_slave_agent axi_s_agt_t_h;

        extern function new(string name = "axi_slave_agt_top" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

endclass

function axi_slave_agt_top::new(string name = "axi_slave_agt_top" , uvm_component parent);
        super.new(name,parent);
endfunction


function void axi_slave_agt_top::build_phase(uvm_phase phase);
    super.build_phase(phase);
	
        axi_s_agt_t_h=axi_slave_agent::type_id::create("axi_s_agt_t_h",this);
endfunction

task axi_slave_agt_top::run_phase(uvm_phase phase);
        //uvm_top.print_topology;
endtask

