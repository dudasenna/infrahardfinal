
module mux5(
	input logic [2:0] SELETOR,
	input logic [63:0]A, B, C, D, E,
	output logic [63:0] SAIDA
	);

	always_comb
			case(SELETOR)
				0: SAIDA=A;
				1: SAIDA=B;
				2: SAIDA=C;
				3: SAIDA=D;
				4: SAIDA=E;
			endcase 
endmodule
