module moore(clk,rst,din,valid,pattern_detector);

input clk,rst,din,valid;
output reg pattern_detector;

parameter S_R=   6'b000001;
parameter S_B=   6'b000010;
parameter S_BB=  6'b000100;
parameter S_BBC= 6'b001000;
parameter S_BBCB=6'b010000;
parameter S_BBCBC=6'b100000; 

reg  [5:0]state,nextstate;

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
			  pattern_detector=0;

              if (din==1) begin
			      nextstate=S_B;
				  	end 
				      else begin
				  nextstate=S_R;
				    end
			  end
            
			S_B : begin
			 pattern_detector=0;
			 if (din==1)begin
			   nextstate=S_BB;
			    end
				  else begin
				  nextstate=S_R;
				    end
			  end
              
				S_BB : begin
			 pattern_detector=0;
			 if (din==1)begin
			   nextstate=S_BB;
			    end
				  else begin
				  nextstate=S_BBC;
				    end
			  end

			  S_BBC : begin
			 pattern_detector=0;
			 if (din==1)begin
			   nextstate=S_BBCB;
			    end
				  else begin
				  nextstate=S_R;
				    end
			  end

             S_BBCB : begin
			 pattern_detector=0;
			 if (din==1)begin
			   nextstate=S_BB;
			    end
				  else begin
				  nextstate=S_BBCBC;
				    end
			  end
              
			  S_BBCBC : begin
			 pattern_detector=1;
			 if (din==1)begin
			   nextstate=S_B;
			    end
				  else begin
				  nextstate=S_R;
				    end
			  end
 
	
         endcase
		    end
		 end
	 end	 
   
   always @(nextstate)state=nextstate;
endmodule


