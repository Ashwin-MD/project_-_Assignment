`include "memory.v"

module top;

parameter WIDTH =16;
parameter DEPTH =64;
parameter ADDR_WIDTH=$clog2(DEPTH);
parameter STR_ADDR=10;
parameter NUM_ADDR=6;


reg clk,rst,wr_rd,valid;
reg [ADDR_WIDTH-1:0]addr;
reg [WIDTH-1:0]wdata;
wire [WIDTH-1:0]rdata;
wire ready;
reg [8*30:1]testcase; 
memory #(WIDTH,DEPTH,ADDR_WIDTH)  dut(.*);

always #5 clk=~clk;


 initial begin
     
	  	clk=0;
		rst=1;
		rst_logic();
        repeat  (2) @(posedge clk);
		rst=0;
		$value$plusargs("testcase=%0s",testcase);
		$display("testcase=%0s",testcase);
  		case(testcase)

		"WRITE_ALL_LOCATION" : begin
         write_logic(0,DEPTH);
		end

		"WRITE_READ_ALL_LOCATION": begin
		  write_logic(0,DEPTH);
		  read_logic(0,DEPTH);
		end

		 "SPECIFIC_LOCATION":begin
           write_logic(STR_ADDR,NUM_ADDR);
		   read_logic(STR_ADDR,NUM_ADDR);
		 end


		 "FIRST_HALF_OF_MEM":begin
		   write_logic(0,DEPTH/2);
		   read_logic(0,DEPTH/2);
		 end

		 "SECOND_HALF_OF_MEM":begin
            write_logic(DEPTH/2,DEPTH/2);
			read_logic(DEPTH/2,DEPTH/2);
		 end

		 "FIRST_QUARTER":begin
		   write_logic(0,DEPTH/4);
			read_logic(0,DEPTH/4);
            end

		 	
		"SECOND_QUARTER":begin
		   write_logic(DEPTH/4,DEPTH/4);
			read_logic(DEPTH/4,DEPTH/4);
            end

		"THIRD_QUARTER":begin
		   write_logic(DEPTH/2,DEPTH/4);
			read_logic(DEPTH/2,DEPTH/4);
            end
	


       "FOURTH_QUARTER":begin
		   write_logic(DEPTH/4,(DEPTH/4)*3);
			read_logic(DEPTH/4,(DEPTH/4)*3);
            end



		 

		endcase
        	#50;
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

task write_logic (input reg [ADDR_WIDTH-1:0]st_addr,input reg[ADDR_WIDTH:0]num_addr);
integer i;
begin

	for(i=st_addr;i<st_addr+num_addr;i=i+1)begin
		@ (posedge clk);
		wr_rd=1;
		addr=i;
		wdata=$random;
		valid=1;
        wait (ready==1);
		end
		@ (posedge clk);
		rst_logic();
end
endtask


task read_logic(input reg [ADDR_WIDTH-1:0]st_addr,input reg[ADDR_WIDTH:0]num_addr);
integer i;
begin
      	for(i=st_addr;i<st_addr+num_addr;i=i+1)begin
		@ (posedge clk);
		wr_rd=0;
		addr=i;
		valid=1;
        wait (ready==1);
		end
		@ (posedge clk);
		rst_logic();
     
end
endtask
	
endmodule	
