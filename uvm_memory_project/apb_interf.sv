interface apb_intrf(input bit clk,rst);
bit [`ADDR_WIDTH-1:0]addr;
bit [`WIDTH-1:0]wdata;
bit [`WIDTH-1:0]rdata;
bit wr_rd;
bit valid;
bit ready;


clocking bfm_cb @(posedge clk);
	default input #1 output #0;
	input rst;
	input rdata;
	input ready;
	output wr_rd;
	output wdata;
	output addr;
	output valid;
endclocking

clocking mon_cb @(posedge clk);
	default input #1;
	input rst;
	input rdata;
	input ready;
	input wr_rd;
	input wdata;
	input addr;
	input valid;
endclocking


endinterface
