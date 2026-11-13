module elevator (
    input clk,
    input reset,
    input [3:0] request,
    output reg [1:0] floor,
    output reg up,
    output reg down,
    output reg door_open
);

parameter IDLE = 2'b00,
          UP   = 2'b01,
          DOWN = 2'b10,
          DOOR = 2'b11;

reg [1:0] state;
reg [3:0] pending;
reg [1:0] target;
reg [2:0] timer;

always @(posedge clk or posedge reset) begin

    if (reset) begin
        floor <= 0;
        up <= 0;
        down <= 0;
        door_open <= 1;
        state <= IDLE;
        pending <= 0;
        target <= 0;
        timer <= 0;
    end

    else begin

        // Save floor requests
        pending <= pending | request;

        case(state)

        IDLE: begin
            up <= 0;
            down <= 0;
            door_open <= 0;

            if (pending[floor] || request[floor]) begin
                door_open <= 1;
                timer <= 3;
                state <= DOOR;
            end

            else if ((pending | request) > (4'b0001 << floor)) begin
                if (|((pending | request) & 
                    (4'b1111 << (floor + 1)))) begin
                    target <= 3;
                    up <= 1;
                    state <= UP;
                end
                else begin
                    target <= 0;
                    down <= 1;
                    state <= DOWN;
                end
            end

        end

        UP: begin
            up <= 1;
            down <= 0;
            door_open <= 0;

            if (floor < 3)
                floor <= floor + 1;

            if (pending[floor + 1] || 
                request[floor + 1]) begin
                up <= 0;
                door_open <= 1;
                timer <= 3;
                state <= DOOR;
                pending[floor + 1] <= 0;
            end
            else if (floor == target) begin
                up <= 0;
                state <= IDLE;
            end
        end

        DOWN: begin
            down <= 1;
            up <= 0;
            door_open <= 0;

            if (floor > 0)
                floor <= floor - 1;

            if (pending[floor - 1] || 
                request[floor - 1]) begin
                down <= 0;
                door_open <= 1;
                timer <= 3;
                state <= DOOR;
                pending[floor - 1] <= 0;
            end
            else if (floor == target) begin
                down <= 0;
                state <= IDLE;
            end
        end

        DOOR: begin
            up <= 0;
            down <= 0;
            door_open <= 1;

            if (timer > 0)
                timer <= timer - 1;
            else begin
                door_open <= 0;
                state <= IDLE;
            end
        end

        endcase

    end
end

endmodule