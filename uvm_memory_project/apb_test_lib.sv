class apb_base_test extends uvm_test;
 apb_env env;
`uvm_component_utils(apb_base_test)
 
 `NEW_COMP

 function void build_phase( uvm_phase phase);
  $display("test::build_phase");
   super.build_phase(phase);
  env=apb_env::type_id::create("env",this);
 endfunction

 function void end_of_elaboration();
  uvm_top.print_topology();
 endfunction


endclass

class apb_1_write_1_read_test extends apb_base_test;

  `uvm_component_utils(apb_1_write_1_read_test)

  `NEW_COMP

/*function void build_phase( uvm_phase phase);
   $display("test::build_phase");
   super.build_phase(phase);
   env=new("env",this);
 endfunction
*/
  
 task run_phase(uvm_phase phase);
   apb_1_write_1_read_seq seq;
   seq= apb_1_write_1_read_seq::type_id::create("seq");
   phase.raise_objection(this);
   phase.phase_done.set_drain_time(this,100);
   seq.start(env.agent.sqr);
   phase.drop_objection(this);
 endtask

class apb_n_wr_rd_test extends apb_base_test;
  `uvm_component_utils(apb_n_wr_rd_test)
  `NEW_COMP

/*task run_phase(uvm_phase phase);
   apb_n_wr_rd_seq seq;
   uvm_resource_db#(int)::set("GLOBAL","COUNT",10,this); // we have to set the tx_num before sequence gets created 
     
     seq= apb_n_wr_rd_seq::type_id::create("seq");
     phase.raise_objection(this);
     phase.phase_done.set_drain_time(this,100);
     seq.start(env.agent.sqr);
     phase.drop_objection(this);
 endtask
 */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);  
    uvm_resource_db#(int)::set("GLOBAL","COUNT",10,this);
    uvm_config_db#(uvm_object_wrapper)::set(this,"env.agent.sqr.run_phase","default_sequence",apb_n_wr_rd_seq::get_type());
    
  endfunction

endclass




















endclass
