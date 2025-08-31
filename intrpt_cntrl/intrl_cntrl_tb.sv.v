`include "intrl_cntrl1.v"
module top;
parameter NUM_PHES=16;
parameter WIDTH=$clog2(NUM_PHES);
parameter DATA_WIDTH=4;

reg  pclk_i,prst_i,pwrite_i,penable_i;
reg  [WIDTH-1:0]paddr_i;
reg  [DATA_WIDTH-1:0]pwdata_i;
reg  [2:0]psel_i;
reg  intrt_serviced_i;
reg  [NUM_PHES-1:0]intr_active_i;
wire pready_o, perror_o;
wire [DATA_WIDTH-1:0]prdata_o;
wire [WIDTH-1:0]intrt_to_be_serviced_o;
wire intr_valid_o;

integer i;
reg [8*40:0]testcase;
integer array[NUM_PHES-1:0];

intrpt_cntrl #(.WIDTH(WIDTH),.DATA_WIDTH(DATA_WIDTH),.NUM_PHES(NUM_PHES))dut (pclk_i,prst_i,paddr_i,pwrite_i,pwdata_i,psel_i,penable_i,pready_o,perror_o,prdata_o,intrt_to_be_serviced_o,intrt_serviced_i,intr_valid_o,intr_active_i);


always #5 pclk_i=~pclk_i;

initial begin
	pclk_i=0;
	prst_i=1;
	pwrite_i=0;
	penable_i=0;
	paddr_i=0;
	pwdata_i=0;
	psel_i=0;
	intrt_serviced_i=0;
	intr_active_i=0;

	repeat(1)@(posedge pclk_i);
	prst_i=0;
	$value$plusargs("testcase=%s",testcase);
	//loading the data to design registers
	case(testcase)
		"LOW_PHERI_WITH_LOW_PRI_VALUE":begin
			for(i=0;i<NUM_PHES;i=i+1)begin 
				write_logic(i,i);//low_pheriphal with low_priority
			end
			rst_logic();
		end
		"LOW_PHERI_WITH_HIGH_PRI_VALUE":begin
			for(i=0;i<NUM_PHES;i=i+1)begin 
				write_logic(i,NUM_PHES-1-i);//low_pheriphal with low_priority
			end
			rst_logic();
		end
		"PHERI_WITH_RANDOM_PRI_VALUE":begin
			//generate  random unique pri values
			unique_arr();
			for(i=0;i<NUM_PHES;i=i+1)begin 
				write_logic(i,array[i]);//low_pheriphal with low_priority
			end
			rst_logic();
		end
	endcase
	intr_active_i=$random;
	#500;
	$finish;
end


always@(posedge intr_valid_o)begin
	#27;											//time takenby processor  to service the request 
	intrt_serviced_i=1;								//processor indicates that i serviced the request
	intr_active_i[intrt_to_be_serviced_o]=0;		//peripheral drops the intrrupts
	@(posedge pclk_i);
	intrt_serviced_i=0;								//waiting for next intrrupts 
end
task write_logic(input reg[WIDTH-1:0]addr,input reg [DATA_WIDTH-1:0]data);
begin 
	@(posedge pclk_i);
	paddr_i=addr;
	pwdata_i=data;
	pwrite_i=1;
	penable_i=1;
	wait(pready_o==1);
end
endtask

task rst_logic();
begin 
	@(posedge pclk_i);
	paddr_i=0;
	pwdata_i=0;
	pwrite_i=0;
	penable_i=0;
end
endtask
task unique_arr();
integer value,i,j;
reg flag;
begin
	for(i=0;i<NUM_PHES;)begin 
		value=$urandom_range(0,15);
		flag=1;
		for(j=0;j<i;j=j+1)begin
			if(array[j]==value)begin 
				j=i;
				flag=0;
			end
			else flag=1;
		end
		if(flag==1)begin
				array[i]=value;
				i=i+1;
		end
	end
end
endtask
endmodule

