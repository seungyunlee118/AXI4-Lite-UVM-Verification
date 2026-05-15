`ifndef SY_TEST_SV
`define SY_TEST_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_test extends uvm_test;
  `uvm_component_utils(sy_test)
  sy_env env;

  function new(string name = "sy_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the env. Note that the Agent and Scoreboard 
    // will be automatically created inside the Env's build_phase.
    env = sy_env::type_id::create("env", this);
  endfunction

  //RAL absolute path 
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    env.regmodel.set_hdl_path_root("tb_top.u_dut");
  endfunction



  virtual task run_phase(uvm_phase phase);
    // Declare the sequence we want to run
    //sy_sequence sy_seq;
    //sy_ral_sequence seq;
    //sy_vseq_rmw vseq; 
    sy_vseq_error vseq_err;
    sy_vseq_sweep vseq_sweep; 

    // Raise Objection: Tell UVM not to end the simulation yet!
    phase.raise_objection(this);
    
    `uvm_info("TEST", "========================================", UVM_NONE)
    `uvm_info("TEST", "Starting Execution of sy_test", UVM_NONE)
    
    // RAW Sequence(sy_sequence) 
    // sy_seq = sy_sequence::type_id::create("sy_seq");
    // `uvm_info("TEST", "Starting sy_sequence...", UVM_NONE)
    // sy_seq.start(env.agt.sqr);

    // RMW(read-modify-write)
    //vseq_rmw = sy_vseq_rmw::type_id::create("vseq_rmw");
    //vseq_rmw.start(env.v_sqr);

    // RAL
    //seq = sy_ral_sequence::type_id::create("seq");
    //seq.regmodel = env.regmodel;
    //seq.start(env.v_sqr);

    // Phase 1: Full Sweep 
    vseq_sweep = sy_vseq_sweep::type_id::create("vseq_sweep");
    vseq_sweep.start(env.v_sqr); 
    
    // Phase 2: Error Injection 
    vseq_err = sy_vseq_error::type_id::create("vseq_err");
    vseq_err.start(env.v_sqr);

    `uvm_info("TEST", "Finished Execution of sy_test", UVM_NONE)
    `uvm_info("TEST", "========================================", UVM_NONE)

    phase.drop_objection(this, "Finished Random Sequence");
  endtask

endclass

`endif