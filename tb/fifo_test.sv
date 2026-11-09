class fifo_test extends uvm_test;

    `uvm_component_utils(fifo_test)

    fifo_env env;

    function new(string name = "fifo_test",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = fifo_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);

        //fifo_sequence seq;

        //phase.raise_objection(this);

        //seq = fifo_sequence::type_id::create("seq");

        //seq.start(env.agent.sequencer);

        fifo_fill_sequence fill_seq;
        fifo_drain_sequence drain_seq;
        fifo_simultaneous_sequence simultaneous_seq;

        phase.raise_objection(this);

        fill_seq = fifo_fill_sequence::type_id::create("fill_seq");
        drain_seq = fifo_drain_sequence::type_id::create("drain_seq");
        simultaneous_seq = fifo_simultaneous_sequence::type_id::create("simultaneous_seq");

        // TEST 1 - Overflow attempt
        `uvm_info("FIFO_TEST", "Starting FIFO fill sequence", UVM_LOW)
        fill_seq.start(env.agent.sequencer);
        
        // TEST 2 - Underflow attempt
        `uvm_info("FIFO_TEST", "Starting FIFO drain sequence", UVM_LOW)
        drain_seq.start(env.agent.sequencer);

        // TEST 3 - write/read simulataneous attempt
        `uvm_info("FIFO_TEST", "Starting FIFO simultaneous write/read sequence", UVM_LOW)
        simultaneous_seq.start(env.agent.sequencer);

        // Allow the monitor and scoreboard to process
        // the final transaction.
        repeat (2) @(env.agent.driver.vif.mon_cb);

        phase.drop_objection(this);

    endtask

endclass
