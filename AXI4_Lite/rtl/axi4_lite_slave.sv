module axi4_lite_slave (
  input  logic        clk,
  input  logic        rst_n,

  // Write Address Channel
  input  logic [31:0] awaddr,
  input  logic [2:0]  awprot,
  input  logic        awvalid,
  output logic        awready,

  // Write Data Channel
  input  logic [31:0] wdata,
  input  logic [3:0]  wstrb,
  input  logic        wvalid,
  output logic        wready,

  // Write Response Channel
  output logic [1:0]  bresp,
  output logic        bvalid,
  input  logic        bready,

  // Read Address Channel
  input  logic [31:0] araddr,
  input  logic [2:0]  arprot,
  input  logic        arvalid,
  output logic        arready,

  // Read Data Channel
  output logic [31:0] rdata,
  output logic [1:0]  rresp,
  output logic        rvalid,
  input  logic        rready
);

  // ---------------------------------------------------------
  // Internal Memory Map: 4 Registers (32-bit each)
  // ---------------------------------------------------------
  logic [31:0] slv_reg [0:3];
  
  // Internal signals for handshaking
  logic aw_en;

  // ---------------------------------------------------------
  // 1. Write Address (AW) & Write Data (W) Handshake
  // ---------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      awready <= 1'b0;
      wready  <= 1'b0;
      aw_en   <= 1'b1;
    end else begin
      // Accept AW and W when both VALID signals are high
      if (!awready && awvalid && !wready && wvalid && aw_en) begin
        awready <= 1'b1;
        wready  <= 1'b1;
        aw_en   <= 1'b0;
      end else begin
        awready <= 1'b0;
        wready  <= 1'b0;
      end
      
      // Reset aw_en after a successful write response
      if (bvalid && bready) begin
        aw_en <= 1'b1;
      end
    end
  end

  // ---------------------------------------------------------
  // 2. Write Operation & Write Response (B)
  // ---------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bvalid <= 1'b0;
      bresp  <= 2'b00; // OKAY response
      for (int i = 0; i < 4; i++)
       slv_reg[i] <= 32'h0;
    end else begin
      if (awready && awvalid && wready && wvalid) begin
        int reg_idx;
        reg_idx = awaddr[3:2]; 
        
        //Address Bound Check)
        if (awaddr < 32'h10) begin 
          if (wstrb[0]) slv_reg[reg_idx][7:0]   <= wdata[7:0];
          if (wstrb[1]) slv_reg[reg_idx][15:8]  <= wdata[15:8];
          if (wstrb[2]) slv_reg[reg_idx][23:16] <= wdata[23:16];
          if (wstrb[3]) slv_reg[reg_idx][31:24] <= wdata[31:24];
          bresp <= 2'b00; // OKAY
        end else begin
          // Invalid Address
          bresp <= 2'b10; // SLVERR
        end
       
        bvalid <= 1'b1; 
      end else if (bvalid && bready) begin
        bvalid <= 1'b0; 
      end
    end
  end

  // ---------------------------------------------------------
  // 3. Read Address (AR) Handshake
  // ---------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arready <= 1'b0;
    end else begin
      if (!arready && arvalid) begin
        arready <= 1'b1;
      end else begin
        arready <= 1'b0;
      end
    end
  end

  // ---------------------------------------------------------
  // 4. Read Data (R) Operation
  // ---------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rvalid <= 1'b0;
      rresp  <= 2'b00;
      rdata  <= 32'h0;
    end else begin
      if (arready && arvalid && !rvalid) begin
        int reg_idx;
        reg_idx = araddr[3:2];
        
        //Address Bound Check
        if (araddr < 32'h10) begin
          // Valid Address
          rdata <= slv_reg[reg_idx]; 
          rresp <= 2'b00; // OKAY 
        end else begin
          // Invalid Address
          rdata <= 32'h0;
          rresp <= 2'b10; // SLVERR
        end
     
        rvalid  <= 1'b1; 
      end else if (rvalid && rready) begin
        rvalid <= 1'b0; 
      end
    end
  end

endmodule