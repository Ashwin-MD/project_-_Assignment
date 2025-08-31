   `include "fifo_sync.v"
	module sync_tb;
	parameter WIDTH=8;
	parameter DEPTH=16;
	parameter PTR_WIDTH=$clog2(DEPTH);
	parameter N=5;
	
	reg clk,rst,wr_en,rd_en;
	reg [7:0]wdata;
    wire [7:0]rdata;
	wire full,empty,wr_err,rd_err;
	reg[8*30:1]testcase;
	
	fifo_sync #(WIDTH,DEPTH,PTR_WIDTH)dut(.*);

	always #5 clk=~clk;

		initial begin
        clk=0;
		rst=1;
		rst_logic();	
		repeat(2) @ (posedge clk);
		rst=0;
		$value$plusargs("testcase=%0s",testcase);
		$display("testcase= %0s",testcase);
		case (testcase)
		"FULL " :begin
					write_logic(DEPTH);
		            read_logic(0);
	   			end
		"EMPTY"	:begin
		      write_logic(0);
			  read_logic(0);
			  end

	    "ALL_WRITES" : begin
		      write_logic(DEPTH);
		           end

		"ALL_WRITES_AND_READS" :begin
		     write_logic(DEPTH);
			 read_logic(DEPTH);
			          end

		"WRITE_ERROR"	:begin
             write_logic(DEPTH+1);
		          end

		"READ_ERROR" :begin
              read_logic(DEPTH+1);
				end

        "CONCURRENT_WRITES_READS" :begin
				fork
		      write_logic(DEPTH);
			  read_logic(DEPTH);
			    join
				       end
		"N_WRITES_AND_READS"  : begin
		      write_logic(N);
			  read_logic(N);
			          end

		endcase

	         #100;
		 $finish;
		end

	         task rst_logic();
			 begin
			 wr_en=0;
 			rd_en=0;
 			wdata=0;
 			end
			endtask

 task write_logic(input reg[PTR_WIDTH:0]num_writes);
 integer i;
begin
           for(i=0;i<num_writes;i=i+1)begin
		  @(posedge clk)
		  wr_en=1;
		  wdata=$random; // after the max write my write will be reset
		   end
		  @(posedge clk)
		  rst_logic();
end
endtask

task read_logic(input reg [PTR_WIDTH:0]num_reads);
integer i;
		 begin
		 for(i=0;i<num_reads;i=i+1)begin
		 @(posedge clk)
		 rd_en=1;
		 end
		 @(posedge clk)
		 rst_logic();
end
endtask

  endmodule
