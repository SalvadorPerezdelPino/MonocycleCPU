module cpu #(
	parameter ADDR_WIDTH = 20,
	parameter DATA_WIDTH = 16
	) (
	input wire clk, reset, 
	output wire [9:0] pc, 
	output wire [5:0] opcode,
	inout wire [DATA_WIDTH-1:0] bus_data, 
	output wire [ADDR_WIDTH-1:0] bus_addr, 
	output wire read, 
	output wire write,
	output wire halted,
	output reg [DATA_WIDTH-1:0] solution
);
	 

	wire z, s;
	wire s_io_wr, s_addr;
	wire [1:0] s_wd3, s_pc;
	wire push, pop;
	wire enable_pc;
	wire we3, wez, wes;
	wire [2:0] op_alu;
	//wire [5:0] opcode;

	control_unit cu1 (
		.opcode 		(opcode), 
	   .z      		(z),
		.s				(s),
	   .s_pc  		(s_pc), 
		.s_wd3 		(s_wd3),
		.s_io_wr 	(s_io_wr),
		.s_addr		(s_addr),
	   .we3    		(we3), 
	   .wez    		(wez), 
		.wes			(wes),
	   .op_alu 		(op_alu),
		.read	  		(read),
		.write  		(write),
		.push			(push),
		.pop			(pop),
		.halted		(halted),
		.enable_pc	(enable_pc)
	);
			  
	datapath #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
		) dp1 (
		.clk      	(clk),
		.reset    	(reset),
		.enable_pc	(enable_pc),
		.s_pc    	(s_pc),
		.s_wd3   	(s_wd3),
		.s_io_wr   	(s_io_wr),
		.s_addr		(s_addr),
		.read		 	(read),
		.write	 	(write),
		.push			(push),
		.pop			(pop),
		.we3      	(we3),
		.wez     	(wez),
		.wes			(wes),
		.op_alu   	(op_alu), 
		.z      	 	(z), 
		.s				(s),
		.opcode 	 	(opcode), 
		.dir    	 	(pc),
		.bus_data 	(bus_data),
		.bus_addr 	(bus_addr)
	);
	
	always @(posedge clk, posedge reset) begin
		if (reset) begin
			solution <= 0;
		end
		else if (write) begin
			solution <= bus_data;
		end
	end
	
endmodule
