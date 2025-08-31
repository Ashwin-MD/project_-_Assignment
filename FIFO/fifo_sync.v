module fifo_sync(clk,rst,wdata,wr_en,rd_en,rdata,wr_err,rd_err,full,empty);
	parameter WIDTH=8;
	parameter DEPTH=16;
	parameter PTR_WIDTH=$clog2(DEPTH);

	input clk,rst,wr_en,rd_en;
	input [7:0]wdata;
	output reg [7:0]rdata;
	output reg full,empty,wr_err,rd_err;

	//internal register
	reg [PTR_WIDTH-1:0] wr_ptr,rd_ptr;
	reg [PTR_WIDTH-1:0] wr_tgf,rd_tgf;
	reg [WIDTH-1:0] mem[DEPTH-1:0];
    integer i;
	
		always @( posedge clk) begin
			//write operation
			if(rst==1)begin
			  full=0;
			  wr_err=0;
			  wr_ptr=0;
			  wr_tgf=0;
			  for(i=0;i<DEPTH;i=i+1) mem[i]=0;
			 end
			 else begin
			   if(wr_en==1)begin
                 if(full==1)begin
			        wr_err=1;
				 end
				 else begin
				  mem[wr_ptr]=wdata; // 15th location is writing 16th data it will get increament in next step 

				  // wr_ptr= wr_ptr+1; if we put here (wr_ptr will save upto 15 so it can make error in output (wr_ptr again goes to zero) ) 

	    if (wr_ptr==DEPTH-1)begin // if we put DEPTH without the (-1) then depth =16 it means wr_ptr will save upto 15 so it can make error in output (wr_ptr again goes to zero) 
				     wr_ptr=0;
					 wr_tgf=~wr_tgf;
				  end
				  else  
				        wr_ptr= wr_ptr+1; // thats why we are implement this here after the write 
				 end
				  
				end
                            // same like that for read also
			   end
			    
		     end


   			//read operation
			always @(posedge clk) begin
            if(rst==1)begin
			  empty=0;
			  rd_err=0;
			  rd_ptr=0;
			  rd_tgf=0;
			  rdata=0;
			end
			else begin
			  if(rd_en==1)begin
			    if(empty==1)begin
			      rd_err=1;
			  end
			  else begin
			    rdata=mem[rd_ptr];
				if (rd_ptr==DEPTH-1)begin
				  rd_ptr=0;
				  rd_tgf=~rd_tgf;
				end
				else 
				   rd_ptr=rd_ptr+1;
				end
	          end
			  end
			end

			//full and empty operation
			always @(posedge clk)begin
			if(wr_ptr==rd_ptr&&wr_tgf==rd_tgf) empty=1;
			
			else 
			empty=0;

            if(wr_ptr==rd_ptr&&wr_tgf!==rd_tgf) full=1;
			else
			full=0;

			end
		
     endmodule	


	      //output ;
		   // once after pointer reaches to 15 my toggle will become one
		   // when we implement (wr_err,rd_err) the (full,empty must go to zero)
