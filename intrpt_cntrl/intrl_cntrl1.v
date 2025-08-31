
//intrrupt controller design

module intrpt_cntrl(
//processor interface 
	pclk_i,prst_i,paddr_i,pwrite_i,pwdata_i,psel_i,penable_i,pready_o,perror_o,prdata_o,
	intrt_to_be_serviced_o,intrt_serviced_i,intr_valid_o,
//slave interface 
intr_active_i
);
parameter NUM_PHES=16;
parameter WIDTH=$clog2(NUM_PHES);
parameter DATA_WIDTH=4;
parameter S_NO_INTRPT							=3'b001;
parameter S_INTRPT_ACTIVE_GIVEN_TO_PROCESSOR	=3'b010;
parameter S_WAIT_FOR_INTRPT_SERVICED			=3'b100;

input pclk_i,prst_i,pwrite_i,penable_i;
input [WIDTH-1:0]paddr_i;
input [DATA_WIDTH-1:0]pwdata_i;
input [2:0]psel_i;
input intrt_serviced_i;
output reg  pready_o, perror_o;
output reg  [DATA_WIDTH-1:0]prdata_o;
output reg  [WIDTH-1:0]intrt_to_be_serviced_o;
output reg  intr_valid_o;
input [NUM_PHES-1:0]intr_active_i;

integer i;

//registers to store the  priority values
reg [DATA_WIDTH-1:0]pri_reg[NUM_PHES-1:0];

//registers for fingin highest pri_value
reg [WIDTH-1:0]curr_highst_pri_value;
reg [WIDTH-1:0]peri_with_high_pri_value;
reg first_match_f;
reg [2:0]state,next_state;

//loading pri_valuesto the register
always@(posedge pclk_i)begin 
	if(prst_i)begin
		pready_o=0;
		perror_o=0;
  		prdata_o=0;
  		intrt_to_be_serviced_o=0;
		intr_valid_o=0;
		curr_highst_pri_value=0;
		peri_with_high_pri_value=0;
		state=S_NO_INTRPT;
		next_state=S_NO_INTRPT;
		for(i=0;i<NUM_PHES;i=i+1)pri_reg[i]=0;
	end
	else begin 
		if(penable_i)begin 
			pready_o=1;
			if(pwrite_i)begin 
					pri_reg[paddr_i]=pwdata_i;
			end
			else begin
					prdata_o=pri_reg[paddr_i];
			end
		end
		else begin 
			pready_o=0;
		end
	end
end


//handling the interrupts

always@(posedge pclk_i)begin 
	if(!prst_i)begin
		case(state)
			S_NO_INTRPT:begin 
				//none of the  pheripharels have interrupts
					if(intr_active_i!=0)begin//if any of the peripheral have intruppts ,moves to state S_INTRPT_ACTIVE_GIVEN_TO_PROCESSOR
							next_state=S_INTRPT_ACTIVE_GIVEN_TO_PROCESSOR;
							first_match_f=1;
					end
					else begin //if no intruppts stay in same state
							next_state=S_NO_INTRPT;
					end
			end
			S_INTRPT_ACTIVE_GIVEN_TO_PROCESSOR:begin 
				//some pheripharels have interrupts 
				//figurres out which pheripharels have highest privalue
				//then give it to processor by making intr_valid_o ->1
				for(i=0;i<NUM_PHES;i=i+1)begin
						if(intr_active_i[i]==1)begin
							if(first_match_f==1)begin //assume the first slave itself to beserviced &it has high pri_value 
								curr_highst_pri_value=pri_reg[i];
								peri_with_high_pri_value=i;
								first_match_f=0;
							end
							else begin 
								if(curr_highst_pri_value<pri_reg[i])begin 
									curr_highst_pri_value=pri_reg[i];
									peri_with_high_pri_value=i;
								end
							end
						end
				end
				intrt_to_be_serviced_o = peri_with_high_pri_value;//service for the  peripheral 
				intr_valid_o=1;//intr_cntrl indicatesto processor im giveing some interrupts 
				next_state=S_WAIT_FOR_INTRPT_SERVICED;
			end
			S_WAIT_FOR_INTRPT_SERVICED:begin
				// once processor srviced  the intruppts
				//check again any intruppts are the ,if no intruppts got to S_NO_INTRPT else go to S_INTRPT_ACTIVE_GIVEN_TO_PROCESSOR
				// along with make register to 0 
				if(intrt_serviced_i==1)begin//processor indicates that it serviced request
					if(intr_active_i!=0)begin 
						next_state=S_INTRPT_ACTIVE_GIVEN_TO_PROCESSOR;
						curr_highst_pri_value=0;
						peri_with_high_pri_value=0;
						first_match_f=1;
						intr_valid_o=0;
					end
					else begin 
						next_state=S_NO_INTRPT;
					end
				end
			end
		endcase
	end
end
//state updating 
always@(next_state)state=next_state;
endmodule
