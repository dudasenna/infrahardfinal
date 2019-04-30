module ANDY(
	input logic entrada_1,
	input logic entrada_2,
	output logic saida
);
always_comb
	begin
		case(entrada_1)
			1:
				begin
					case(entrada_2)
						1:
							begin
								saida=1;
							end
						0:
							begin
								saida=0;
							end
					endcase
				end
			0:
				begin
					case(entrada_2)
						1:
							begin
								saida=0;
							end
						0:
							begin
								saida=0;
							end
					endcase
				end
		endcase
	end
endmodule