class apb_drv extends uvm_driver#(apb_tx);
 `uvm_component_utils(apb_drv);
 virtual apb_intrf vif;

function new (string name="",uvm_component parent);
 super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
 super.build_phase(phase);
 uvm_resource_db#(virtual apb_intrf)::read_by_name("GLOBAL","VIF",vif,this);
endfunction

  task run_phase(uvm_phase phase);
 // vif=top.pif;
  forever begin
   seq_item_port.get_next_item(req);
   req.print();
   drive_tx(req);
   seq_item_port.item_done();
  end
endtask

task drive_tx (apb_tx tx);
   
  		@(vif.bfm_cb);
		vif.bfm_cb.addr     <=tx.addr;
		vif.bfm_cb.wr_rd	<=tx.wr_rd;
		
			if(tx.wr_rd==1)vif.bfm_cb.wdata<=tx.data;
			vif.bfm_cb.valid<=1;
		wait(vif.bfm_cb.ready==1);
	
	   
	
		@(vif.bfm_cb);
		vif.bfm_cb.valid<=0;
		vif.bfm_cb.addr<=0;
		vif.bfm_cb.wdata<=0;
		vif.bfm_cb.wr_rd<=0;
  

endtask

endclass
