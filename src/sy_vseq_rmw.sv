`ifndef SY_VSEQ_RMW_SV
`define SY_VSEQ_RMW_SV
// Read-Modify-Write senario
class sy_vseq_rmw extends sy_vseq_base;
  `uvm_object_utils(sy_vseq_rmw)

  function new(string name = "sy_vseq_rmw");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t rdata;
    uvm_reg_data_t modified_data;

    `uvm_info("VSEQ_RMW", "Starting Read-Modify-Write Scenario...", UVM_LOW)

    // Step 1: Read the current value of CTRL_REG via Frontdoor
    // This creates an AXI Read transaction (AR and R channels)
    regmodel.ctrl_reg.read(status, rdata, UVM_FRONTDOOR, null, this);
    `uvm_info("VSEQ_RMW", $sformatf("Step 1: Read Initial Data = 'h%0h", rdata), UVM_LOW)

    // Step 2: Modify the data
    // Example: Keep original bits, but forcefully set bit [0] and bit [4] to 1
    modified_data = rdata | 32'h0000_0011;
    `uvm_info("VSEQ_RMW", $sformatf("Step 2: Modified Data = 'h%0h", modified_data), UVM_LOW)

    // Step 3: Write the modified data back immediately via Frontdoor
    // This creates an AXI Write transaction (AW, W, and B channels) back-to-back
    regmodel.ctrl_reg.write(status, modified_data, UVM_FRONTDOOR, null, this);
    `uvm_info("VSEQ_RMW", "Step 3: Wrote Modified Data back to CTRL_REG", UVM_LOW)

  endtask
endclass

`endif 