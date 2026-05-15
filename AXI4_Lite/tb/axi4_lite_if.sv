interface axi4_lite_if(input logic clk, input logic rst_n);

  // Write Address Channel Signals
  logic [31:0] awaddr;
  logic [2:0]  awprot;
  logic        awvalid;
  logic        awready;

  // Write Data Channel Signals
  logic [31:0] wdata;
  logic [3:0]  wstrb;
  logic        wvalid;
  logic        wready;

  // Write Response Channel Signals
  logic [1:0]  bresp;
  logic        bvalid;
  logic        bready;

  // Read Address Channel Signals
  logic [31:0] araddr;
  logic [2:0]  arprot;
  logic        arvalid;
  logic        arready;

  // Read Data Channel Signals
  logic [31:0] rdata;
  logic [1:0]  rresp;
  logic        rvalid;
  logic        rready;

  // Define modports for Master and Slave connection
  modport master_mp (
    output awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready, araddr, arprot, arvalid, rready,
    input  awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
  );

  modport slave_mp (
    input  awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready, araddr, arprot, arvalid, rready,
    output awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
  );

  
  //----------------------------------------------------
  //         SVA(SystemVerilog Assertion)
  //----------------------------------------------------

  // 1. Reset Checks during reset, all VALID signals must be deasserted (0) --- IGNORE ---
  property p_reset_awvalid; @(posedge clk) (!rst_n) |-> (awvalid == 1'b0); endproperty
  property p_reset_wvalid;  @(posedge clk) (!rst_n) |-> (wvalid == 1'b0);  endproperty
  property p_reset_arvalid; @(posedge clk) (!rst_n) |-> (arvalid == 1'b0); endproperty

  assert_reset_awvalid: assert property(p_reset_awvalid) else $error("SVA FATAL: AWVALID is not 0 during reset!");
  assert_reset_wvalid:  assert property(p_reset_wvalid)  else $error("SVA FATAL: WVALID is not 0 during reset!");
  assert_reset_arvalid: assert property(p_reset_arvalid) else $error("SVA FATAL: ARVALID is not 0 during reset!");

  // 2. Handshake Hold Rules never drop VALID before handshake completes (READY=1) --- IGNORE ---
  property p_awvalid_hold; @(posedge clk) disable iff (!rst_n) (awvalid && !awready) |=> (awvalid); endproperty
  property p_wvalid_hold;  @(posedge clk) disable iff (!rst_n) (wvalid && !wready)   |=> (wvalid);  endproperty
  property p_arvalid_hold; @(posedge clk) disable iff (!rst_n) (arvalid && !arready) |=> (arvalid); endproperty

  assert_awvalid_hold: assert property(p_awvalid_hold) else $error("SVA FATAL: AWVALID dropped before AWREADY!");
  assert_wvalid_hold:  assert property(p_wvalid_hold)  else $error("SVA FATAL: WVALID dropped before WREADY!");
  assert_arvalid_hold: assert property(p_arvalid_hold) else $error("SVA FATAL: ARVALID dropped before ARREADY!");

  // 3. Payload Stability Rules never change address/data while waiting for handshake --- IGNORE ---
  property p_awaddr_stable; @(posedge clk) disable iff (!rst_n) (awvalid && !awready) |=> $stable(awaddr);endproperty
  property p_wdata_stable;  @(posedge clk) disable iff (!rst_n) (wvalid && !wready)   |=> $stable(wdata);  endproperty
  property p_araddr_stable; @(posedge clk) disable iff (!rst_n) (arvalid && !arready) |=> $stable(araddr); endproperty

  assert_awaddr_stable: assert property(p_awaddr_stable) else $error("SVA FATAL: AWADDR changed while waiting!");
  assert_wdata_stable:  assert property(p_wdata_stable)  else $error("SVA FATAL: WDATA changed while waiting!");
  assert_araddr_stable: assert property(p_araddr_stable) else $error("SVA FATAL: ARADDR changed while waiting!");

  // 4. Unknown(X/Z) State Check VALID and READY signals should never be in an unknown state --- IGNORE ---
  property p_no_xz_valid_ready;
    @(posedge clk) disable iff (!rst_n) // activate only when not in reset
    !$isunknown({awvalid, awready, wvalid, wready, arvalid, arready}); 
  endproperty

  assert_no_xz_valid_ready: assert property(p_no_xz_valid_ready) 
    else $error("SVA FATAL: Control signals contain X or Z!");
endinterface