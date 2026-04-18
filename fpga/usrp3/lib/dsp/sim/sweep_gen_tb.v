`timescale 1ns/1ps

module sweep_gen_tb();

   reg clk = 0;
   reg reset;
   reg run;
   reg triangle_sweep = 0;
   reg [31:0] start_phase_incr;
   reg [31:0] stop_phase_incr;
   reg [31:0] sweep_step;
   wire [31:0] phase_incr_sweep;

   sweep_gen sweep_gen(.clk(clk), .rst(reset),
   .run(run),
   .triangle_sweep(triangle_sweep),
   .start_phase_incr(start_phase_incr),
   .stop_phase_incr(stop_phase_incr),
   .sweep_step(sweep_step),
   .phase_incr(phase_incr_sweep)
   );


   // 10MHz master_clock_rate
   always #50 clk <= ~clk;

   initial
     begin
        start_phase_incr <= 32'h00000000;
        stop_phase_incr <= 32'h00000000;
        sweep_step <= 32'h000000000;
	reset <= 1'b0;
	run <= 0;

	@(posedge clk);
	// Into Reset...
	reset <= 1'b1;
	repeat(10) @(posedge clk);
	// .. and back out of reset.
	reset <= 1'b0;
	repeat(10) @(posedge clk);

	// Set complex data inputs to DC unit circle position.
        // Set start to -2.5MHz = +(3/4)*2^32 = 0xC000'0000;
        start_phase_incr <= 32'hC0000000;
        // Set stop to +2.5MHz = +(1/4)*2^32 = 0x4000'0000;
        stop_phase_incr <= 32'h40000000;
        // Want to have sweep complete over 256 samples, delta is 0x8000'0000
        // divide by 256 is shift by 8 bits, so 0x0080'0000
        sweep_step <= 32'h00800000;
	run <= 1'b1;
	repeat(100) @(posedge clk);

	repeat(100000) @(posedge clk);
	$finish();

     end // initial begin


endmodule //
