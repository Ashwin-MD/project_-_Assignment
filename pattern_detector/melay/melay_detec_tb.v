`include"melay_detec.v"
module melay_tb;
 
reg clk,rst,din,valid;

wire pattern_detector;

integer count;
 
 always #5 clk=~clk;


  melay_detect dut (clk,rst,din,valid,pattern_detector);


  
  initial begin
    clk=0;
	count=0;
	rst=1;
	rst_logic();
	repeat(2)@(posedge clk) 
	rst=0;
	valid=1;
	repeat (150)begin
	din=$random;
	#5;
	end
	#10;
	rst_logic();

      #10;
	  $display("pattern_detector =%0d",count);
	  $finish;
  
   end
            
task rst_logic();
begin
   din=0;
   valid=0;
end
endtask
	always @(posedge pattern_detector)count=count+1; 
	

endmodule

