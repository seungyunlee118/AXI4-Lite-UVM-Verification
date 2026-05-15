`ifndef SY_VIRTUAL_SEQUENCER_SV
`define SY_VIRTUAL_SEQUENCER_SV

class sy_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(sy_virtual_sequencer)

  // Handles to physical sequencers and RAL
  uvm_sequencer #(sy_transaction) axi_sqr;
  sy_reg_block regmodel;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass

`endif 