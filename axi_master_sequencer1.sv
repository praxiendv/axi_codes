class axi_master_sequencer1 extends uvm_sequencer #(axi_master_trans1);

        `uvm_component_utils(axi_master_sequencer1)

        extern function new(string name = "axi_master_sequencer1",uvm_component parent);
endclass

function axi_master_sequencer1::new(string name="axi_master_sequencer1",uvm_component parent);
        super.new(name,parent);
endfunction