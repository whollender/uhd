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

   wire [31:0] start_shift;
   wire [31:0] stop_shift;
	assign start_shift = {~start_phase_incr[31], start_phase_incr[30:0]};
   assign stop_shift = {~stop_phase_incr[31], stop_phase_incr[30:0]};

   reg [31:0] phase_incr_sweep;
   reg neg_sweep = 1'b0;
	reg counter_rst = 1'b1;
	
	always @(posedge clk)
	if (rst) begin
		neg_sweep <= 1'b0;
		counter_rst <= 1'b1;
	end else if (~run) begin
		neg_sweep <= 1'b0;
		counter_rst <= 1'b1;
	end else if (phase_incr_sweep < start_shift) begin
		neg_sweep <= 1'b0;
		counter_rst <= 1'b0;
	end else if (phase_incr_sweep >= stop_shift) begin
		if (triangle_sweep) begin
			neg_sweep <= 1'b1;
			counter_rst <= 1'b0;
		end else begin
			neg_sweep <= 1'b0;
			counter_rst <= 1'b1;
		end
	end else begin
		neg_sweep <= neg_sweep;
		counter_rst <= 1'b0;
	end
	
   always @(posedge clk)
      if(rst) begin
			phase_incr_sweep <= 0;
      end else if(counter_rst) begin
			phase_incr_sweep <= start_shift;
      end else begin
			if (neg_sweep) begin
				phase_incr_sweep <= phase_incr_sweep - sweep_step;
			end else begin
				phase_incr_sweep <= phase_incr_sweep + sweep_step;
			end
		end

// Invert MSB to shift from -Fs/2 -> Fs/2 to 0 -> Fs
assign phase_incr = {~phase_incr_sweep[31], phase_incr_sweep[30:0]};

endmodule
