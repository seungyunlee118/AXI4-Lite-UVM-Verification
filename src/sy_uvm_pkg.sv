`ifndef SY_UVM_PKG_SV
`define SY_UVM_PKG_SV

// bottom-up 

package sy_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
// 1. Base Transaction must be compiled first
  `include "sy_transaction.sv"
  
  // 2. RAL Components
  `include "sy_reg_block.sv"
  `include "sy_reg_adapter.sv"
  
  // 3. Sequences (Now they can see sy_transaction)
  `include "sy_sequence.sv"
  `include "sy_ral_sequence.sv"

  // Include new Virtual Sequencer files 
  `include "sy_virtual_sequencer.sv"
  `include "sy_vseq_base.sv"
  `include "sy_vseq_rmw.sv"
  `include "sy_vseq_sweep.sv"
  `include "sy_vseq_error.sv"
  
  // 4. UVM Components (Order matters: Driver/Monitor -> Agent -> Env -> Test)
  `include "sy_driver.sv"
  `include "sy_monitor.sv"
  `include "sy_agent.sv"
  `include "sy_scoreboard.sv"
  `include "sy_subscriber.sv"
  `include "sy_env.sv"
  `include "sy_test.sv"

endpackage

`endif