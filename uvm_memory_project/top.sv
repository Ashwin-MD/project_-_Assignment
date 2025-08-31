//`include"uvm_pkg.sv"
import uvm_pkg::*;
`include "apb_common.sv"

`include "uvm_macros.svh"
`include "apb_slave_dut.v"
`include "apb_tx.sv"
`include "apb_seq_lib.sv"
`include "apb_interf.sv"
`include "apb_mon.sv"
`include "apb_cov.sv"
`include "apb_drv.sv"
`include "apb_sqr.sv"
`include "apb_agent.sv"
`include "apb_env.sv"
`include "apb_test_lib.sv"

module top;
reg clk,rst;
apb_intrf pif (clk,rst);

 initial begin
    clk = 0;
   forever #5 clk= ~clk;	
 end

 initial begin
 uvm_resource_db#(virtual apb_intrf )::set("GLOBAL" ,"VIF",pif,null);
  rst=1;
  #20;
  rst=0;
 end
 
  apb_slave_dut  dut(.clk(pif.clk),
	 	.rst(pif.rst),
	 	.valid(pif.valid),
		.ready(pif.ready),
		.rdata(pif.rdata),
		.wdata(pif.wdata),
		.addr(pif.addr),
		.wr_rd(pif.wr_rd));


initial begin

  run_test("apb_n_wr_rd_test");


end
 
  initial begin
    $dumpvars();
    $dumpfile("1.vcd");
  end
  
  
  
  initial begin
   
   	#1000;
   $finish; 
  
  end
  
endmodule
