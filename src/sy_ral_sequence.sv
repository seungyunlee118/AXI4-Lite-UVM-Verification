`ifndef SY_RAL_SEQUENCE_SV
`define SY_RAL_SEQUENCE_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_ral_sequence extends uvm_sequence;
  `uvm_object_utils(sy_ral_sequence)
  
  sy_reg_block regmodel; 

  function new(string name="sy_ral_sequence");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t data;

    `uvm_info("RAL_SEQ", "Starting RAL Sequence...", UVM_LOW)

    // 1. Write to CTRL_REG (Address 0x00)
    //regmodel.ctrl_reg.write(status, 32'h0000_0001, UVM_FRONTDOOR);
    //`uvm_info("RAL_SEQ", "Wrote 1 to CTRL_REG via RAL", UVM_LOW)

    // 2. Read from STATUS_REG (Address 0x04) 
    //regmodel.status_reg.read(status, data, UVM_FRONTDOOR);
    //`uvm_info("RAL_SEQ", $sformatf("Read Data %h from STATUS_REG via RAL", data), UVM_LOW)

    // 1. Backdoor Write (poke)
    regmodel.ctrl_reg.poke(status, 32'hDEADBEEF);
    `uvm_info("RAL_SEQ", $sformatf("Poked DEADBEEF to CTRL_REG via BACKDOOR"), UVM_LOW)

    // 2. Backdoor Read (peek)
    regmodel.status_reg.peek(status, data);
    `uvm_info("RAL_SEQ", $sformatf("Peeked Data %0h from STATUS_REG via BACKDOOR", data), UVM_LOW)

  endtask
endclass

`endif