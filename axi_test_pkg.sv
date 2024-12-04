// Code your design here

`include "uvm_macros.svh"
package axi_test_pkg;

	import uvm_pkg::*;
        `include "axi_master_trans.sv"
		`include "axi_master_trans1.sv"
        `include "axi_master_agent_config.sv"
		`include "axi_master_agent_config1.sv"
        `include "axi_slave_agent_config.sv"
        `include "axi_env_config.sv"
        `include "master_driver.sv"
		`include "master_driver1.sv"
        `include "master_monitor1.2.sv"
		`include "master_monitor1.sv"
        `include "axi_master_sequencer.sv"
		`include "axi_master_sequencer1.sv"
        `include "axi_master_agent.sv"
		`include "axi_master_agent1.sv"
        `include "axi_master_agent_top.sv"
		`include "axi_master_agent_top1.sv"
        `include "axi_master_seqs.sv"
		`include "axi_master_seqs1.sv"

        `include "axi_slave_trans.sv"
        `include "slave_monitor.sv"
        `include "axi_slave_sequencer.sv"
        `include "axi_slave_seqs.sv"
        `include "slave_driver.sv"
        `include "axi_slave_agent.sv"
        `include "axi_slave_agent_top.sv"

		`include "master_collector.sv"
		`include "master_collector1.sv"
		`include "slave_collector.sv"

       `include "axi_virtual_sequencer.sv"
        `include "axi_virtual_seqs.sv"
        `include "axi_SB.sv"

        `include "axi_env.sv"

        `include "axi_test.sv"
endpackage	