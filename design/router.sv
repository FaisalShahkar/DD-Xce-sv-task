module router (
    input logic clk,
    input logic reset,
    input logic valid,
    input logic [1:0] dest_addr,
    input logic [1:0] packet_type,
    input logic [7:0] payload,
    input logic eop,
    output logic ready
);

    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        RECEIVE  = 2'b01,
        PROCESS  = 2'b10
    } state_t;

    state_t state, next_state;
    logic [7:0] fifo [0:3]; // 4 buffers of 8 bit size
    integer fifo_ptr;      // for indexing the above 4 buffers

    always_ff @(posedge clk or negedge reset) 
    begin
        if (!reset) 
        begin
            state <= IDLE;
            fifo_ptr <= 0;
        end 
        else 
        begin
            state <= next_state;
            if (state == RECEIVE && valid) // when we are at receive state and valid is high data os stored in specific buffer
            begin 
                fifo[fifo_ptr] <= payload;
                fifo_ptr <= fifo_ptr + 1;
            end
        end
    end

    always_comb 
    begin
        next_state = state;
        case (state)
            IDLE: 
            begin
                if (valid) 
                begin
                    next_state = RECEIVE;
                end
            end
            RECEIVE: 
            begin
                if (eop) 
                begin
                    next_state = PROCESS;
                end
            end
            PROCESS: 
            begin
                if (ready) 
                begin
                    next_state = IDLE;
                end
            end
        endcase
    end

endmodule