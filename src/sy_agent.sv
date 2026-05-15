`ifndef SY_AGENT_SV
`define SY_AGENT_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_agent extends uvm_agent;

  // UVM Factory Registration
  `uvm_component_utils(sy_agent)

  uvm_sequencer #(sy_transaction) sqr;
  sy_driver  drv;
  sy_monitor mon;

  // Standard UVM Constructor
  function new(string name = "sy_agent", uvm_component parent);
    super.new(name, parent);
  endfunction


  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = sy_monitor::type_id::create("mon", this);
    
    // ACTIVE mode  : Driver and Sequencer are created and connected
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = uvm_sequencer#(sy_transaction)::type_id::create("sqr", this);
      drv = sy_driver::type_id::create("drv", this);
    end
  endfunction



  // Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (get_is_active() == UVM_ACTIVE) begin
      // Connecting Driver's port to Sequencer's export
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction

endclass

`endif