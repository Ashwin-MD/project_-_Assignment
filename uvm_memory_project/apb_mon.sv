class apb_mon extends uvm_monitor;
apb_tx tx;
virtual apb_intrf vif;
  
uvm_analysis_port#(apb_tx) ap_port; //mon has childern so we have to create object to it
`uvm_component_utils(apb_mon)


`NEW_COMP

function void build_phase (uvm_phase phase);
super.build_phase(phase);
ap_port=new("apb_port",this);
 // vif=top.pif;
  uvm_resource_db#(virtual apb_intrf)::read_by_name("GLOBAL","VIF",vif,this);  
endfunction

	task run_phase(uvm_phase phase);
		//vif=top.pif;
		forever begin
		@(vif.mon_cb);
		if(vif.mon_cb.valid==1 && vif.mon_cb.ready==1) begin
		tx=new();
        tx.addr = vif.mon_cb.addr;
		tx.wr_rd = vif.mon_cb.wr_rd;
		tx.data = vif.mon_cb.wr_rd ? vif.mon_cb.wdata:vif.mon_cb.rdata;
		
		//tx.print("mon prints");
		ap_port.write(tx);

	    end
	end
	endtask
endclass

