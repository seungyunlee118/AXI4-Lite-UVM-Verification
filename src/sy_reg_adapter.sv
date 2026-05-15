`ifndef SY_REG_ADAPTER_SV
`define SY_REG_ADAPTER_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(sy_reg_adapter)

  function new(string name = "sy_reg_adapter");
    super.new(name);
    supports_byte_enable = 0; 
    provides_responses = 0;   
  endfunction

  // 1. RAL -> bus transaction 
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    sy_transaction tx;
    tx = sy_transaction::type_id::create("tx");
    tx.addr = rw.addr; // coppy address from RAL to bus transaction
    
    if (rw.kind == UVM_WRITE) begin
      tx.trans_kind = WRITE; 
      tx.data = rw.data; 
    end else begin
      tx.trans_kind = READ;
    end
    
    return tx;
  endfunction

  // 2. Bus transaction -> RAL
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    sy_transaction tx;
    
    // check if the incoming bus_item is of type sy_transaction
    if (!$cast(tx, bus_item)) begin
      `uvm_fatal("ADAPTER", "Provided bus_item is not of the correct type sy_transaction")
    end
    
    // deliver the response back to RAL (assuming all transactions are successful)
    rw.addr = tx.addr;
    rw.data = tx.data;
    rw.kind = (tx.trans_kind == WRITE) ? UVM_WRITE : UVM_READ;
    rw.status = UVM_IS_OK; 
  endfunction

endclass

`endif