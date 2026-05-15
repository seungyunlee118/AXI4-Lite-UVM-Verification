`ifndef SY_SEQUENCE_SV
`define SY_SEQUENCE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_sequence extends uvm_sequence #(sy_transaction);

  `uvm_object_utils(sy_sequence)
  
  function new(string name = "sy_sequence");
    super.new(name);
  endfunction

  virtual task body();
    sy_transaction req;
    logic [31:0] saved_addr; 
    int num_tx = 50; // repeat 50 times

    `uvm_info("SEQ", $sformatf("Starting Directed-Random Sequence with %0d items...", num_tx), UVM_LOW)

    for (int i = 0; i < num_tx; i++) begin
      // Step 1: Write to a Random Address
      req = sy_transaction::type_id::create("req");
      start_item(req);
      
      if (!req.randomize() with { trans_kind == WRITE; }) begin
        `uvm_fatal("SEQ", "Randomization failed for WRITE")
      end
      
      saved_addr = req.addr; 
      
      `uvm_info("SEQ", $sformatf("[Loop %0d] Directed WRITE: Addr=%h", i, req.addr), UVM_LOW)
      finish_item(req);

      // Step 2: Read from the EXACT SAME Address
      req = sy_transaction::type_id::create("req");
      start_item(req);
      
      if (!req.randomize() with { 
          trans_kind == READ; 
          addr == local::saved_addr; 
      }) begin
        `uvm_fatal("SEQ", "Randomization failed for READ")
      end
      
      `uvm_info("SEQ", $sformatf("[Loop %0d] Directed READ : Addr=%h", i, req.addr), UVM_LOW)
      finish_item(req);
    end

    `uvm_info("SEQ", "Directed-Random Sequence Completed!", UVM_LOW)
  endtask

endclass

`endif