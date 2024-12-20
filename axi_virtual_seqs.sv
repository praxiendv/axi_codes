class axi_vbase_seq extends uvm_sequence #(uvm_sequence_item);

        `uvm_object_utils(axi_vbase_seq)
		

        axi_master_sequencer master_seqrh_h[];
   	axi_master_sequencer1 master_seqrh_h1[];
        axi_slave_sequencer slave_seqrh_h[];
		

        axi_virtual_sequencer v_sqrh_h;
		
        axi_master_rand_seq rand_mxtns;
  	axi_master_rand_seq1 rand_mxtns1;
        axi_slave_rand_seq rand_sxtns;
  
        axi_master_fixed_seq  fixed_m_vseq;
  	axi_master_fixed_seq1  fixed_m_vseq1;
	axi_slave_fixed_seq fixed_s_vseq;

	axi_master_inc_seq inc_m_vseq;
  	axi_master_inc_seq1 inc_m_vseq1;
	axi_slave_inc_seq	inc_s_vseq;

	axi_master_wrap_seq	wrap_m_vseq;
  	axi_master_wrap_seq1 wrap_m_vseq1;
	axi_slave_wrap_seq	wrap_s_vseq;
  

        axi_env_config axi_env_cfg_h;


        extern function new(string name = "axi_vbase_seq");
        extern task body();
endclass : axi_vbase_seq

function axi_vbase_seq::new(string name ="axi_vbase_seq");
        super.new(name);
endfunction



task axi_vbase_seq::body();

        if(!uvm_config_db #(axi_env_config)::get(null,get_full_name(),"axi_env_config",axi_env_cfg_h))
        `uvm_fatal("CONFIG","cannot get() axi_env_cfg_h from uvm_config_db. Have you set() it?")

        master_seqrh_h = new[axi_env_cfg_h.no_of_duts];
  		master_seqrh_h1 = new[axi_env_cfg_h.no_of_duts];
        slave_seqrh_h = new[axi_env_cfg_h.no_of_duts];

  assert($cast(v_sqrh_h,m_sequencer))
  else
        begin
                `uvm_error("BODY", "Error in $cast of virtual sequencer")
        end

        foreach(master_seqrh_h[i])
                master_seqrh_h[i] = v_sqrh_h.master_seqrh_h[i];  
  
  		foreach(master_seqrh_h1[i])
          master_seqrh_h1[i] = v_sqrh_h.master_seqrh_h1[i];  
  
        foreach(slave_seqrh_h[i])
                slave_seqrh_h[i] = v_sqrh_h.slave_seqrh_h[i]; 

endtask: body




class axi_rand_vseq extends axi_vbase_seq;

        `uvm_object_utils(axi_rand_vseq)


        extern function new(string name = "axi_rand_vseq");
        extern task body();
endclass : axi_rand_vseq

function axi_rand_vseq::new(string name ="axi_rand_vseq");
        super.new(name);
endfunction


task axi_rand_vseq::body();
    super.body();

    rand_mxtns= axi_master_rand_seq::type_id::create("rand_mxtns");
  rand_mxtns1= axi_master_rand_seq1::type_id::create("rand_mxtns1");
    rand_sxtns= axi_slave_rand_seq::type_id::create("rand_sxtns");
fork
  begin
    if(axi_env_cfg_h.has_magent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                rand_mxtns.start(master_seqrh_h[i]);
        end
  end
  
    begin
      if(axi_env_cfg_h.has_magent1)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

              rand_mxtns1.start(master_seqrh_h1[i]);
        end
  end
  
 // #0;
  
  //axi_slave_xtn.randmoize() with len==master_seqrh.len;
  begin
    
  if(axi_env_cfg_h.has_sagent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                rand_sxtns.start(slave_seqrh_h[i]);
        end
  end
join
endtask

          


class axi_fixed_vseq extends axi_vbase_seq;

        `uvm_object_utils(axi_fixed_vseq)


        extern function new(string name = "axi_fixed_vseq");
        extern task body();
endclass : axi_fixed_vseq

function axi_fixed_vseq::new(string name ="axi_fixed_vseq");
        super.new(name);
endfunction


task axi_fixed_vseq::body();
    super.body();

    fixed_m_vseq= axi_master_fixed_seq::type_id::create("fixed_m_vseq");
  	fixed_m_vseq1= axi_master_fixed_seq1::type_id::create("fixed_m_vseq1");
    fixed_s_vseq= axi_slave_fixed_seq::type_id::create("fixed_s_vseq");
fork
  begin
  begin
    if(axi_env_cfg_h.has_magent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                fixed_m_vseq.start(master_seqrh_h[i]);
        end
  end
  
  
    begin
      if(axi_env_cfg_h.has_magent1)
          begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

              fixed_m_vseq1.start(master_seqrh_h1[i]);
        end
  end
    
  end
 // #0;
  

  begin
    
    assert( fixed_s_vseq.randomize() with {len==fixed_m_vseq.len;} );
     
    `uvm_info(get_type_name(),$sformatf("++++++++++++++fixed_m_vseq.len=%d ++++++++++++++",fixed_m_vseq.len),UVM_LOW);
    `uvm_info(get_type_name(),$sformatf("++++++++++++++fixed_s_vseq.len=%d ++++++++++++++",fixed_s_vseq.len),UVM_LOW);
    
  if(axi_env_cfg_h.has_sagent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                fixed_s_vseq.start(slave_seqrh_h[i]);
        end
  end
join
endtask
          
          
class axi_inc_vseq extends axi_vbase_seq;

        `uvm_object_utils(axi_inc_vseq)


        extern function new(string name = "axi_inc_vseq");
        extern task body();
endclass : axi_inc_vseq

function axi_inc_vseq::new(string name ="axi_inc_vseq");
        super.new(name);
endfunction


task axi_inc_vseq::body();
    super.body();

    inc_m_vseq= axi_master_inc_seq::type_id::create("inc_m_vseq");
  inc_m_vseq1= axi_master_inc_seq1::type_id::create("inc_m_vseq1");
    inc_s_vseq= axi_slave_inc_seq::type_id::create("inc_s_vseq");
fork
  begin
    if(axi_env_cfg_h.has_magent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                inc_m_vseq.start(master_seqrh_h[i]);
        end
  end
  
  
    begin
      if(axi_env_cfg_h.has_magent1)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

              inc_m_vseq1.start(master_seqrh_h1[i]);
        end
  end
 // #0;
  
  //axi_slave_xtn.randmoize() with len==master_seqrh.len;
  begin
  if(axi_env_cfg_h.has_sagent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                inc_s_vseq.start(slave_seqrh_h[i]);
        end
  end
join
endtask
          
          


class axi_wrap_vseq extends axi_vbase_seq;

        `uvm_object_utils(axi_wrap_vseq)


        extern function new(string name = "axi_wrap_vseq");
        extern task body();
endclass : axi_wrap_vseq

function axi_wrap_vseq::new(string name ="axi_wrap_vseq");
        super.new(name);
endfunction


task axi_wrap_vseq::body();
    super.body();

    wrap_m_vseq= axi_master_wrap_seq::type_id::create("wrap_m_vseq");
  	wrap_m_vseq1= axi_master_wrap_seq1::type_id::create("wrap_m_vseq1");
    wrap_s_vseq= axi_slave_wrap_seq::type_id::create("wrap_s_vseq");
fork
  begin
    if(axi_env_cfg_h.has_magent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                wrap_m_vseq.start(master_seqrh_h[i]);
        end
  end
  
  
    begin
      if(axi_env_cfg_h.has_magent1)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

              wrap_m_vseq1.start(master_seqrh_h1[i]);
        end
  end
 // #0;
  
  //axi_slave_xtn.randmoize() with len==master_seqrh.len;
  begin
  if(axi_env_cfg_h.has_sagent)
                begin
            for (int i=0 ; i < axi_env_cfg_h.no_of_duts; i++)

                wrap_s_vseq.start(slave_seqrh_h[i]);
        end
  end
join
endtask
