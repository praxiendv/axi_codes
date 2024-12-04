class axi_slave_sequencer extends uvm_sequencer #(axi_slave_trans);

        `uvm_component_utils(axi_slave_sequencer)

        extern function new(string name = "axi_slave_sequencer",uvm_component parent);
endclass

function axi_slave_sequencer::new(string name="axi_slave_sequencer",uvm_component parent);
        super.new(name,parent);
endfunction