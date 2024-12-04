class axi_master_sequencer extends uvm_sequencer #(axi_master_trans);

        `uvm_component_utils(axi_master_sequencer)

        extern function new(string name = "axi_master_sequencer",uvm_component parent);
endclass

function axi_master_sequencer::new(string name="axi_master_sequencer",uvm_component parent);
        super.new(name,parent);
endfunction