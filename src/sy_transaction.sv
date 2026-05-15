`ifndef SY_TRANSACTION_SV
`define SY_TRANSACTION_SV

// Import UVM base classes and macros
import uvm_pkg::*;
`include "uvm_macros.svh"

// Enum to distinguish between Read and Write operations
typedef enum {WRITE, READ} sy_trans_type_e;

class sy_transaction extends uvm_sequence_item;

  //---------------------------------------------------
  // CRV(Constrained Random Verification)
  //---------------------------------------------------
  
  // Analysis: These fields represent the "Data Payload" 
  rand logic [31:0] addr;
  rand logic [31:0] data;
  logic [1:0] resp; // To capture bresp or rresp
  rand sy_trans_type_e trans_kind;

  // 1. Word-Aligned Address Constraint
  constraint c_addr_align {
    addr[1:0] == 2'b00; // addr % 4 == 0;
  }

  // 2. Memory Map Boundary Constraint
  constraint c_addr_bound {
    addr inside {[32'h0000_0000 : 32'h0000_00FF]};
  }

  // 3. Transaction Type Distribution Constraint
  constraint c_trans_dist {
    trans_kind dist {WRITE := 50, READ := 50};
  }

  // UVM Automation Macros: Registers the class to the UVM Factory
  `uvm_object_utils_begin(sy_transaction)
    `uvm_field_int(addr,       UVM_ALL_ON)
    `uvm_field_int(data,       UVM_ALL_ON)
    `uvm_field_enum(sy_trans_type_e, trans_kind, UVM_ALL_ON)
  `uvm_object_utils_end

  // Standard UVM Constructor
  function new(string name = "sy_transaction");
    super.new(name);
  endfunction

endclass

`endif