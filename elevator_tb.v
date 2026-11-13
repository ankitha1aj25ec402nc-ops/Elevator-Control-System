module tb_elevator;

reg clk;
reg reset;
reg [3:0] request;

wire [1:0] floor;
wire up, down, door_open;

elevator uut (
    .clk(clk),
    .reset(reset),
    .request(request),
    .floor(floor),
    .up(up),
    .down(down),
    .door_open(door_open)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Monitor output
initial begin
    $monitor("Time=%0t | Request=%b | Floor=%d | UP=%b | DOWN=%b | DOOR=%b",
             $time, request, floor, up, down, door_open);
end

initial begin

    $dumpfile("elevator.vcd");
    $dumpvars(0, tb_elevator);

    reset = 1;
    request = 4'b0000;

    #20;
    reset = 0;

    // Request floor 2
    #10;
    request = 4'b0100;

    #10;
    request = 4'b0000;

    // Wait for elevator to reach floor 2
    wait(floor == 2 && door_open == 1);
    $display("Elevator reached Floor 2");

    #50;

    // Request floor 3
    request = 4'b1000;
    #10;
    request = 4'b0000;

    wait(floor == 3 && door_open == 1);
    $display("Elevator reached Floor 3");

    #50;

    // Request Ground floor
    request = 4'b0001;
    #10;
    request = 4'b0000;

    wait(floor == 0 && door_open == 1);
    $display("Elevator reached Ground Floor");

    #50;

    $display("Elevator Test Completed");

    $finish;

end

endmodule