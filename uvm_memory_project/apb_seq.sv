class apb_seq extends uvm_sequence #(apb_tx);
apb_tx tx;
 `uvm_object_utils(apb_seq);

function new (string name="");
 super.new(name);
endfunction

 task body();
   
  `uvm_do_with(req,{req.wr_rd==1;})
  tx = new req; 
  `uvm_do_with(req,{req.wr_rd==0; req.addr==tx.addr;})

 endtask


endclass
