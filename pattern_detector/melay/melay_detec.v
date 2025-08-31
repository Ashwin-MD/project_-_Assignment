module melay_detecty(clk,rst,din,valid,pattern_detector);

input clk,rst,din,valid;
output reg pattern_detector;

parameter S_R= 5'b00001;
parameter S_B= 5'b00010;
parameter S_BB=5'b00100;
parameter S_BBC=5'b01000;
parameter S_BBCB=5'b10000;

reg  [4:0]state,nextstate;

		always @(posedge clk)begin
		if(rst==1)begin
		 pattern_detector=0;
		 state=S_R;
		 nextstate=S_R;
		end
         else begin
		     if(valid==1)begin
			 case(state)

			 S_R : begin
              if (din==1) begin
			      nextstate=S_B;
				  pattern_detector=0;
				  end 
				  else begin
				  nextstate=S_R;
				  pattern_detector=0;
			  end
			  end

			  	S_B : begin
				 if (din==1)begin
				     nextstate=S_BB;
					 pattern_detector=0;
					 end
				  else begin
				     nextstate=S_R;
					  pattern_detector=0;

			       end
				   end

				 	S_BB : begin
				 if (din==1)begin
				     nextstate=S_BBC;
					 pattern_detector=0;
					 end
				  else begin
				     nextstate=S_BB;
					  pattern_detector=0;
				     end
					 end

					S_BBC : begin
				 if (din==1)begin
				     nextstate=S_BBCB;
					 pattern_detector=0;
					 end
				  else begin
				     nextstate=S_R;
					  pattern_detector=0;
                     end
					  end

				S_BBCB :begin
				 if (din==1)begin
				    nextstate=S_R;
					 pattern_detector=0;
					 end
				else begin
				   nextstate=S_BB;
				    pattern_detector=1;
   					end
					 end
			 
			 endcase
		 end
		end
	end

 always @(nextstate)state=nextstate;
	 
 endmodule
