`ifndef SY_VSEQ_SWEEP_SV
`define SY_VSEQ_SWEEP_SV

//Full sweep 
class sy_vseq_sweep extends sy_vseq_base;
  `uvm_object_utils(sy_vseq_sweep)

  function new(string name = "sy_vseq_sweep");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t rdata;

    `uvm_info("VSEQ_SWEEP", "Starting Full Sweep Scenario...", UVM_LOW)

    // --- Phase 1: WRITE SWEEP (Iterate through declared registers) ---
    `uvm_info("VSEQ_SWEEP", "--- Phase 1: WRITE SWEEP ---", UVM_LOW)
    regmodel.ctrl_reg.write(status, 32'h1111_1111, UVM_FRONTDOOR, null, this);
    regmodel.status_reg.write(status, 32'h2222_2222, UVM_FRONTDOOR, null, this);
    regmodel.reg_2.write(status, 32'h3333_3333, UVM_FRONTDOOR, null, this);
    regmodel.reg_3.write(status, 32'h4444_4444, UVM_FRONTDOOR, null, this);

    
    // --- Phase 2: READ SWEEP (Iterate through declared registers) ---
    `uvm_info("VSEQ_SWEEP", "--- Phase 2: READ SWEEP ---", UVM_LOW)
    regmodel.ctrl_reg.read(status, rdata, UVM_FRONTDOOR, null, this);
    regmodel.status_reg.read(status, rdata, UVM_FRONTDOOR, null, this);
    regmodel.reg_2.read(status, rdata, UVM_FRONTDOOR, null, this);
    regmodel.reg_3.read(status, rdata, UVM_FRONTDOOR, null, this);
    `uvm_info("VSEQ_SWEEP", "Full Sweep Scenario Completed.", UVM_LOW)
  endtask
endclass

`endif