`include "fifo_async.v"
module async_tb;
reg wr_clk,rd_clk,rst,wr_en,rd_en;
reg [7:0]wdata;
wire [7:0]rdata;
wire full,empty,rd_err,wr_err;
reg [8*30:1]testcase;

   parameter WIDTH=8;
   parameter DEPTH=16;
   parameter PTR_WIDTH=$clog2(DEPTH);
   parameter N=11;


  

 async  #(WIDTH,DEPTH,PTR_WIDTH) dut (.*);
 always #3 wr_clk=~wr_clk;
 always #5 rd_clk=~rd_clk;

  initial begin
     wr_clk=0;
	  rd_clk=0;
	   rst=1;
	   rst_logic();
	   repeat (2) @(posedge wr_clk);
       rst=0;
	   $value$plusargs("testcase=%0s",testcase);
       $display("testcase=%0s",testcase);

    
	case(testcase)

	 "ALL_WRITES_AND_ALL_READS":begin
	     write_logic(DEPTH);
		 read_logic(DEPTH);
	     end

	"ALL_WRITES":begin
         write_logic(DEPTH);
		end

	"WRITE_ERROR":begin
		  write_logic(DEPTH+1);
		  end

     "READ_ERROR":begin
		  write_logic(DEPTH+1);
		  end

	 "N_WRITES_AND_N_READS":begin
	      write_logic(N);
		  read_logic(N);
		  end
     "C0NSECUTIVE_WRITES_AND_READS":begin
          fork
		  write_logic(DEPTH);
		  read_logic(DEPTH);
		  join
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


  //write operation
task write_logic (input reg [PTR_WIDTH:0]num_writes);
integer i;
 begin
        for(i=0;i<num_writes;i=i+1)begin
         @ (posedge wr_clk);
          wr_en=1;
	      wdata=$random;

		 end

         @(posedge wr_clk);
        rst_logic();

  end
  endtask


  task read_logic(input reg [PTR_WIDTH:0]num_reads);
  integer i;
  begin
       for(i=0;i<num_reads;i=i+1)begin
         @ (posedge rd_clk);
           rd_en=1;
       end	 
	
              @(posedge rd_clk);
               rst_logic();

  end
  endtask

   
  endmodule


