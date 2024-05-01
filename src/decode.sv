`default_nettype none

module instruction_decode(
  input logic[15:0] instruction,
  output dec_sig_t signals,
  output logic halt
);

  always_comb begin
    signals.opcode = opcode_t'(instruction[2:0]);
    halt = 1'b0;
    signals.rfWrite = 1'b0;
    case(signals.opcode)
      R_TYPE: begin
        signals.rs1 = instruction[5:3];
        signals.rs2 = instruction[8:6];
        signals.rd = instruction[11:9];
        signals.alu_op =  alu_op_t'(instruction[15:12]);
        signals.is_double_word = 1'b0;
        signals.rfWrite = 1'b1;
        // signals.dest = REG_FILE;
      end
      I_TYPE: begin
        signals.rs1 = instruction[5:3];
        signals.rd = instruction[11:9];
        // signals.dest = REG_FILE;
        signals.is_double_word = 1'b1;
        signals.useImm = 1'b1;
        signals.alu_op = alu_op_t'(instruction[15:12]);
        signals.rfWrite = 1'b1;
      end
      B_TYPE: begin
        signals.rs1 = instruction[5:3];
        signals.rs2 = instruction[8:6];
        signals.offset = instruction[12:9];
        signals.is_double_word = 1'b0;
        signals.b_type = br_op_t'(instruction[15:13]);
        
      end
      J_TYPE: begin
        signals.is_double_word = 1'b0;
        signals.offset = {instruction[15:12], instruction[8:4]};
        signals.jump_type = jmp_t'(instruction[6]);
        signals.rd = instruction[11:9];
      end
      M_TYPE: begin
        signals.is_double_word = 1'b1;
        signals.rd = instruction[11:9];
        signals.rs1 = instruction[5:3];
        signals.rs2 = instruction[8:6];
        signals.alu_op = ADD;
        signals.mem_op = mem_op_t'(instruction[15:12]);
        if(signals.mem_op == LW | signals.mem_op == LB | signals.mem_op == LHW) begin
          signals.rfWrite = 1'b1;
        end 
        // signals.addr_offset = instruction[31:16]; //need mar mux
        signals.useAddr = 1'b1;
      end
      SYS_END: begin
        signals.is_double_word = 1'b0;
        signals.rd = 'd0;
        signals.rs1 = 'd0;
        signals.rs2 = 'd0;
        halt = 1'b1;
      end
    endcase
  end

endmodule