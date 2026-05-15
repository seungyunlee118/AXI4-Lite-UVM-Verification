`ifndef SY_VSEQ_ERROR_SV
`define SY_VSEQ_ERROR_SV

class sy_vseq_error extends sy_vseq_base;
  `uvm_object_utils(sy_vseq_error)

  function new(string name = "sy_vseq_error");
    super.new(name);
  endfunction

  virtual task body();
    sy_transaction tx;

    `uvm_info("VSEQ_ERR", "Starting Error Injection Scenario...", UVM_LOW)

    // ---------------------------------------------------------
    // 1. Invalid Write Access (Target: 0xFFFF0000)
    // ---------------------------------------------------------
    tx = sy_transaction::type_id::create("tx");
    
    // Send transaction directly to the physical AXI Sequencer
    start_item(tx, -1, axi_sqr); 
    
    tx.trans_kind = WRITE;
    tx.addr       = 32'hFFFF_0000; 
    tx.data       = 32'hDEAD_DEAD;
    
    finish_item(tx);
    `uvm_info("VSEQ_ERR", "Sent Invalid Write Access to Address 0xFFFF0000", UVM_LOW)

    // ---------------------------------------------------------
    // 2. Invalid Read Access (Target: 0xFFFF0000)
    // ---------------------------------------------------------
    // Create a new transaction to avoid data corruption from the previous one
    tx = sy_transaction::type_id::create("tx");
    
    start_item(tx, -1, axi_sqr); 
    
    tx.trans_kind = READ;
    tx.addr       = 32'hFFFF_0000; 
    // Data field is ignored during a Read request, no need to assign
    
    finish_item(tx);
    `uvm_info("VSEQ_ERR", "Sent Invalid Read Access to Address 0xFFFF0000", UVM_LOW)

  endtask
endclass

`endif