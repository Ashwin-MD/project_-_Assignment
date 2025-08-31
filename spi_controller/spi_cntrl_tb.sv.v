`include "spi_cntrl.v"
module top;

parameter NUM_BITS= 8;
reg pclk_i,prst_i,penable_i,pwrite_i;
reg [NUM_BITS-1:0]paddr_i;
reg [NUM_BITS-1:0]pwdata_i;
reg [2:0]psel_i;
wire [NUM_BITS-1:0]prdata_o;
wire pready_o,perror_o;
reg sclk_ref_i;

reg miso;
wire mosi;
wire [2:0]cs;
wire sclk_o;

integer i;
spi_cntrl #(.NUM_BITS(NUM_BITS)) dut (pclk_i,prst_i,paddr_i,penable_i,pwrite_i,pwdata_i,pready_o,prdata_o,perror_o,psel_i,sclk_o,mosi,miso,cs,sclk_ref_i);

initial begin
	pclk_i=0;
	forever #5 pclk_i=~pclk_i;
end
initial begin
	sclk_ref_i=0;
	forever #2 sclk_ref_i=~sclk_ref_i;
end

initial begin
	prst_i=1;
	penable_i=0;
	pwrite_i=0;
	paddr_i=0;
	pwdata_i=0;
	psel_i=0;
	miso=1;
	repeat(1)@(posedge pclk_i);
	prst_i=0;
	
	//write  the address to the registers
		 for(i=0;i<NUM_BITS;i=i+1)begin
		 	write_logic(i,8'hd3+i);//d3,d4,d5,d6,d7,d8,d9,da
		 end
	
	//write  the data to the registers
		 for(i=0;i<NUM_BITS;i=i+1)begin
		 	write_logic(8'h10+i,8'h53+i);//53,54,55,56,57,58,59,5a
		 end

	//write into  cntrl registers
		 	//write_logic(8'h20,{4'b0000,3'b000,1'b1});// 1txs 
		 	write_logic(8'h20,{4'b0000,3'b111,1'b1});// 8txs 
		 rst_logic();	
			#1000;
		 	write_logic(8'h20,{4'b0000,3'b101,1'b1});// 6txs 
		 rst_logic();	
end
initial begin 
	#5000;
	$finish;
end
task rst_logic();
begin 
	@(posedge pclk_i);
	paddr_i=0;
	pwdata_i=0;
	pwrite_i=0;
	penable_i=0;
end
endtask
task write_logic(input reg[NUM_BITS-1:0]addr,input reg [NUM_BITS-1:0]data);
begin 
	@(posedge pclk_i);
	paddr_i=addr;
	pwdata_i=data;
	pwrite_i=1;
	penable_i=1;
	wait(pready_o==1);
end
endtask





endmodule
