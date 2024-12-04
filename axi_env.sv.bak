class axi_env extends uvm_env;

        `uvm_component_utils(axi_env)


        //agent top
		
        axi_master_agt_top master_agt_top_h[];
  		axi_master_agt_top1 master_agt_top_h1[];
        axi_slave_agt_top slave_agt_top_h[];
  
		
        // virtual_sequencer as  axi_v_sequencer_h
        axi_virtual_sequencer axi_v_sequencer_h;
		
        //   scoreboard
        axi_SB axi_sb_h[];
		
		//coverage collector
		
		master_collector m_collector_h[];
  		master_collector1 m_collector_h1[];
 		slave_collector	s_collector_h[];
		
        // env configuration
    axi_env_config axi_env_cfg_h;

        extern function new(string name = "axi_env", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
		extern function void end_of_elaboration_phase(uvm_phase phase);

endclass: axi_env



function axi_env::new(string name = "axi_env", uvm_component parent);
        super.new(name,parent);
endfunction



function void axi_env::build_phase(uvm_phase phase);

    super.build_phase(phase);
		
        if(!uvm_config_db #(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg_h))
                `uvm_fatal("CONFIG","cannot get() axi_env_cfg_h from uvm_config_db. Have you set() it?")
				
    if(axi_env_cfg_h.has_magent)
                begin
                     
                        master_agt_top_h = new[axi_env_cfg_h.no_of_duts];
                    
                        foreach(master_agt_top_h[i])
                                begin

                                        uvm_config_db #(axi_master_agent_config)::set(this,$sformatf("master_agt_top_h[%0d]*",i),  "axi_master_agent_config", axi_env_cfg_h.m_agent_cfg_h[i]);
										
                                        master_agt_top_h[i]=axi_master_agt_top::type_id::create($sformatf("master_agt_top_h[%0d]",i) ,this);
				end
		end


    if(axi_env_cfg_h.has_magent1)
                begin
                     
                        master_agt_top_h1 = new[axi_env_cfg_h.no_of_duts];
                    
                        foreach(master_agt_top_h1[i])
                                begin

                                        uvm_config_db #(axi_master_agent_config1)::set(this,$sformatf("master_agt_top_h1[%0d]*",i),  "axi_master_agent_config1", axi_env_cfg_h.m_agent_cfg_h1[i]);
										
                                  master_agt_top_h1[i]=axi_master_agt_top1::type_id::create($sformatf("master_agt_top_h1[%0d]",i) ,this);
				end
		end



    if(axi_env_cfg_h.has_sagent == 1)
                begin
                     
            slave_agt_top_h = new[axi_env_cfg_h.no_of_duts];
                       
            foreach(slave_agt_top_h[i])
                                begin

                                        uvm_config_db #(axi_slave_agent_config)::set(this,$sformatf("slave_agt_top_h[%0d]*",i),  "axi_slave_agent_config", axi_env_cfg_h.s_agent_cfg_h[i]);

                                        slave_agt_top_h[i]=axi_slave_agt_top::type_id::create($sformatf("slave_agt_top_h[%0d]", i),this);
                                end
        end


	

                // need to Create axi_v_sequencer_h
				
             if(axi_env_cfg_h.has_virtual_sequencer)
            axi_v_sequencer_h=axi_virtual_sequencer::type_id::create("axi_v_sequencer_h",this);

    if(axi_env_cfg_h.has_scoreboard)
                begin
							axi_sb_h = new[axi_env_cfg_h.no_of_duts];
                       
							foreach (axi_sb_h[i])
									axi_sb_h[i] =axi_SB::type_id::create($sformatf("axi_sb_h[%0d]",i),this);
			end
			
	    if(axi_env_cfg_h.has_mcollector)
                begin
							m_collector_h = new[axi_env_cfg_h.no_of_duts];
                       
							foreach (m_collector_h[i])
									m_collector_h[i] =master_collector::type_id::create($sformatf("m_collector_h[%0d]",i),this);
			end	

	    if(axi_env_cfg_h.has_mcollector1)
                begin
							m_collector_h1= new[axi_env_cfg_h.no_of_duts];
                       
							foreach (m_collector_h1[i])
                              m_collector_h1[i] =master_collector1::type_id::create($sformatf("m_collector_h1[%0d]",i),this);
			end	

			
			
	 if(axi_env_cfg_h.has_scollector)
                begin
							s_collector_h = new[axi_env_cfg_h.no_of_duts];
                       
							foreach (s_collector_h[i])
									s_collector_h[i] =slave_collector::type_id::create($sformatf("s_collector_h[%0d]",i),this);
			end	
			
			
			
endfunction



function void axi_env::connect_phase(uvm_phase phase);

        if(axi_env_cfg_h.has_scoreboard)
                begin
                foreach(master_agt_top_h[i])
                               master_agt_top_h[i].axi_m_agnt_h.axi_m_mon_h.monitor_port.connect(axi_sb_h[i].fifo_master.analysis_export);
				

				foreach(master_agt_top_h1[i])
                               master_agt_top_h1[i].axi_m_agnt_h.axi_m_mon_h.monitor_port.connect(axi_sb_h[i].fifo_master1.analysis_export);
							   
                foreach(slave_agt_top_h[i])
                                slave_agt_top_h[i].axi_s_agt_t_h.axi_s_mon_h.monitor_port.connect(axi_sb_h[i].fifo_slave.analysis_export);
                end
		
        if(axi_env_cfg_h.has_mcollector)
                begin
                foreach(master_agt_top_h[i])
                               master_agt_top_h[i].axi_m_agnt_h.axi_m_mon_h.monitor_port.connect(m_collector_h[i].analysis_export);
                end		
				
		        if(axi_env_cfg_h.has_mcollector1)
                begin
                foreach(master_agt_top_h1[i])
                               master_agt_top_h1[i].axi_m_agnt_h.axi_m_mon_h.monitor_port.connect(m_collector_h1[i].analysis_export);
                end	
				
  if(axi_env_cfg_h.has_scollector)
                begin
                foreach(master_agt_top_h[i])
                                slave_agt_top_h[i].axi_s_agt_t_h.axi_s_mon_h.monitor_port.connect(s_collector_h[i].analysis_export);
                end		
				
endfunction


function void axi_env::end_of_elaboration_phase(uvm_phase phase);


    if(axi_env_cfg_h.has_virtual_sequencer)
                begin
            if(axi_env_cfg_h.has_magent)
                                foreach(master_agt_top_h[i])
                                        begin
                                                        axi_v_sequencer_h.master_seqrh_h[i] = master_agt_top_h[i].axi_m_agnt_h.axi_m_seqr_h;
                                        end

            if(axi_env_cfg_h.has_magent1)
                                foreach(master_agt_top_h1[i])
                                        begin
                                                        axi_v_sequencer_h.master_seqrh_h1[i] = master_agt_top_h1[i].axi_m_agnt_h.axi_m_seqr_h;
                                        end

                        if(axi_env_cfg_h.has_sagent)
                                begin
                                        foreach(slave_agt_top_h[i])
                                                axi_v_sequencer_h.slave_seqrh_h[i] = slave_agt_top_h[i].axi_s_agt_t_h.axi_s_seqrh_h;
                                end
               end
endfunction
