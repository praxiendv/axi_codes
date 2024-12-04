
//Base sequence

class axi_slave_seqs_base extends uvm_sequence #(axi_slave_trans);

        `uvm_object_utils(axi_slave_seqs_base)
  
       axi_env_config_seq axi_env_cfg_seq_h;
  int no_seq_xtn;
  
    extern function new(string name ="axi_slave_seqs_base");

      
endclass

function axi_slave_seqs_base::new(string name ="axi_slave_seqs_base");
        super.new(name);

              if(!uvm_config_db#(axi_env_config_seq)::get(null, "uvm_test_top.seq", "axi_env_config_seq", axi_env_cfg_seq_h)) 
            `uvm_fatal(get_name(), "config cannot be found in ConfigDB!")
                  
                  no_seq_xtn=axi_env_cfg_seq_h.no_seq_xtn;
  
endfunction
      
/**************************Rand sequence **********************************/

class axi_slave_rand_seq extends axi_slave_seqs_base;

        `uvm_object_utils(axi_slave_rand_seq)
  
   // axi_slave_agent_config axi_s_agnt_cfg;
  
  //rand int len;

    extern function new(string name ="axi_slave_rand_seq");
    extern task body();

endclass

function axi_slave_rand_seq::new(string name = "axi_slave_rand_seq");
        super.new(name);
endfunction

task axi_slave_rand_seq::body();
  
  
  repeat(super.no_seq_xtn)  
        begin
                req=axi_slave_trans::type_id::create("req");
				
                start_item(req);
          assert(req.randomize());// with req.len==len);
                finish_item(req);
        end
endtask


class axi_slave_fixed_seq extends axi_slave_seqs_base;

        `uvm_object_utils(axi_slave_fixed_seq)
  
  
  rand int len;

    extern function new(string name ="axi_slave_fixed_seq");
    extern task body();

endclass

function axi_slave_fixed_seq::new(string name = "axi_slave_fixed_seq");
        super.new(name);
endfunction

task axi_slave_fixed_seq::body();
  
  
  repeat(super.no_seq_xtn)   
        begin
                req=axi_slave_trans::type_id::create("req");
				
                start_item(req);
          assert(req.randomize());// with {req.len==len;});
                finish_item(req);
        end
endtask
      


class axi_slave_inc_seq extends axi_slave_seqs_base;

        `uvm_object_utils(axi_slave_inc_seq)
  
  
  //rand int len;

    extern function new(string name ="axi_slave_inc_seq");
    extern task body();

endclass

function axi_slave_inc_seq::new(string name = "axi_slave_inc_seq");
        super.new(name);
endfunction

task axi_slave_inc_seq::body();
  
  
  repeat(super.no_seq_xtn)  
        begin
                req=axi_slave_trans::type_id::create("req");
				
                start_item(req);
          assert(req.randomize());// with req.len==len);
                finish_item(req);
        end
endtask

      

class axi_slave_wrap_seq extends axi_slave_seqs_base;

        `uvm_object_utils(axi_slave_wrap_seq)
  
  
  //rand int len;

    extern function new(string name ="axi_slave_wrap_seq");
    extern task body();

endclass

function axi_slave_wrap_seq::new(string name = "axi_slave_wrap_seq");
        super.new(name);
  
endfunction

task axi_slave_wrap_seq::body();
  
  
  repeat(super.no_seq_xtn)   
        begin
                req=axi_slave_trans::type_id::create("req");
				
                start_item(req);
          assert(req.randomize());// with req.len==len);
                finish_item(req);
        end
endtask
