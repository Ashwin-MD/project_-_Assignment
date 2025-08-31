module spi_cntrl(
//processor interface (apb signals)
	pclk_i,prst_i,paddr_i,penable_i,pwrite_i,pwdata_i,pready_o,prdata_o,perror_o,psel_i,
//slave interface (spi  signals)
	sclk_o,mosi,miso,cs,sclk_ref_i,
);
parameter NUM_BITS= 8;
parameter NUM_TXS = 8;

parameter S_IDLE_NO_TXS    =5'b00001;
parameter S_ADDR_PHASE		=5'b00010;
parameter S_IDLE_ADDR_DATA  =5'b00100;
parameter S_DATA_PHASE		=5'b01000;
parameter S_IDLE_TXS_PNDING	=5'b10000;

input pclk_i,prst_i,penable_i,pwrite_i;
input [NUM_BITS-1:0]paddr_i;
input [NUM_BITS-1:0]pwdata_i;
input [2:0]psel_i;
output reg [NUM_BITS-1:0]prdata_o;
output reg pready_o,perror_o;

input miso;
input sclk_ref_i;
output reg mosi;
output reg [2:0]cs;
output sclk_o;

// internal registers
reg [NUM_BITS-1:0]addr_reg[NUM_TXS-1:0]; //maximum 8 address 
reg [NUM_BITS-1:0]data_reg[NUM_TXS-1:0]; //maximum 8 data 
reg [NUM_BITS-1:0]cntrl_reg;
	
reg [NUM_BITS-1:0]addr_temp;
reg [NUM_BITS-1:0]data_temp;
reg [2:0]curr_txs_index;
reg [3:0]num_txs_pending;
reg flag;
reg [NUM_BITS-1:0]read_temp;//used for stro darta which is comming from slave

reg [4:0]state,nxt_state;
integer i,count;

//programming registers
//processor -  spi controller  and viceversa
always@(posedge pclk_i)begin
	if(prst_i)begin 
		prdata_o=0;
		perror_o=0;
		pready_o=0;
		mosi=0;
		cs=0;
		for(i=0;i<NUM_TXS;i=i+1)begin
				addr_reg[i]=0;
				data_reg[i]=0;
		end
		state=S_IDLE_NO_TXS;
		nxt_state=S_IDLE_NO_TXS;
		cntrl_reg=0;
		curr_txs_index=0;
		num_txs_pending=0;
		addr_temp=0;
		data_temp=0;
		count=0;
		read_temp=0;
		flag=0;
	end
	else begin 
		if(penable_i)begin 
			pready_o=1;
			if(pwrite_i)begin
				if(paddr_i>=8'h0 && paddr_i<=8'h7)
					addr_reg[paddr_i]=pwdata_i;//data belongs to address
				if(paddr_i>=8'h10 && paddr_i<=8'h17)
					data_reg[paddr_i-8'h10]=pwdata_i;//data belongs to address
				if(paddr_i==8'h20)begin 
					cntrl_reg[3:0]=pwdata_i;
				end
			end
			else begin 
				if(paddr_i>=8'h0 && paddr_i<=8'h7)
					prdata_o=addr_reg[paddr_i];//data belongs to address
				if(paddr_i>=8'h10 && paddr_i<=8'h17)
					prdata_o=data_reg[paddr_i-8'h10];//data belongs to address
				if(paddr_i==8'h20);
					prdata_o=cntrl_reg[3:0];
			end
		end
		else begin 
			pready_o=0;
		end
	end
end
//spi cntrl - spi slave and viceversa

always@(posedge sclk_ref_i)begin
	if(!prst_i)begin
			case(state)
				S_IDLE_NO_TXS:begin 
				mosi=1;
				flag=1'b0;//sclk_o will be ideal
						if(cntrl_reg[0]==1)begin
							nxt_state=S_ADDR_PHASE;
							num_txs_pending=cntrl_reg[3:1]+1;//0->1txs,1->2txs,....7->8txs
							cntrl_reg[6:4]= curr_txs_index;//  starts from staring index
							addr_temp=addr_reg[curr_txs_index];//collecting the 1st index addr from add_reg and storing int temprory variable
							data_temp=data_reg[curr_txs_index];//collecting the 1st index data from data_reg and storing int temprory variable
							count=0;
							flag=1'b1;//sclk_o will run  
						end
						else begin
							nxt_state=S_IDLE_NO_TXS;				
						end
				end
				S_ADDR_PHASE:begin 
					mosi=addr_temp[count];
					count=count+1;
					if(count==8)begin 
						nxt_state=S_IDLE_ADDR_DATA;
						flag=1'b0;
						count=0;
					end
					else begin 
						nxt_state=S_ADDR_PHASE;
						flag=1'b1;
					end 

				end
				S_IDLE_ADDR_DATA:begin 
					mosi=1;
					count=count+1;
					if(count==5)begin 
						nxt_state=S_DATA_PHASE;
						flag=1'b1;
						count=0;
					end
					else begin 
						nxt_state=S_IDLE_ADDR_DATA;
						flag=1'b0;
					end
				end
				S_DATA_PHASE:begin 
					if(addr_temp[7]==1)
						mosi=data_temp[count];//write data to slave 
					else  begin 
						read_temp[count]=miso;//read data from slave 
						mosi=1;
					end 
					count=count+1;
					if(count==8)begin 
						nxt_state=S_IDLE_TXS_PNDING;
						flag=1'b0;
						num_txs_pending=num_txs_pending-1;//1 txs is completed
						count=0;
					end
				end
				S_IDLE_TXS_PNDING:begin 
					mosi=1;
					count=count+1;
					if(count==5)begin
						if(num_txs_pending>0)begin
							nxt_state=S_ADDR_PHASE;
							count=0;
							flag=1'b1;
							curr_txs_index=curr_txs_index+1;        //incremanting the index
							addr_temp=addr_reg[curr_txs_index];		//updating the addr temp 
							data_temp=data_reg[curr_txs_index];		//updating the  data temp
								
						end		
						else begin
								nxt_state=S_IDLE_NO_TXS;
								flag=1'b0;

							//	cntrl_reg[7]=1;					//indicates that all txs are completed 
							//	cntrl_reg[0]=0;//it creates forever txs is held 
								cntrl_reg={1'b1,{7{1'b0}}};
								num_txs_pending=0;
								curr_txs_index=0;
								addr_temp=0;
								data_temp=0;
								count=0;
						end
					end
					else  begin 
						nxt_state=S_IDLE_TXS_PNDING;
							flag=1'b0;
					end
				end
			endcase
	end
end

//sclk_o= flag ? run_clK;ideal

assign sclk_o= flag ? sclk_ref_i :1'b1;


always@(nxt_state)state=nxt_state;

endmodule
