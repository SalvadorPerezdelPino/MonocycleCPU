module datapath #(
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 8
	) (
	input wire clk, 
	input wire reset,
	input wire enable_pc,
	// Control del camino de datos
	input wire s_io_wr, s_addr,
	input wire [1:0] s_wd3, s_pc,
	input wire we3, wez, wes,
	// Control de la pila
	input wire push, pop,
	// ALU
	input wire [2:0] op_alu, 
	output wire z, s,
	output wire [5:0] opcode, 
	output wire [9:0] dir,
	// I/O
	input wire read, 
	input wire write, 	
	inout wire [DATA_WIDTH-1:0] bus_data, 
	output wire [ADDR_WIDTH-1:0] bus_addr
);
	
	wire [31:0] inst;
	wire [3:0] ra1, ra2, wa3;
	wire [9:0] jmp_pc, inc_pc, next_pc, ret_dir;
	wire [DATA_WIDTH-1:0] inm, alu_res, rd1, rd2, wd3, alu_inm, data_to_io, data_from_io;
	wire [7:0] inm_to_io; // No aumenta por diseño
	wire z_alu, s_alu;
	
	assign jmp_pc = inst[9:0];
	assign ra1 = inst[11:8];
	assign ra2 = inst[7:4];
	assign wa3 = inst[3:0];
	assign inm = inst[19:4];
	assign inm_to_io = inst[7:0];
	assign opcode = inst[31:26];
	
	// Mux que selecciona la próxima dirección del program counter
	mux4 #(10) mux_pc (
		.d0	(inc_pc),
		.d1	(jmp_pc),
		.d2	(ret_dir),
		.d3	(),
		.s		(s_pc),
		.y		(next_pc)
	);
	
	// Mux que selecciona el valor a almacenar en el banco de registros
	mux4 #(DATA_WIDTH) mux_reg (
		.d0	(alu_res),
		.d1	(inm),
		.d2	(data_from_io),
		.d3	(),
		.s		(s_wd3),
		.y		(wd3)
	
	);
	
	// Mux que selecciona si el dato a escribir en un dispositivo externo viene de un registro o un inmediato
	mux2 #(DATA_WIDTH) mux_to_io (
		.d0 (rd2),
		.d1 ({8'b0, inm_to_io}),
		.s (s_io_wr),
		.y (data_to_io)
	);
	
	mux2 #(ADDR_WIDTH) mux_addr (
		.d0 ({{ADDR_WIDTH-DATA_WIDTH{1'b0}}, rd1}), // Rellena con 0
		.d1 (inst[27:8]),
		.s  (s_addr),
		.y  (bus_addr)
	);
	
	// Program counter 
	registro #(10) pc (
		.clk	 	(clk), 
		.reset 	(reset), 
		.enable	(enable_pc),
		.d		 	(next_pc), 
		.q		 	(dir)
	);
	
	// Incrementa el program counter para la siguiente instrucción
	sum sum_pc (
		.a	(10'b0000000001), 
		.b	(dir), 
		.y	(inc_pc)
	);
	
	// Memoria que contiene el programa
	localparam PROGFILE = "C:/Users/Usuario/Documents/clase/inf/tercero/2Q/diseno_de_procesadores/CPUsimple/progfile.dat";
	program_memory progmem (
		.clk (clk), 
		.addr   (dir), 
		.inst  (inst)
	);
	
	// Banco de registros
	regfile #(DATA_WIDTH) banco_reg	(
		.clk (clk), 
		.we3 (we3), 
		.ra1 (ra1), 
		.ra2 (ra2), 
		.wa3 (wa3), 
		.wd3 (wd3), 
		.rd1 (rd1), 
		.rd2 (rd2)
	); 

	// ALU para operaciones
	alu alu1 (
		.a      (rd1), 
		.b      (rd2), 
		.op_alu (op_alu), 
		.y      (alu_res), 
		.zero   (z_alu),
		.sign   (s_alu)
	);
				 
	// Flag de cero en las operaciones ALU
	ffd ffz (
		.clk	 (clk), 
		.reset (reset), 
		.d		 (z_alu), 
		.carga (wez), 
		.q		 (z)
	);
	
	// Flag de signo en las operaciones ALU
	ffd ffs (
		.clk	 (clk), 
		.reset (reset), 
		.d		 (s_alu), 
		.carga (wes), 
		.q		 (s)
	);
	
	// Driver de acceso al bus de datos y direcciones
	cd_io cd_io0 (
		.bus_data		(bus_data),
		.data_from_cpu	(data_to_io),
		.data_to_cpu	(data_from_io),
		.write			(write),
		.read			   (read)
	);
	
	// Pila de direcciones para subrutinas
	stack stack0 (
		.push			(push),
		.pop			(pop),
		.clk			(clk),
		.in_data		(inc_pc),
		.out_data	(ret_dir)
	);
		
endmodule
