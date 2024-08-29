module tb_noc_router ();
// input and outputs
logic clk;
logic reset;
logic start;
logic gen_valid, gen_ready;
logic [1:0] gen_dest_addr;
logic [1:0] gen_packet_type;
logic [7:0] gen_payload;
logic gen_eop;

logic router_valid, router_ready;
logic [1:0] router_dest_addr;
logic [1:0] router_packet_type;
logic [7:0] router_payload;
logic router_eop;

// instantiation module packet generator
packet_generator uut1(
    .clk(clk),
    .reset(reset),
    .start(start),
    .valid(gen_valid),
    .ready(gen_ready),
    .dest_addr(gen_dest_addr),
    .packet_type(gen_packet_type),
    .payload(gen_payload),
    .eop(gen_eop)
);

// instantiation module router
router uut2(
    .clk(clk),
    .reset(reset),
    .valid(router_valid),
    .dest_addr(router_dest_addr),
    .packet_type(router_packet_type),
    .payload(router_payload),
    .eop(router_eop),
    .ready(router_ready)
);

// clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// reset sequence
task reset_apply();
    reset = 1;
    @(posedge clk);
    reset = 0;
endtask

// initialization
task init_sequence();
    clk = 0;
    reset = 0;
    start = 0;
    gen_ready = 0;
    router_valid = 0;
    router_dest_addr = 2'b0;
    router_packet_type = 2'b0;
    router_payload = 8'b0;
    router_eop = 0;   
endtask 

// driver task for inputs
task driver();
    logic [1:0] addr;
    logic [1:0] type_of_packet; 
    logic [7:0] data;
    logic router_eop1;
    
    // generate the random addresses, packet type, data
    addr           = $urandom_range(0,3);
    type_of_packet = $urandom_range(0,3);
    data           = $urandom_range(0,100);
    router_eop1    = $urandom_range(0,1);
    start          = $urandom_range(0,1);
    gen_ready      = $urandom_range(0,1);

    if(start)
    begin
        gen_valid = 1;
        // waiting for ready signal is high
        $display("waiting for ready signal high for handshake");
        while (!gen_ready) begin
            @(posedge clk);            
        end
        $display("handshake occur both valid and ready are high");
        router_dest_addr = addr;
        router_packet_type = type_of_packet;
        router_payload = data;
        router_eop = router_eop1;
        @(posedge clk);
        // after the handshake gen_valid become low 
        gen_valid = 0;
    end
    else 
    begin
        // waiting for request
        $display("Waiting for start signal is high to start the execution");
        while (!start) begin
            @(posedge clk);
        end
    end   
endtask

// monitor task for outputs and inputs checking
task monitor();
    // after some clock cycles data has been processed and router valid signal is high 
    @(posedge clk);
    @(posedge clk);
    router_valid = 1;
    // waiting for ready signal is high
    $display("waiting for ready signal high for handshake");
    while (!router_ready) begin
        @(posedge clk);
    end
    $display("Again handshake occur both valid and ready are high");
    
    // monitor the outputs
    $monitor("router_ready: %b, router_dest_addr: %b, router_packet_type: %b,router_eop: %b,router_payload: %b"
    ,router_ready,router_dest_addr,router_packet_type,router_eop,router_payload);

endtask

initial begin

    $display("Applying Reset");
    reset_apply();  // reset apply
    @(posedge clk);
 
    $display("initialize the signals"); 
    init_sequence(); // initialize the signals
    @(posedge clk);

    fork
        driver();
        monitor();    
    join
    $finish;
end

// waveform simulation
initial begin
    $dumpfile("tb_noc_router.vcd");
    $dumpvars(0,tb_noc_router);
end    
endmodule