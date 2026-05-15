`ifndef SY_VSEQ_BASE_SV
`define SY_VSEQ_BASE_SV

class sy_vseq_base extends uvm_sequence;
  `uvm_object_utils(sy_vseq_base)

  // Magic Macro: Casts m_sequencer to p_sequencer of type sy_virtual_sequencer
  `uvm_declare_p_sequencer(sy_virtual_sequencer)

  // Local handles for convenience
  uvm_sequencer #(sy_transaction) axi_sqr;
  sy_reg_block regmodel;

  function new(string name = "sy_vseq_base");
    super.new(name);
  endfunction

  // Pre-body automatically maps local handles to the Virtual Sequencer's handles
  virtual task pre_body();
    if (p_sequencer == null) begin
      `uvm_fatal("VSEQ_BASE", "Virtual sequencer pointer is null!")
    end
    axi_sqr = p_sequencer.axi_sqr;
    regmodel = p_sequencer.regmodel;
  endtask
endclass

`endif