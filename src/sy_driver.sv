`ifndef SY_DRIVER_SV
`define SY_DRIVER_SV
 import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_driver extends uvm_driver #(sy_transaction);

  `uvm_component_utils(sy_driver)
  virtual axi4_lite_if vif;

  function new(string name = "sy_driver", uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi4_lite_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRV", "Could not get virtual interface!")
    end
  endfunction


  virtual task run_phase(uvm_phase phase);
    vif.awvalid <= 1'b0;
    vif.wvalid  <= 1'b0;
    vif.bready  <= 1'b0;
    vif.arvalid <= 1'b0;
    vif.rready  <= 1'b0;

    // Hardware Reset Synchronization
    `uvm_info("DRV", "Waiting for Hardware Reset to finish...", UVM_NONE)
    wait(vif.rst_n == 1'b1);
    `uvm_info("DRV", "Reset completed! Starting to fetch items.", UVM_NONE)

    forever begin
      seq_item_port.get_next_item(req);
  
      if (req.trans_kind == WRITE) begin
        drive_write(req);
      end else begin
        drive_read(req);
      end

      seq_item_port.item_done();
    end
  endtask


  task drive_write(sy_transaction req);
    `uvm_info("DRV", "Starting AXI Write Transaction", UVM_NONE)

    // Sync with the clock before starting the transaction
    @(posedge vif.clk);

    // 2. AW, W channel 
    vif.awvalid <= 1'b1;
    vif.awaddr  <= req.addr;
    vif.wvalid  <= 1'b1;
    vif.wdata   <= req.data;
    vif.wstrb   <= 4'hF;
    vif.bready  <= 1'b1; 

    // 3. Wait for the next edge so RTL can sample the VALID signals
    @(posedge vif.clk);

    fork
      // Thread 1: AW Channel Handshake
      begin : aw_handshake
        do begin 
          @(posedge vif.clk);
        end while (vif.awready !== 1'b1);
        vif.awvalid <= 1'b0;
      end
      
      // Thread 2: W Channel Handshake
      begin : w_handshake
        do begin
           @(posedge vif.clk);
        end while (vif.wready !== 1'b1);
        vif.wvalid <= 1'b0;
      end
    join

    // B channel 
    while (vif.bvalid !== 1'b1) @(posedge vif.clk);
    vif.bready <= 1'b0;
    `uvm_info("DRV", "Finished AXI Write Transaction", UVM_NONE)
  endtask
 


  task drive_read(sy_transaction tx);
    `uvm_info("DRV", "Starting AXI Read Transaction", UVM_NONE)
    @(posedge vif.clk);
    vif.araddr  <= tx.addr;
    vif.arvalid <= 1'b1;
    vif.rready  <= 1'b1;

    // Wait for AR Handshake
    do begin
      @(posedge vif.clk);
    end while (vif.arready !== 1'b1);
    vif.arvalid <= 1'b0;

    // Wait for R Handshake (Data arrival)
    do begin
      @(posedge vif.clk);
    end while (vif.rvalid !== 1'b1);
    tx.data = vif.rdata;
    vif.rready <= 1'b0;

    `uvm_info("DRV", $sformatf("Read Done: Addr=%h", tx.addr), UVM_LOW)
  endtask

endclass

`endif