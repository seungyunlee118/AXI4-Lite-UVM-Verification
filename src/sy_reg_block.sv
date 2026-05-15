`ifndef SY_REG_BLOCK_SV
`define SY_REG_BLOCK_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

// ==========================================================
// 1. CTRL_REG (Address: 0x00)
// ==========================================================
class sy_ctrl_reg extends uvm_reg;
  `uvm_object_utils(sy_ctrl_reg)
  rand uvm_reg_field enable;

  function new(string name = "sy_ctrl_reg");
    super.new(name, 32, UVM_NO_COVERAGE); 
  endfunction

  virtual function void build();
    enable = uvm_reg_field::type_id::create("enable");
    enable.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0); 
  endfunction
endclass

// ==========================================================
// 2. STATUS_REG (Address: 0x04)
// ==========================================================
class sy_status_reg extends uvm_reg;
  `uvm_object_utils(sy_status_reg)
  uvm_reg_field ready;

  function new(string name = "sy_status_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    ready = uvm_reg_field::type_id::create("ready");
    ready.configure(this, 1, 0, "RO", 0, 1'b0, 1, 0, 0); 
  endfunction
endclass

// ==========================================================
// 3. REG_2 (Address: 0x08) - Generic 32-bit RW Register
// ==========================================================
class sy_reg_2 extends uvm_reg;
  `uvm_object_utils(sy_reg_2)
  rand uvm_reg_field data;

  function new(string name = "sy_reg_2");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 0); 
  endfunction
endclass

// ==========================================================
// 4. REG_3 (Address: 0x0C) - Generic 32-bit RW Register
// ==========================================================
class sy_reg_3 extends uvm_reg;
  `uvm_object_utils(sy_reg_3)
  rand uvm_reg_field data;

  function new(string name = "sy_reg_3");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 0); 
  endfunction
endclass

// ==========================================================
// 5. Register Block (Top-level Memory Map)
// ==========================================================
class sy_reg_block extends uvm_reg_block;
  `uvm_object_utils(sy_reg_block)

  rand sy_ctrl_reg   ctrl_reg;
  rand sy_status_reg status_reg;
  rand sy_reg_2      reg_2;
  rand sy_reg_3      reg_3;

  function new(string name = "sy_reg_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    // Instantiate and build all 4 registers
    ctrl_reg = sy_ctrl_reg::type_id::create("ctrl_reg");
    ctrl_reg.configure(this, null);
    ctrl_reg.build();

    status_reg = sy_status_reg::type_id::create("status_reg");
    status_reg.configure(this, null);
    status_reg.build();

    reg_2 = sy_reg_2::type_id::create("reg_2");
    reg_2.configure(this, null);
    reg_2.build();

    reg_3 = sy_reg_3::type_id::create("reg_3");
    reg_3.configure(this, null);
    reg_3.build();

    // Create memory map
    default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);

    // Add registers to map with correct offsets
    default_map.add_reg(ctrl_reg,   'h00, "RW");
    default_map.add_reg(status_reg, 'h04, "RO");
    default_map.add_reg(reg_2,      'h08, "RW");
    default_map.add_reg(reg_3,      'h0C, "RW");
    
    // Set backdoor HDL paths matching the RTL array
    ctrl_reg.add_hdl_path_slice("slv_reg[0]", 0, 32);
    status_reg.add_hdl_path_slice("slv_reg[1]", 0, 32);
    reg_2.add_hdl_path_slice("slv_reg[2]", 0, 32);
    reg_3.add_hdl_path_slice("slv_reg[3]", 0, 32);

    lock_model(); 
  endfunction
endclass

`endif