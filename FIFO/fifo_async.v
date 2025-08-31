   module async(wr_clk,rd_clk,rst,wr_en,rd_en,wdata,rdata,full,empty,rd_err,wr_err);
   parameter WIDTH=8;
   parameter DEPTH=16;
   parameter PTR_WIDTH=$clog2(DEPTH);

   input  wr_clk,rd_clk,rst,wr_en,rd_en;
   input [7:0] wdata;
   output reg [7:0]rdata;
   output reg full,empty,wr_err,rd_err;

   //internal signal
   reg [PTR_WIDTH-1:0] wr_ptr,rd_ptr;
   reg[PTR_WIDTH-1:0]wr_tgf,rd_tgf;
   reg[WIDTH-1:0] mem[DEPTH-1:0];
   reg [PTR_WIDTH-1:0] wr_ptr_clk ,rd_ptr_clk ;
   reg [PTR_WIDTH-1:0]wr_tgf_clk ,rd_tgf_clk;

    
   integer i;
   always @(posedge wr_clk)begin
          if(rst==1)begin
		  	full=0;
			wr_err=0;
			wr_ptr=0;
			wr_tgf=0;
		for (i=0;i<DEPTH;i=i+1)mem[i]=0;
		end
           else begin
		    if(wr_en==1) begin
			  if(full==1)begin
			    wr_err=1;
			  end	
				else begin
				   mem[wr_ptr]=wdata;
				      if(wr_ptr==DEPTH-1)begin
					    wr_ptr=0;
						 wr_tgf=~wr_tgf;
						 end
						 else 
						   wr_ptr=wr_ptr+1;
						  end
            end
   end

end  
       //read operation 

       always @(posedge rd_clk)begin
          if(rst==1)begin
	   		empty=0;
			rd_err=0;
			rdata=0;
			rd_ptr=0;
			rd_tgf=0;
	       			 end
		 else begin
		      if(rd_en==1)begin
			    if(empty==1)begin
				  rd_err=1;
				  end
				    else begin
					 rdata=mem[rd_ptr];
					  if(rd_ptr==DEPTH-1)begin
					     rd_ptr=0;
						  rd_tgf=~rd_tgf;
						end

					   else 
					      rd_ptr=rd_ptr+1;
			end	  

		 end
	   end
 end
          //synchronizing the (asynchronous w r t to wr_ptr) 
		   always @(posedge rd_clk)begin
		    wr_ptr_clk <=wr_ptr;
					wr_tgf_clk <=wr_tgf;
		   end

               //synchronizing the (asynchronous w r t to rd_ptr)

		  		  always @ (posedge wr_clk)begin
		    		 rd_ptr_clk <=rd_ptr;
			 			rd_tgf_clk <=rd_tgf;
		           end
                 always @ (posedge wr_clk)begin
		   if(wr_ptr_clk==rd_ptr_clk &&  wr_tgf_clk ==rd_tgf_clk ) empty=1;
			 else 
			   empty=0;
		   	if(wr_ptr_clk==rd_ptr_clk &&  wr_tgf_clk !=rd_tgf_clk) full=1;
			 else 
			     full=0;
			 end

		endmodule

