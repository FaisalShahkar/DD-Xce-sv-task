module packet_generator (
    input  logic clk,
    input  logic reset,
    input  logic start,
    input  logic ready,
    output logic valid,
    output logic [1:0] dest_addr,
    output logic [1:0] packet_type,
    output logic [7:0] payload,
    output logic eop
);

    typedef enum logic [1:0] 
    {
        DATA     = 2'b00,
        CONTROL  = 2'b01,
        RESPONSE = 2'b10,
        RESERVED = 2'b11
    } packet_type_t;

    logic [1:0] packet_state;
    logic [1:0] dest;
    logic [7:0] data;
    logic [1:0] type_packet;
    logic       end_of_packet;

    always_ff @(posedge clk or negedge reset) 
    begin
        if (!reset) begin
            packet_state <= 2'b00;
            dest <= 2'b00;
            data <= 8'b00000000;
            type_packet <= DATA;
            end_of_packet <= 0;
        end 
        else 
        begin
            if (start) 
            begin
                case (packet_state)
                    2'b00: 
                    begin
                        valid <= 1;
                        if (ready) 
                        begin
                            dest <= 2'b00;
                            type_packet <= DATA;
                            data <= data;
                            end_of_packet <= 0;
                            packet_state <= 2'b01; 
                        end
                        
                    end
                    2'b01: 
                    begin
                        valid <= 1;
                        dest <= 2'b01;
                        type_packet <= CONTROL;
                        data <= data;
                        end_of_packet <= 0;
                        packet_state <= 2'b10;
                    end
                    2'b10: 
                    begin
                        valid <= 1;
                        dest <= 2'b10;
                        type_packet <= RESPONSE;
                        data <= data;
                        end_of_packet <= 1;
                        packet_state <= 2'b00;
                    end
                    2'b11: 
                    begin
                        valid <= 1;
                        dest <= 2'b11;
                        type_packet <= RESERVED;
                        data <= data;
                        end_of_packet <= 0;
                        packet_state <= 2'b10;
                    end
                endcase
            end 
            else 
            begin
                valid <= 0;
                end_of_packet <= 0;
            end
        end
    end

    assign dest_addr = dest;
    assign packet_type = type_packet;
    assign payload = data;
    assign eop = end_of_packet;

endmodule
