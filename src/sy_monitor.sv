`ifndef SY_MONITOR_SV
`define SY_MONITOR_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class sy_monitor extends uvm_monitor;

  `uvm_component_utils(sy_monitor)
  virtual axi4_lite_if vif;

  // Analysis Port to send captured transactions to the Scoreboard
  uvm_analysis_port #(sy_transaction) item_collected_port;

  function new(string name = "sy_monitor", uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  // ---------------------------------------------------------
  //                       Build Phase
  // ---------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(virtual axi4_lite_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON", "Could not get virtual interface!")
    end
  endfunction

  // ---------------------------------------------------------
  //                       Run Phase
  // ---------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      fork
        collect_write_tx();
        collect_read_tx();
      join
    end
  endtask


  // ---------------------------------------------------------
  //                    collect_write_tx
  // ---------------------------------------------------------
  task collect_write_tx();
    sy_transaction tx;
    
    forever begin 
      tx = sy_transaction::type_id::create("tx");
      tx.trans_kind = WRITE;

      fork
        begin
          do begin
            @(posedge vif.clk);
          end while (!(vif.awvalid && vif.awready));
          
          tx.addr = vif.awaddr;
        end

        begin
          do begin
            @(posedge vif.clk);
          end while (!(vif.wvalid && vif.wready));
          tx.data = vif.wdata;
        end
      join

      // Wait for Write Response (B channel) handshake
      do begin
        @(posedge vif.clk);
      end while (!(vif.bvalid && vif.bready));
      
      // Capture the response status from the bus
      tx.resp = vif.bresp; 
      
      item_collected_port.write(tx);
      `uvm_info("MON", $sformatf("Captured WRITE: Addr=%h, Data=%h, Resp=%b", tx.addr, tx.data, tx.resp), UVM_LOW)
    end
  endtask


  // ---------------------------------------------------------
  //                   collect_read_tx
  // ---------------------------------------------------------
 task collect_read_tx();
    sy_transaction tx;

    forever begin 
      tx = sy_transaction::type_id::create("tx");
      tx.trans_kind = READ;

      // Wait for Read Address (AR channel) handshake
      do begin
        @(posedge vif.clk);
      end while (!(vif.arvalid && vif.arready));
      tx.addr = vif.araddr;

      // Wait for Read Data & Response (R channel) handshake
      do begin
        @(posedge vif.clk);
      end while (!(vif.rvalid && vif.rready));
      
      tx.data = vif.rdata;
      
      // Capture the response status from the bus
      tx.resp = vif.rresp;

      item_collected_port.write(tx);
      `uvm_info("MON", $sformatf("Captured READ : Addr=%h, Data=%h, Resp=%b", tx.addr, tx.data, tx.resp), UVM_LOW)
    end
  endtask

endclass

`endif