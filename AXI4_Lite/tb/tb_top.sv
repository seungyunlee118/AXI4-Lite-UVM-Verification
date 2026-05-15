
`timescale 1ns/1ps

// 1. UVM Package Import (Crucial for uvm_config_db to work)
`include "uvm_macros.svh"
import uvm_pkg::*;

// 2. Hardware Interface (Must be outside the package)
`include "axi4_lite_if.sv"

// 3. UVM Environment Package (Ensure extension matches your setup, e.g., .svh or .sv)
`include "sy_uvm_pkg.sv"
import sy_uvm_pkg::*;

module tb_top;

  // ---------------------------------------------------------
  // Clock and Reset Generation
  // ---------------------------------------------------------
  logic clk;
  logic rst_n;

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  // ---------------------------------------------------------
  // Instantiate the Interface
  // ---------------------------------------------------------
  axi4_lite_if vif(clk, rst_n);

  // ---------------------------------------------------------
  // Instantiate the DUT (Design Under Test)
  // ---------------------------------------------------------
  axi4_lite_slave u_dut (
    .clk     (vif.clk),
    .rst_n   (vif.rst_n),
    .awaddr  (vif.awaddr),
    .awvalid (vif.awvalid),
    .awready (vif.awready),
    .wdata   (vif.wdata),
    .wstrb   (vif.wstrb),
    .wvalid  (vif.wvalid),
    .wready  (vif.wready),
    .bresp   (vif.bresp),
    .bvalid  (vif.bvalid),
    .bready  (vif.bready),
    .araddr  (vif.araddr),
    .arvalid (vif.arvalid),
    .arready (vif.arready),
    .rdata   (vif.rdata),
    .rresp   (vif.rresp),
    .rvalid  (vif.rvalid),
    .rready  (vif.rready),
    .arprot  (3'b000), 
    .awprot  (3'b000)
  );

  // ---------------------------------------------------------
  // Dump Waveforms
  // ---------------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end
  
  // ---------------------------------------------------------
  // UVM Heartbeat: Config DB and Run Test
  // ---------------------------------------------------------
  initial begin
    // Pass the physical interface to the UVM world
    uvm_config_db#(virtual axi4_lite_if)::set(null, "*", "vif", vif);

    // Start the UVM test execution
    run_test("sy_test");
  end

endmodule