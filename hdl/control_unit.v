module control_unit (
	input wire [5:0] opcode, 
	input wire zero, sign, carry, overflow, 
	output reg s_addr, s_io_wr, we3, we_flags, push, pop,
	output reg [1:0] s_wd3, s_pc,
	output reg [2:0] op_alu, 
	output reg read, 
	output reg write,
	output reg halted,
	output reg enable_pc
);

	localparam HALT = 6'b000001;
	localparam NOP = 6'b000000;
	localparam ALU = 6'b111???;
	localparam J = 6'b110000;
	localparam JG = 6'b110001;
	localparam JAL = 6'b110101;
	localparam JR = 6'b11011?;
	localparam JZ = 6'b110011;
	localparam JNZ = 6'b110010;
	localparam LDI = 6'b101000;
	localparam LD = 6'b1011??;
	localparam LD_R = 6'b101011;
	localparam STR_R = 6'b101010;
	localparam STR = 6'b1000??;
	localparam STI = 6'b1001??;
	localparam JG_S = 6'b110100;
	
	always @* begin
		casez(opcode)
			HALT: begin
				s_pc <= 2'b00;
				s_wd3 <= 2'b00;
				s_io_wr <= 1'b0;
				s_addr <= 1'b0;
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b00;
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b1;
				enable_pc <= 1'b0;
			end
			
			ALU: begin // ALU
				s_pc <= 2'b00;
				s_wd3 <= 2'b00;
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b1;
				we_flags <= 1'b1;
				op_alu <= opcode[2:0];
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end

			J: begin // J
				s_pc <= 2'b01;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000;
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			JG: begin // JG
				s_pc <= (~zero && ~sign) ? 2'b01 : 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; //don't care
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			JG_S: begin // JG Signed
				s_pc <= (~zero && ~(sign ^ overflow)) ? 2'b01 : 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; //don't care
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			JAL: begin // JAL
				s_pc <= 2'b01;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000;
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b1;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			JR: begin // JR
				s_pc <= 2'b10;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000;
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b1;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			JZ: begin // JZ
				s_pc <= zero ? 2'b01 : 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; //don't care
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			JNZ: begin // JNZ
				s_pc <= zero ? 2'b00 : 2'b01;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			LDI: begin // LDI
				s_pc <= 2'b00;
				s_wd3 <= 2'b01; 
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0; // don't care
				we3 <= 1'b1;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			LD: begin // LD -> carga lo que hay una dirección inmediata en un registro
				s_pc <= 2'b00;
				s_wd3 <= 2'b10; 
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b1;
				we3 <= 1'b1;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b1;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			LD_R: begin // LD -> carga lo que hay una dirección DENTRO DE UN REGISTRO en otro registro
				s_pc <= 2'b00;
				s_wd3 <= 2'b10; 
				s_io_wr <= 1'b0; // don't care
				s_addr <= 1'b0;
				we3 <= 1'b1;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b1;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			STR_R: begin // STR de registro a memoria en un registro
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0;
				s_addr <= 1'b0;
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b0;
				write <= 1'b1;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			STR: begin // STR
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; // don't care
				s_io_wr <= 1'b0;
				s_addr <= 1'b1;
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b0;
				write <= 1'b1;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
			
			STI: begin // STI
				s_pc <= 2'b00;
				s_wd3 <= 2'b10; // don't care
				s_io_wr <= 1'b1;
				s_addr <= 1'b1;
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000; // don't care
				read <= 1'b0;
				write <= 1'b1;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
		
			default begin
				s_pc <= 2'b00;
				s_wd3 <= 2'b00; 
				s_io_wr <= 1'b0;
				s_addr <= 1'b0;
				we3 <= 1'b0;
				we_flags <= 1'b0;
				op_alu <= 3'b000;
				read <= 1'b0;
				write <= 1'b0;
				push <= 1'b0;
				pop <= 1'b0;
				halted <= 1'b0;
				enable_pc <= 1'b1;
			end
		endcase
	end

endmodule