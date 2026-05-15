`ifndef SY_SUBSCRIBER_SV
`define SY_SUBSCRIBER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_subscriber extends uvm_subscriber #(sy_transaction);
  `uvm_component_utils(sy_subscriber)

  sy_transaction tx;

  // ---------------------------------------------------------
  // Covergroup Definition (The Checklist)
  // ---------------------------------------------------------
  covergroup cg_axi_bus;
    option.per_instance = 1; // Generate coverage report per instance

    // 1. Coverpoint for Transaction Type (Read or Write)
    cp_kind: coverpoint tx.trans_kind {
      bins read_op  = {READ};
      bins write_op = {WRITE};
    }

    // 2. Coverpoint for Address 
    cp_addr: coverpoint tx.addr {
      bins ctrl_reg     = {'h00};
      bins status_reg   = {'h04};
      bins reg_2        = {'h08}; // Added reg_2
      bins reg_3        = {'h0C}; // Added reg_3
      bins out_of_bound = {['h10 : 32'hFFFF_FFFF]}; // To track Error Injection
    }

    // 3. Cross Coverage
    // Did we perform BOTH Read and Write for EVERY address?
    cross_kind_addr: cross cp_kind, cp_addr;
  endgroup



  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_axi_bus = new(); 
  endfunction



  // ---------------------------------------------------------
  // write() function: Automatically called when Monitor broadcasts data
  // ---------------------------------------------------------
  virtual function void write(sy_transaction t);
    $cast(tx, t.clone()); // Clone to avoid data corruption from concurrent transactions
    cg_axi_bus.sample();  // Sample the covergroup with the new transaction data
  endfunction

  // ---------------------------------------------------------
  // report_phase: output coverage after simulation
  // ---------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    // get_inst_coverage(): calculate coverage percentage
    `uvm_info("COVERAGE", $sformatf("========================================"), UVM_NONE)
    `uvm_info("COVERAGE", $sformatf(" AXI Bus Functional Coverage: %3.2f %%", cg_axi_bus.get_inst_coverage()), UVM_NONE)
    `uvm_info("COVERAGE", $sformatf("========================================"), UVM_NONE)
  endfunction

endclass

`endif