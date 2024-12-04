`include "axi_env.sv"
class axi_test extends uvm_test;

        `uvm_component_utils(axi_test)

    axi_env axi_env_h;
    axi_env_config axi_env_cfg_h;
  	axi_env_config_seq axi_env_cfg_seq_h;
    axi_master_agent_config m_agt_cfg_h[];
	 axi_master_agent_config1 m_agt_cfg_h1[];
    axi_slave_agent_config s_agt_cfg_h[];

  	// no of dut 
    int no_of_duts = 1;
  
  	//create the agent
    int has_magent = 1;
	int has_magent1= 1;
    int has_sagent = 1;
  
  	//enable the coverage collector
    bit has_mcollector=0;
	bit has_mcollector1=0;
 	bit has_scollector=0;
  
  	// no of sequence u want run
 	int no_seq_xtn=4;
  
  	//WRITE-0,READ-1,WRITE_READ-2 Operation
  bit [1:0] write_read_flag=0;
  
  
   //WRITE-0,READ-1,WRITE_READ-2 Operation master 1
  bit [1:0] write_read_flag1=1;
  
  //write out of response & write interleav  
    	int write_interleave=0;
  		int write_out_order_resp=0;
  
    //read out of response & read interleav  
   		int read_interleave=0;
  		int read_out_order_resp=0;

        extern function new(string name = "axi_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void config_axi();
endclass


function axi_test::new(string name = "axi_test" , uvm_component parent);
        super.new(name,parent);
endfunction


function void axi_test::config_axi();
        if (has_magent)
                begin
                        
                        m_agt_cfg_h = new[no_of_duts];

                foreach(m_agt_cfg_h[i])
                                begin
                                      
                                        m_agt_cfg_h[i]=axi_master_agent_config::type_id::create($sformatf("m_agt_cfg_h[%0d]", i));
										
                                        if(!uvm_config_db #(virtual axi_interface)::get(this,"", $sformatf("vif_%0d",i),m_agt_cfg_h[i].axi_m_agt_cfg_vif))
                                        `uvm_fatal("VIF CONFIG","cannot get()interface axi_m_agt_cfg_vif from uvm_config_db. Have you set() it?")
										
                                          m_agt_cfg_h[i].write_read_flag =write_read_flag;
                                 		 m_agt_cfg_h[i].is_active = UVM_ACTIVE;
                                  
                                  		m_agt_cfg_h[i].m_write_interleave = write_interleave ;
                                 		m_agt_cfg_h[i].m_write_out_order_resp = write_out_order_resp;
                                  
                                        m_agt_cfg_h[i].m_read_interleave = read_interleave ;
                                 		m_agt_cfg_h[i].m_read_out_order_resp = read_out_order_resp;
                                  		

                                        axi_env_cfg_h.m_agent_cfg_h[i] = m_agt_cfg_h[i]; 

                end
        end

        if (has_magent1)
                begin
                        
                        m_agt_cfg_h1 = new[no_of_duts];

                foreach(m_agt_cfg_h1[i])
                                begin
                                      
                                  m_agt_cfg_h1[i]=axi_master_agent_config1::type_id::create($sformatf("m_agt_cfg_h1[%0d]", i));
										
                                        if(!uvm_config_db #(virtual axi_interface)::get(this,"", $sformatf("vif_%0d",i),m_agt_cfg_h1[i].axi_m_agt_cfg_vif))
                                        `uvm_fatal("VIF CONFIG","cannot get()interface axi_m_agt_cfg_vif from uvm_config_db. Have you set() it?")
										
                                          m_agt_cfg_h1[i].write_read_flag =write_read_flag1;
                                 		 m_agt_cfg_h1[i].is_active = UVM_ACTIVE;
                                  
                                  		m_agt_cfg_h1[i].m_write_interleave = write_interleave ;
                                 		m_agt_cfg_h1[i].m_write_out_order_resp = write_out_order_resp;
                                  
                                        m_agt_cfg_h1[i].m_read_interleave = read_interleave ;
                                 		m_agt_cfg_h1[i].m_read_out_order_resp = read_out_order_resp;
                                  		

                                        axi_env_cfg_h.m_agent_cfg_h1[i] = m_agt_cfg_h1[i]; 

                end
        end
     
    if (has_sagent)
                begin

            s_agt_cfg_h = new[no_of_duts];

                        foreach(s_agt_cfg_h[i])
                                begin

                                        s_agt_cfg_h[i]=axi_slave_agent_config::type_id::create($sformatf("s_agt_cfg_h[%0d]", i));


                                        if(!uvm_config_db #(virtual axi_interface)::get(this,"", $sformatf("vif_%0d",i),s_agt_cfg_h[i].axi_s_agt_cfg_vif))
                                        `uvm_fatal("VIF CONFIG","cannot get()interface axi_s_agt_cfg_vif from uvm_config_db. Have you set() it?")
										
                                          s_agt_cfg_h[i].write_read_flag =write_read_flag;
                                  		  s_agt_cfg_h[i].is_active = UVM_ACTIVE;
                                  
                                   		s_agt_cfg_h[i].s_write_interleave = write_interleave ;
                                 		s_agt_cfg_h[i].s_write_out_order_resp = write_out_order_resp;

                                   		s_agt_cfg_h[i].s_read_interleave = read_interleave ;
                                 		s_agt_cfg_h[i].s_read_out_order_resp = read_out_order_resp;
                                  
                                        axi_env_cfg_h.s_agent_cfg_h[i] = s_agt_cfg_h[i];

                end
        end
				axi_env_cfg_seq_h.no_seq_xtn=no_seq_xtn;
				axi_env_cfg_h.no_of_duts = no_of_duts;
				axi_env_cfg_h.has_magent = has_magent;
				axi_env_cfg_h.has_magent1 = has_magent1;
				axi_env_cfg_h.has_sagent = has_sagent;
				axi_env_cfg_h.write_read_flag=write_read_flag;
  
  				axi_env_cfg_h.has_mcollector= has_mcollector;
				axi_env_cfg_h.has_mcollector1= has_mcollector1;
  				axi_env_cfg_h.has_scollector= has_scollector;
                axi_env_cfg_h.has_scoreboard= 0;

endfunction : config_axi


//-----------------  build() phase method  -------------------//

function void axi_test::build_phase(uvm_phase phase);
    super.build();

        axi_env_cfg_h=axi_env_config::type_id::create("axi_env_cfg_h");
  		axi_env_cfg_seq_h=axi_env_config_seq::type_id::create("axi_env_cfg_seq_h");
		
    if(has_magent)
        axi_env_cfg_h.m_agent_cfg_h = new[no_of_duts];
		
	if(has_magent1)
        axi_env_cfg_h.m_agent_cfg_h1 = new[no_of_duts];
		
    if(has_sagent)
        axi_env_cfg_h.s_agent_cfg_h = new[no_of_duts];
		
    	//configure the axir vip
		config_axi();
        
        uvm_config_db #(axi_env_config)::set(this,"*","axi_env_config",axi_env_cfg_h);
  		uvm_config_db #(axi_env_config_seq)::set(null,"uvm_test_top.*",  "axi_env_config_seq", axi_env_cfg_seq_h);
        
        axi_env_h=axi_env::type_id::create("axi_env_h", this);
  
endfunction




class first_axi_test extends axi_test;


        `uvm_component_utils(first_axi_test)

        // Declare the handle for  axi_rand_vseq virtual sequence
    axi_rand_vseq axi_seqh;

        extern function new(string name = "first_axi_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass


function first_axi_test::new(string name = "first_axi_test" , uvm_component parent);
        super.new(name,parent);
endfunction



function void first_axi_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction


task first_axi_test::run_phase(uvm_phase phase);

    phase.raise_objection(this);

   axi_seqh=axi_rand_vseq::type_id::create("axi_seqh");
  
    axi_seqh.start(axi_env_h.axi_v_sequencer_h);   
 #500;
    phase.drop_objection(this);
endtask

          
class fixed_axi_test extends axi_test;


        `uvm_component_utils(fixed_axi_test)

        // Declare the handle for  axi_rand_vseq virtual sequence
    axi_fixed_vseq axi_fixed_vseq_h;

        extern function new(string name = "fixed_axi_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass


function fixed_axi_test::new(string name = "fixed_axi_test" , uvm_component parent);
        super.new(name,parent);
endfunction



function void fixed_axi_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction


task fixed_axi_test::run_phase(uvm_phase phase);

    phase.raise_objection(this);

   axi_fixed_vseq_h=axi_fixed_vseq::type_id::create("axi_fixed_seq_h");
  
    axi_fixed_vseq_h.start(axi_env_h.axi_v_sequencer_h);   
 #100;
    phase.drop_objection(this);
endtask          

class Inc_axi_test extends axi_test;


        `uvm_component_utils(Inc_axi_test)

        // Declare the handle for  axi_rand_vseq virtual sequence
   axi_inc_vseq	axi_inc_vseq_h;

        extern function new(string name = "Inc_axi_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass


function Inc_axi_test::new(string name = "Inc_axi_test" , uvm_component parent);
        super.new(name,parent);
endfunction



function void Inc_axi_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction


task Inc_axi_test::run_phase(uvm_phase phase);

    phase.raise_objection(this);

   axi_inc_vseq_h=axi_inc_vseq::type_id::create("axi_inc_vseq_h");
  
    axi_inc_vseq_h.start(axi_env_h.axi_v_sequencer_h);   
 #200;
    phase.drop_objection(this);
endtask          
          
class wrap_axi_test extends axi_test;


        `uvm_component_utils(wrap_axi_test)

        // Declare the handle for  axi_rand_vseq virtual sequence
    axi_wrap_vseq axi_wrap_vseq_h;

        extern function new(string name = "wrap_axi_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass


function wrap_axi_test::new(string name = "wrap_axi_test" , uvm_component parent);
        super.new(name,parent);
endfunction



function void wrap_axi_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction


task wrap_axi_test::run_phase(uvm_phase phase);

    phase.raise_objection(this);

   axi_wrap_vseq_h=axi_wrap_vseq::type_id::create("axi_wrap_vseq_h");
  
    axi_wrap_vseq_h.start(axi_env_h.axi_v_sequencer_h);   
 #200;
    phase.drop_objection(this);

endtask      
 
         