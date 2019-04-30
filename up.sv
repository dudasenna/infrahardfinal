module up( //TESTE PRA VER SE PEGA
 input logic CLK, RESET
 );
wire RESET_WIRE;
wire IR_WIRE;//ok
wire LOAD_A;//ok
wire LOAD_B;//ok
wire ALU_OUT_MUX_WIRE;
wire UC_TO_OR;
wire PC_WRITE;//ok
wire BANCO_WIRE;//ok
wire LOAD_MDR;//ok
wire LOAD_ALU_OUT;//ok
wire DMEM_RW;//ok
wire IGUAL;
wire MAIOR;
wire MENOR;
wire MUX_MR_WIRE;//ok\
wire UC_TO_AND;
wire AND_TO_OR;
wire [1:0] SHIFT;
wire [1:0]ALU_SRCA;//ok
wire [2:0] ALU_SRCB;//ok
wire [2:0] ALU_SELECTOR;//ok
wire [4:0] IR19_15;//ok
wire [4:0] IR24_20;//ok
wire [4:0] IR11_7;//ok
wire [6:0] IR6_0;//ok
wire [15:0] SAIDA_ESTADO;//ok
wire [31:0] IR31_0;//ok
wire [31:0] MEM_TO_IR_32;//ok
wire [31:25]FUNCT7;
wire [14:12]FUNCT3;
wire [31:26]FUNCT6;
wire [63:0] MEM_TO_REG;//ok
wire [63:0] REGMEM_TO_MUX;
wire [63:0] MUX_TO_WRITE_DATA;
wire [63:0] ALU_OUT_TO_MUX;
wire [63:0] PC_IN;//ok
wire [63:0] PC_OUT;//ok
wire [63:0] A_IN_ALU;//ok
wire [63:0] B_IN_ALU;//ok
wire [63:0] RS1;//ok
wire [63:0] RS2;//ok
wire [63:0] REG_A_MUX;//ok
wire [63:0] REG_B_MUX;//ok
wire [63:0] SIGN_OUT;//ok
wire [63:0] SHIFT_OUT;//ok
wire [63:0] ALU_TO_OUT;

uc UC(//ok
 .CLK(CLK),//OK
 .RESET(RESET),//OK
 .ALU_SRCA(ALU_SRCA),//OK
 .ALU_SRCB(ALU_SRCB),
 .RESET_WIRE(RESET_WIRE),//OK
 .ALU_SELECTOR(ALU_SELECTOR),
 .PC_WRITE(PC_WRITE),//OK
 .DMEM_RW(DMEM_RW),//OK
 .IR_WIRE(IR_WIRE),//OK
 .IR6_0(IR6_0),//OK
 .IR11_7(IR11_7),//OK
 .IR19_15(IR19_15),//OK
 .IR24_20(IR24_20),//OK
 .IR31_0(IR31_0),//OK
 .LOAD_A(LOAD_A),//OK
 .LOAD_B(LOAD_B),//OK
 .BANCO_WIRE(BANCO_WIRE),//OK
 .LOAD_MDR(LOAD_MDR),//OK
 .IGUAL(IGUAL),
 .MENOR(MENOR),
 .SAIDA_ESTADO(SAIDA_ESTADO),
 .LOAD_ALU_OUT(LOAD_ALU_OUT),//OK
 .FUNCT7(FUNCT7),
 .FUNCT3(FUNCT3),
 .FUNCT6(FUNCT6),
 .MUX_MR_WIRE(MUX_MR_WIRE),
 .ALU_OUT_MUX_WIRE(ALU_OUT_MUX_WIRE),
 .SHIFT(SHIFT)
 );

mux4 MUX_A( //ok
 .SELETOR(ALU_SRCA),
 .A(PC_OUT),
 .B(REG_A_MUX),
 .C(64'd0),
 .D(64'd1),
 .SAIDA(A_IN_ALU)
 );

mux2 MUX_MR( //ok
 .SELETOR(MUX_MR_WIRE),
 .ENTRADA_1(ALU_OUT_TO_MUX),
 .ENTRADA_2(REGMEM_TO_MUX),
 .SAIDA(MUX_TO_WRITE_DATA)
 );

 mux2 ALU_OUT_MUX( //ok
 .SELETOR(ALU_OUT_MUX_WIRE),
 .ENTRADA_1(ALU_TO_OUT),
 .ENTRADA_2(ALU_OUT_TO_MUX),
 .SAIDA(PC_IN)
 );

mux5 MUX_B( //ok
 .SELETOR(ALU_SRCB),
 .A(REG_B_MUX),
 .B(64'd4),
 .C(SIGN_OUT),
 .D(SHIFT_OUT),
 .E(64'd0),
 .SAIDA(B_IN_ALU)
 );

ula64 ALU ( //ok
 .A(A_IN_ALU),
 .B(B_IN_ALU),
 .Seletor(ALU_SELECTOR),
 .S(ALU_TO_OUT),
 .Overflow(),
 .Negativo(),
 .z(),
 .Igual(IGUAL),
 .Maior(),
 .Menor(MENOR)
 );
 
Instr_Reg_RISC_V BANCO(//ok
 .Clk(CLK),
 .Reset(RESET),
 .Load_ir(IR_WIRE),
 .Entrada(MEM_TO_IR_32),
 .Instr19_15(IR19_15),
 .Instr24_20(IR24_20),
 .Instr11_7(IR11_7),
 .Instr6_0(IR6_0),
 .Instr31_0(IR31_0)
 );

bancoReg BANCOREG(//ok
 .write(BANCO_WIRE), //p
 .clock(CLK),
	.reset(RESET),
	.regreader1(IR19_15),
	.regreader2(IR24_20),
	.regwriteaddress(IR11_7),
	.datain(MUX_TO_WRITE_DATA),
	.dataout1(RS1),
	.dataout2(RS2)
);

Memoria32 MEMORIA32(//p
 .raddress(PC_OUT[31:0]), //endereço de ler
 .waddress(), //endereço de esrever (mem32 nunca escreve)
 .Clk(CLK),
 .Datain(),
 .Dataout(MEM_TO_IR_32),
 .Wr(0) //define se é leitura ou escrita
 );

Memoria64 MEMORIA64(//p
 .raddress(ALU_TO_OUT), //endereço de ler //PC_IN pq eh a saida do alu_out
 .waddress(ALU_TO_OUT), //endereço de escrever
 .Clk(CLK),
 .Datain(REG_B_MUX),
 .Dataout(MEM_TO_REG), //saida vai ser a entrada do memory data reg
 .Wr(DMEM_RW) //wr se for 0 le, se for 1 escreve
 );

register PC(//ok
 .clk(CLK),
 .reset(RESET),
 .regWrite(PC_WRITE),
 .DadoIn(PC_IN),
 .DadoOut(PC_OUT)
 );

register REG_A(//ok
 .clk(CLK),
 .reset(RESET),
 .regWrite(LOAD_A),
 .DadoIn(RS1),
 .DadoOut(REG_A_MUX)
 );

register REG_B(//ok
 .clk(CLK),
 .reset(RESET),
 .regWrite(LOAD_B),
 .DadoIn(RS2),
 .DadoOut(REG_B_MUX)
 );
 
SignExt SIGNEXT(//ok
 .entrada(IR31_0),
 .saida(SIGN_OUT),
 .IR6_0(IR6_0)
 );

ShiftL1 SHIFTL1(//ok
 .Shift(SHIFT),
 .Entrada(REG_A_MUX),
 .N(SIGN_OUT),
 .Saida(SHIFT_OUT)
 );


register ALU_OUT(//ok
 .clk(CLK),
 .reset(RESET),
 .regWrite(LOAD_ALU_OUT),
 .DadoIn(ALU_TO_OUT),
 .DadoOut(ALU_OUT_TO_MUX)
 );

register MEMORY_DATA_REG(//ok
 .clk(CLK),
 .reset(RESET),
 .regWrite(LOAD_MDR),
 .DadoIn(MEM_TO_REG),
 .DadoOut(REGMEM_TO_MUX)
 );

ANDY E(
.entrada_1(UC_TO_AND),
.entrada_2(IGUAL),
.saida(AND_TO_OR)
);

endmodule // up