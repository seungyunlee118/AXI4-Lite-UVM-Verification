`ifndef SY_ENV_SV
`define SY_ENV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_env extends uvm_env;

  // UVM Factory Registration
  `uvm_component_utils(sy_env)

  // Sub-components
  sy_agent      agt;  
  sy_scoreboard scb;
  sy_reg_block   regmodel;  // RAL component
  sy_reg_adapter adapter;
  sy_virtual_sequencer v_sqr; // Declare Virtual Sequencer
  sy_subscriber sub; // Declare Subscriber

  // Standard UVM Constructor
  function new(string name = "sy_env", uvm_component parent);
    super.new(name, parent);
  endfunction


  // ---------------------------------------------------------
  // Build Phase: Create the Agent and Scoreboard
  // ---------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agt = sy_agent::type_id::create("agt", this);
    scb = sy_scoreboard::type_id::create("scb", this);

    // Create RAL Component
    regmodel = sy_reg_block::type_id::create("regmodel");
    regmodel.build();  
    // Manually call build() to construct the register model before connecting it to the sequencer
    adapter = sy_reg_adapter::type_id::create("adapter");

    // Create Virtual Sequencer
    v_sqr = sy_virtual_sequencer::type_id::create("v_sqr", this);
    
    // Create Subscriber
    sub = sy_subscriber::type_id::create("sub", this);
  endfunction


  // ---------------------------------------------------------
  // Connect Phase: Link the Monitor to the Scoreboard
  // ---------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect Agent's Monitor port to Scoreboard's implementation port
    agt.mon.item_collected_port.connect(scb.item_collected_export);

    // 3. RAL Connections
    regmodel.default_map.set_sequencer(agt.sqr, adapter);
    regmodel.default_map.set_auto_predict(1); // 
    
    // Monitor sends data to Subscriber (One-to-Many broadcasting)
    agt.mon.item_collected_port.connect(sub.analysis_export);

    // Connect Physical Sequencer and RAL to Virtual Sequencer
    v_sqr.axi_sqr = agt.sqr;
    v_sqr.regmodel = regmodel;
  endfunction

endclass

`endif