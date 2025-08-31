module apb_slave_dut(clk,rst,wr_rd,addr,wdata,valid,rdata,ready);


//parameter WIDTH=16;
//parameter DEPTH=32;
//parameter ADDR_WIDTH=$clog2(DEPTH);

input clk,rst,wr_rd,valid;
  input [`WIDTH-1:0]wdata;
  input [`ADDR_WIDTH-1:0]addr;

output reg ready;
  output reg [`WIDTH-1:0]rdata;

  reg[`WIDTH-1:0]mem[`DEPTH-1:0];
integer i;

always @(posedge clk)begin
	if(rst==1)begin
	rdata=0;
	ready=0;
      for(i=0;i<`DEPTH;i++) mem[i]=0;
	end
	else begin
		if(valid)begin
			ready=1;
			if(wr_rd)begin
			mem[addr]=wdata;
			end
		else begin
			rdata=mem[addr];
		end
	end
		else begin
			ready=0;
		end
	end
end
endmodule

