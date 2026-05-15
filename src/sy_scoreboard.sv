`ifndef SY_SCOREBOARD_SV
`define SY_SCOREBOARD_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(sy_scoreboard)
  // Analysis Export to receive data from the Monitor
  uvm_analysis_imp #(sy_transaction, sy_scoreboard) item_collected_export;

  // "Reference Model": An associative array to mimic the Slave's internal registers
  // We use this to store what WE think is inside the DUT
  logic [31:0] ref_memory [logic [31:0]];

  function new(string name = "sy_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
  endfunction

  // ---------------------------------------------------------
  //                         Logic
  // ---------------------------------------------------------
  virtual function void write(sy_transaction tx);
    
    // --- ADDED: Error Response Handling ---
    // Ignore transactions where the RTL responded with an error (e.g., SLVERR = 2'b10)
    if (tx.resp != 2'b00) begin
      `uvm_info("SCB", $sformatf("Ignored Error Transaction: Addr=%h, Resp=%b", tx.addr, tx.resp), UVM_LOW)
      return; // Exit function immediately, do not store or compare data
    end
    // --------------------------------------

    if (tx.trans_kind == WRITE) begin
      // Store the written data into our Reference Model
      ref_memory[tx.addr] = tx.data;
      `uvm_info("SCB", $sformatf("Stored Expected: Addr=%h, Data=%h", tx.addr, tx.data), UVM_LOW)
    end 
    else if (tx.trans_kind == READ) begin
      // Check if the address exists in our Reference Model
      if (ref_memory.exists(tx.addr)) begin
        if (ref_memory[tx.addr] == tx.data) begin
          `uvm_info("SCB", $sformatf("MATCH! Addr=%h, Data=%h", tx.addr, tx.data), UVM_LOW)
        end else begin
          `uvm_error("SCB", $sformatf("MISMATCH! Addr=%h, Exp=%h, Got=%h", 
                     tx.addr, ref_memory[tx.addr], tx.data))
        end
      end else begin
        `uvm_info("SCB", $sformatf("Read from uninitialized address: %h", tx.addr), UVM_LOW)
      end
    end
  endfunction

endclass

`endif