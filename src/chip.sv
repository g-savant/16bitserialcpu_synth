`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    
    // Basic counter design as an example

    RangeFinder#(10) rf(.data_in(io_in[9:0]),
                        .clock,
                        .reset,
                        .go(io_in[11]),
                        .finish(io_in[10]),
                        .range(io_out[9:0],
                        .debug_error(io_out[11])));

endmodule


module RangeFinder
  #(parameter WIDTH=16)
  (input logic [WIDTH-1:0] data_in,
  input logic clock, reset,
  input logic go, finish,
  output logic [WIDTH-1:0] range,
  output logic debug_error);



  logic[WIDTH-1:0] max_val, min_val;

  logic going;

  always_ff @(posedge clock, posedge reset) begin
    if(reset) begin
      going <= 1'b0;
      min_val <= 'd0;
      max_val <= 'd0;
      debug_error <= 1'b0;
    end else begin
      if(go | going) begin
        if(go & ~going) begin
          if(finish) debug_error <= 1'b1;
          else begin
            max_val <= data_in;
            min_val <= data_in;
            debug_error <= 1'b0;
            going <= 1'b1;
          end
        end else begin
          if(finish) going <= 1'b0;
          else going <= 1'b1;
          if(data_in < min_val) min_val <= data_in;
          else min_val <= min_val;
          if(data_in > max_val) max_val <= data_in;
          else max_val <= max_val;
        end
      end else begin
        if(~going & finish) debug_error <= 1'b1;
        min_val <= min_val;
        max_val <= max_val;
        going <= 1'b0;
      end
    end
  end

  always_comb begin
    if(data_in < max_val & data_in > min_val) range = max_val - min_val;
    else if(data_in < max_val & data_in < min_val) range = max_val - data_in;
    else if(data_in > max_val & data_in > min_val) range = data_in - min_val;
    else if(data_in > max_val & data_in < min_val) range = max_val - min_val;
  end


endmodule