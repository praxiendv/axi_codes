class master_collector1 extends uvm_subscriber #(axi_master_trans1);
   `uvm_component_utils (master_collector1)

   axi_master_trans1 t;

   covergroup mstr_coverage;
      option.per_instance         = 1;

   endgroup


  virtual function void sample(axi_master_trans1 t);

this.t=t;
mstr_coverage.sample();

endfunction

function new (string name = "master_collector1",uvm_component parent);
   super.new(name,parent);
   mstr_coverage=new();
endfunction : new

  function void write(axi_master_trans1 t);

    sample(t);

`uvm_info(get_type_name(),$sformatf("master_collector1 coverage"),UVM_NONE);

endfunction

endclass
