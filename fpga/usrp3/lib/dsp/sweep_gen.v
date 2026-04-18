// Simple sweep gen
// Generate swept phase increment values for NCO

module sweep_gen
  (input clk, input rst,
   input run,
   input triangle_sweep,
   input [31:0] start_phase_incr,
   input [31:0] stop_phase_incr,
   input [31:0] sweep_step,
   output [31:0] phase_incr
   );

   wire [31:0] start_shift = {~start_phase_incr[31], start_phase_incr[30:0]};
   wire [31:0] stop_shift = {~stop_phase_incr[31], stop_phase_incr[30:0]};

   reg [31:0] phase_incr_sweep;
   reg pos_sweep;
   always @(posedge clk)
      if(rst) begin
	 phase_incr_sweep <= 0;
	 pos_sweep <= 1'b1;
      end else if(~run) begin
	 phase_incr_sweep <= start_shift;
	 pos_sweep <= 1'b1;
      end else begin
	 if(phase_incr_sweep >= stop_shift) begin
	    phase_incr_sweep <= start_shift;
	 end else begin
	    phase_incr_sweep <= phase_incr_sweep + sweep_step;
		 end
		 end

// Invert MSB to shift from -Fs/2 -> Fs/2 to 0 -> Fs
assign phase_incr = {~phase_incr_sweep[31], phase_incr_sweep[30:0]};

endmodule
