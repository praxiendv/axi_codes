
//Base sequence

class axi_master_seqs_base1 extends uvm_sequence #(axi_master_trans1);

        `uvm_object_utils(axi_master_seqs_base1)
 
      axi_env_config_seq axi_env_cfg_seq_h;
  int no_seq_xtn;
  
    extern function new(string name ="axi_master_seqs_base1");
   

endclass

function axi_master_seqs_base1::new(string name ="axi_master_seqs_base1");
        super.new(name);
            if(!uvm_config_db#(axi_env_config_seq)::get(null, "uvm_test_top.seq", "axi_env_config_seq", axi_env_cfg_seq_h)) 
            `uvm_fatal(get_name(), "config cannot be found in ConfigDB!")
                  
                  no_seq_xtn=axi_env_cfg_seq_h.no_seq_xtn;
endfunction
          



/**************************Rand sequence **********************************/

class axi_master_rand_seq1 extends axi_master_seqs_base1;

  
        `uvm_object_utils(axi_master_rand_seq1)
  
  axi_master_agent_config axi_m_agt_cfg_h;
  
  //int len;
 

    extern function new(string name ="axi_master_rand_seq1");
    extern task body();

endclass

function axi_master_rand_seq1::new(string name = "axi_master_rand_seq1");
        super.new(name);
  

endfunction

task axi_master_rand_seq1::body();
  
  
  repeat(super.no_seq_xtn)  
        begin
        
                req=axi_master_trans1::type_id::create("req");
				
                start_item(req);
         		 assert(req.randomize());
          		//	len=req.AWLEN;
                finish_item(req);
        end
endtask

      
  
/**************************fixed bus sequence **********************************/

class axi_master_fixed_seq1 extends axi_master_seqs_base1;

  
        `uvm_object_utils(axi_master_fixed_seq1)
  

  int len;

    extern function new(string name ="axi_master_fixed_seq1");
      extern task body();

endclass

function axi_master_fixed_seq1::new(string name = "axi_master_fixed_seq1");
        super.new(name);

  
//len=5;
endfunction

        task axi_master_fixed_seq1::body();
  
  
  repeat(super.no_seq_xtn)   
        begin
        
                req=axi_master_trans1::type_id::create("req");
				
                start_item(req);
          assert(req.randomize() with {AWBURST==2'b0;ARBURST==2'b0;/*ARLEN==2'b1;*/});
          			len=5;//req.AWLEN;
                finish_item(req);
        end
endtask
    
  
/**************************inc bus sequence **********************************/

class axi_master_inc_seq1 extends axi_master_seqs_base1;

  
        `uvm_object_utils(axi_master_inc_seq1)
  
     
  
  //int len;

    extern function new(string name ="axi_master_inc_seq1");
    extern task body();

endclass

function axi_master_inc_seq1::new(string name = "axi_master_inc_seq1");
        super.new(name);
endfunction

task axi_master_inc_seq1::body();
  
  
  repeat(super.no_seq_xtn)   
        begin
        
                req=axi_master_trans1::type_id::create("req");
				
                start_item(req);
          assert(req.randomize() with {AWBURST==2'b01;ARBURST==2'b01;});
          			//len=req.AWLEN;
                finish_item(req);
        end
endtask
 
       
/**************************wrap bus sequence **********************************/

class axi_master_wrap_seq1 extends axi_master_seqs_base1;

  
        `uvm_object_utils(axi_master_wrap_seq1)
  
 
  
  //int len;

    extern function new(string name ="axi_master_wrap_seq1");
    extern task body();

endclass

function axi_master_wrap_seq1::new(string name = "axi_master_wrap_seq1");
        super.new(name);
endfunction

task axi_master_wrap_seq1::body();
  
  
  repeat(super.no_seq_xtn)
        begin
        
                req=axi_master_trans1::type_id::create("req");
				
                start_item(req);
          assert(req.randomize() with {AWBURST==2'b10;ARBURST==2'b10;});
          			//len=req.AWLEN;
                finish_item(req);
        end
endtask
    