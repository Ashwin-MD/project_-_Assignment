`include "memory.v"

module top;

parameter WIDTH =16;
parameter DEPTH =64;
parameter ADDR_WIDTH=$clog2(DEPTH);


reg clk,rst,wr_rd,valid;
reg [ADDR_WIDTH-1:0]addr;
reg [WIDTH-1:0]wdata;
wire [WIDTH-1:0]rdata;
wire ready;
 
memory #(WIDTH,DEPTH,ADDR_WIDTH)  dut(.*);

always #5 clk=~clk;


 initial begin
      
	  	clk=0;
		rst=1;
		rst_logic();
        repeat  (2) @(posedge clk);
		rst=0;
		$readmemh("digital_image.hex",dut.mem);
		$writememh("digital_image1.hex",dut.mem);
			
	    $finish;



	end

task rst_logic();
begin
	wr_rd=0;
	valid=0;
	addr=0;
    wdata=0;

end
endtask

endmodule	
