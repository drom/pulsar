module pulsar (clk, drv);

input clk /* synthesis chip_pin = "R8" */;
output drv /* synthesis chip_pin = "B5" */ ; // JP1.10 GPIO_07

// clk = 50MHz (20ns)
// run[0] = 25MHz (40ns)
// run[1] = 12.5MHz (80ns)
// run[2] = 6.25MHz (160ns)
// run[3] = 3.125MHz (320ns)
// run[4] = 1.5625MHz (640ns)
// run[5] = 0.78125MHz (1.28us)

// 40KHz = 25us (1250 clocks)
// 625 + 625
// /```\___/

// _/`0`\_1_/`2`\_3_/`4`\_5_...

reg [31:0] run; // free running counter
reg [31:0] mem [0:255]; // pulse sequence array
reg [31:0] limit;
reg [31:0] timer;
reg [7:0] pointer; // pointer
reg start; // start condition
reg prestart; // pre-history for the start condition

initial begin
    $readmemh("ram.txt", mem);
end

always @ (*) limit = mem[pointer];

always @ (posedge clk) run <= run + 1;

// repeat after ~84ms (4 Mcycles)

always @ (posedge clk) prestart <= run[23];

always @ (*) start = ~prestart & run[23]; // __/``` posedge detector


always @ (posedge clk)
    if (start) begin
        pointer <= 0;
        timer <= 0; // initial load
    end else begin
        if (timer == 0) begin
            timer <= limit;
            pointer <= pointer + 1;
        end else begin
            timer = timer - 1;
        end
    end

assign drv = pointer[0];

endmodule
