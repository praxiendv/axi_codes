class master_collector extends uvm_subscriber #(axi_master_trans);
   `uvm_component_utils (master_collector)

   axi_master_trans t;

   covergroup mstr_coverage;
      option.per_instance         = 1;

   endgroup


  virtual function void sample(axi_master_trans t);

this.t=t;
mstr_coverage.sample();

endfunction

function new (string name = "master_collector",uvm_component parent);
   super.new(name,parent);
   mstr_coverage=new();
endfunction : new

  function void write(axi_master_trans t);

    sample(t);

`uvm_info(get_type_name(),$sformatf("master_collector coverage"),UVM_NONE);

endfunction

endclass
