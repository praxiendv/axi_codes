class slave_collector extends uvm_subscriber #(axi_slave_trans);
   `uvm_component_utils (slave_collector)

   axi_slave_trans t;

   covergroup slv_coverage;
      option.per_instance         = 1;

   endgroup


virtual function void sample(axi_slave_trans t);

this.t=t;
slv_coverage.sample();

endfunction

function new (string name = "slave_collector",uvm_component parent);
   super.new(name,parent);
   slv_coverage=new();
endfunction : new

function void write(axi_slave_trans t);

sample(t);

`uvm_info(get_type_name(),$sformatf("slave_collector coverage"),UVM_NONE);

endfunction

endclass
