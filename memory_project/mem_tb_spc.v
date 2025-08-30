`include "memory.v"

module top;

parameter WIDTH =16;
parameter DEPTH =64;
parameter ADDR_WIDTH=$clog2(DEPTH);


reg clk,rst,wr_rd,valid;
reg [ADDR_WIDTH-1:0]addr;
reg [WIDTH-1:]wdata;
wire [WIDTH-1:0]rdata;
wire ready;
 
memory #(WIDTH,DEPTH,ADDR_WIDTH)  dut(.*);

always #5 clk=~clk;


 initial begin
     
	  	clk=0;
		rst=1;
		rst_logic();
        repeat  2 @(posedge clk);
		rst=0;

		//write logic
		for(i=0;i<DEPTH:i=i+1)begin
		@ (posedge clk);
		wr_rd=1;
		addr=i;
		wdata=$random;
		valid=1;
        end

		wait (ready==1);
		@ (posedge clk);
		rst_logic();

		//read logic
		for(i=0;i<DEPTH;i=i+1)begin
		@ (posedge clk);
		valid=1;
		wr_rd=0;
		end
		
 		wait (ready==1);
        end

		@(posedge clk);
		rst_logic();



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
