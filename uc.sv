module uc(
  input logic CLK,//ok
  input logic RESET,//ok
  input logic IGUAL, MENOR,
  input logic [31:0] IR31_0,//ok
  input logic [4:0] IR11_7, IR19_15, IR24_20,//ok
  input logic [6:0] IR6_0,//ok
  output logic RESET_WIRE, PC_WRITE, IR_WIRE, LOAD_A, LOAD_B, BANCO_WIRE, LOAD_ALU_OUT, LOAD_MDR, DMEM_RW, MUX_MR_WIRE , ALU_OUT_MUX_WIRE,
  output logic [2:0] ALU_SELECTOR,
  output logic [6:0] ESTADO_ATUAL,
  output logic [1:0] ALU_SRCA, SHIFT,
  output logic [2:0] ALU_SRCB,
  output logic [15:0] SAIDA_ESTADO,
  output logic [31:25] FUNCT7,
  output logic [31:26] FUNCT6,
  output logic [14:12] FUNCT3
 );

 enum logic [15:0]{
  RESET_ESTADO,//0
  BUSCA,//1
  SOMA,//2
  DECODE,//3
  R,//4
  SLT2,SLT3,//5
  R2,//6
  I1, I2,//7 8 
  LD2,LD3,LD4,//9
  S,//10
  SD2, SD3,//11 12
  BEQ1, BEQ2,//13 14
  BNE2,//15
  BGE, BGE2,//16 17
  BLT, BLT2,//18 19
  JALR_SB,//20 
  LUI, //21
  JAL,//22
  JALR2, JALR3,//23 24
  BREAK//25
  
 }ESTADO, PROX_ESTADO;
 
 always_ff@(posedge CLK, posedge RESET)
 begin
  if(RESET)
  begin
   ESTADO<=RESET_ESTADO;
  end
  else 
  begin
   ESTADO<=PROX_ESTADO;
  end
 end
 
 assign ESTADO_ATUAL = ESTADO;
 assign FUNCT7 = IR31_0[31:25];
 assign FUNCT6 = IR31_0[31:26];
 assign FUNCT3 = IR31_0[14:12];
 
 always_comb 
 case(ESTADO)
  RESET_ESTADO:
  begin
   SAIDA_ESTADO = 0;
   PC_WRITE = 0;
   RESET_WIRE = 1;
   ALU_SRCA = 0;
   ALU_SRCB = 0;
   ALU_SELECTOR = 0;
   LOAD_ALU_OUT = 0; //FALTA DECLARAR NA UP
   DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC
   IR_WIRE = 0;
   LOAD_A = 0;
   LOAD_B = 0;
   MUX_MR_WIRE = 0;
   LOAD_MDR = 0;
   BANCO_WIRE = 0;
   SHIFT= 0;
   ALU_OUT_MUX_WIRE=0;
   SHIFT= 0;
   
   PROX_ESTADO = BUSCA;
  end
  
  BUSCA:
  //nao esta buscando certo
  begin
   SAIDA_ESTADO = 1;
   PC_WRITE = 0;
   RESET_WIRE = 0;
   ALU_SRCA = 0;
   ALU_SRCB = 0;
   ALU_SELECTOR = 0;
   LOAD_ALU_OUT = 0; //FALTA DECLARAR NA UC
   DMEM_RW = 0; //0 => READ, 1 => WRITE FALTA DECLARAR NA UC//?
   IR_WIRE = 1;
   LOAD_A = 0;
   LOAD_B = 0;
   MUX_MR_WIRE = 0;
   LOAD_MDR = 0;
   BANCO_WIRE = 0;
   SHIFT= 0;
   ALU_OUT_MUX_WIRE=0; 
   PROX_ESTADO = SOMA;
  end
 
  SOMA:
  begin
   SAIDA_ESTADO = 2;
   PC_WRITE = 1;
   RESET_WIRE = 0;
   ALU_SRCA = 0;
   ALU_SRCB = 1;
   ALU_SELECTOR = 1;
   LOAD_ALU_OUT = 0; 
   DMEM_RW = 0; 
   IR_WIRE = 1;
   LOAD_A = 0;
   LOAD_B = 0;
   MUX_MR_WIRE = 0;
   LOAD_MDR = 0;
   BANCO_WIRE = 0;
   SHIFT= 0;
   ALU_OUT_MUX_WIRE = 0;
   PROX_ESTADO = DECODE;
  end
  
  DECODE:
  begin
   IR_WIRE = 0;
   PC_WRITE = 0;
   SAIDA_ESTADO = 3;
   RESET_WIRE = 0;
   ALU_SRCA = 0; 
   ALU_SRCB = 0; 
   ALU_SELECTOR = 0; 
   LOAD_ALU_OUT = 0;
   DMEM_RW = 0; 
   LOAD_A = 1;
   LOAD_B = 1; 
   MUX_MR_WIRE = 0;
   LOAD_MDR = 0;
   BANCO_WIRE = 0;
   SHIFT= 0;
   ALU_OUT_MUX_WIRE=0;
   

    case(IR6_0)//LER OPCODE

      51: //ADD, SUB, AND, SLT LEMBRAR QUE O OPCODE ESTA MODIFICADO
        begin//ok
          PROX_ESTADO = R;
        end

      19: //ADDI, SLTI E NOP E 'SHIFTS
        begin//ok
          PROX_ESTADO = I1;
        end 

      3: //LB, LH, LW, LD, LBU, LHU, LWU
        begin//ok
          PROX_ESTADO = I2;
        end

       115: //BREAK
         begin
          PROX_ESTADO = BREAK;
         end

      35: //TIPO S
       begin
          PROX_ESTADO = S;
       end 

      99: //BEQ1
       begin
          PROX_ESTADO = BEQ1;
       end

      103: //JALR E TIPO SB
       begin
          PROX_ESTADO = JALR_SB;
       end

      55: //LUI
       begin
          PROX_ESTADO = LUI;
       end

      111: //JAL
        begin
          PROX_ESTADO = JAL;
        end

      default:
        begin
          PROX_ESTADO = RESET_ESTADO;//O CODIGO ESTA ENTRANDO NESSE default (nao reconhece o opcode)
        end
    endcase
  end
  
  R: 
   begin
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 1; //SELECIONA O REG_A_MUX
    ALU_SRCB = 0; //SELECIONA O REG_B_MUX
      case(FUNCT3)
        0: // ADD E SUB
          case(FUNCT7)
          0: //ADD

            begin
              SAIDA_ESTADO = 4;
              ALU_SELECTOR = 1; //SOMA 001        
              LOAD_ALU_OUT = 1;
              DMEM_RW = 0; //0 => READ, 1 => WRITE 
              IR_WIRE = 0;
              LOAD_A = 0;
              LOAD_B = 0; 
              MUX_MR_WIRE = 0;
              LOAD_MDR = 0;
              BANCO_WIRE = 0;
              SHIFT= 0;
              ALU_OUT_MUX_WIRE=0;
              PROX_ESTADO = R2;      
            end

          32: //SUB

             begin
              SAIDA_ESTADO = 5;
              ALU_SELECTOR = 2; //SUB 010
              LOAD_ALU_OUT = 1;
              DMEM_RW = 0; //0 => READ, 1 => WRITE 
              IR_WIRE = 0;
              LOAD_A = 0;
              LOAD_B = 0; 
              MUX_MR_WIRE = 0;
              LOAD_MDR = 0;
              BANCO_WIRE = 0;
              SHIFT= 0;
              ALU_OUT_MUX_WIRE=0;
              
              PROX_ESTADO = R2;
             end
          endcase
        7: //AND
        	begin
              SAIDA_ESTADO = 6;
              ALU_SELECTOR = 3; //SOMA 001        
              LOAD_ALU_OUT = 1;
              DMEM_RW = 0; //0 => READ, 1 => WRITE 
              IR_WIRE = 0;
              LOAD_A = 0;
              LOAD_B = 0; 
              MUX_MR_WIRE = 0;
              LOAD_MDR = 0;
              BANCO_WIRE = 0;
              SHIFT= 0;
              ALU_OUT_MUX_WIRE=0;
              PROX_ESTADO = R2;      
            end
        2: //SLT
          begin
            SAIDA_ESTADO =7;
            PC_WRITE = 0;
            RESET_WIRE = 0;
            ALU_SRCA = 1;
            ALU_SRCB = 0;
            ALU_SELECTOR = 7;
            LOAD_ALU_OUT = 0; 
            DMEM_RW = 0; //0 => READ, 1 => WRITE 
            IR_WIRE= 0 ;
            LOAD_A = 0;
            LOAD_B = 0;
            MUX_MR_WIRE = 0;
            LOAD_MDR = 0;
            BANCO_WIRE = 0;
            SHIFT= 0;
            ALU_OUT_MUX_WIRE=0;
            //COMPARACAO FEITA, VALOR DEVE PASSAR PARA RD
			 if (MENOR)
			        begin
			          PROX_ESTADO = SLT2;
			        end

			      else
			        begin
			          PROX_ESTADO = SLT3;
			        end
          end

      endcase

   end
  SLT2:
    begin
     	SAIDA_ESTADO = 80;
        PC_WRITE = 0;
        RESET_WIRE = 0;
        ALU_SRCA = 3;
        ALU_SRCB = 4;
        ALU_SELECTOR = 1;
        LOAD_ALU_OUT = 1;
        DMEM_RW =0;
        IR_WIRE = 0;
        LOAD_A = 0;
        LOAD_B = 0;
        MUX_MR_WIRE = 0;
        LOAD_MDR = 0;
        BANCO_WIRE = 1;
        ALU_OUT_MUX_WIRE=0;
        SHIFT= 0;
        PROX_ESTADO = R2;

    end
      SLT3: //TESTE PRA VER SE PEGA 
    begin
     	SAIDA_ESTADO = 90;
        PC_WRITE = 0;
        RESET_WIRE = 0;
        ALU_SRCA = 2;
        ALU_SRCB = 4;
        ALU_SELECTOR = 1;
        LOAD_ALU_OUT = 1;
        DMEM_RW =0;
        IR_WIRE = 0;
        LOAD_A = 0;
        LOAD_B = 0;
        MUX_MR_WIRE = 0;
        LOAD_MDR = 0;
        BANCO_WIRE = 1;
        ALU_OUT_MUX_WIRE=0;
        SHIFT= 0;
        PROX_ESTADO = R2;

    end

 R2:
    begin
      SAIDA_ESTADO = 10;
      PC_WRITE = 0;
      RESET_WIRE = 0;
      ALU_SRCA = 0;
      ALU_SRCB = 0;
      ALU_SELECTOR = 0;
      LOAD_ALU_OUT = 0;
      DMEM_RW = 0;
  
      IR_WIRE = 0;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      LOAD_MDR = 0;
      BANCO_WIRE = 1;
      ALU_OUT_MUX_WIRE=0;
      SHIFT= 0;
      
      PROX_ESTADO = BUSCA;
    end

  I1: // ************* TA FALTANDO O 'NOP' **************
  begin
  case(FUNCT3)
    0: //ADDI

      begin
        SAIDA_ESTADO = 11;
        PC_WRITE = 0;
        RESET_WIRE = 0;
        ALU_SRCA = 1;
        ALU_SRCB = 2;
        ALU_SELECTOR = 1;
        LOAD_ALU_OUT = 1;
        DMEM_RW =0;
    
        IR_WIRE = 0;
        LOAD_A = 0;
        LOAD_B = 0;
        MUX_MR_WIRE = 0;
        LOAD_MDR = 0;
        BANCO_WIRE = 1;
        ALU_OUT_MUX_WIRE=0;
        
        SHIFT= 0;
        PROX_ESTADO = BUSCA;
      end

    2: //SLTI
      begin
       PC_WRITE = 0;
        SAIDA_ESTADO =12;
        RESET_WIRE = 0;
        ALU_SRCA = 1;
        ALU_SRCB = 2;
        ALU_SELECTOR = 7;
        LOAD_ALU_OUT = 0; 
        DMEM_RW = 0; //0 => READ, 1 => WRITE 
        IR_WIRE= 0 ;
        LOAD_A = 0;
        LOAD_B = 0;
        MUX_MR_WIRE = 0;
        LOAD_MDR = 0;
        BANCO_WIRE = 0;
        SHIFT= 3;
        ALU_OUT_MUX_WIRE=0;
            //COMPARACAO FEITA, VALOR DEVE PASSAR PARA RD
                   if (MENOR)
                          begin
                            PROX_ESTADO = SLT2;
                          end

                        else
                          begin
                            PROX_ESTADO = SLT3;
                          end
      end

    5:
      begin
        //SRLI E SRAI
        case(FUNCT6) //FUNCT6 SÃO OS ULTIMOS 6 BITS
          0: //SRLI
            begin
            end

          16: //SRAI
            begin
            end

        endcase
      end
    1: //SLLI
      begin
      end

  endcase
  end

  

  I2:
  begin
    case(FUNCT3)
    /*0: //LB
      begin
      end

    1: //LH
      begin
      end

    2: //LW
      begin
      end
    */

    3: //LD
      begin
        SAIDA_ESTADO = 13;
        PC_WRITE = 0;
        RESET_WIRE = 0;
        ALU_SRCA = 1;
        ALU_SRCB = 2;
        ALU_SELECTOR = 1;
        LOAD_ALU_OUT = 0;
        DMEM_RW = 0;
    
        IR_WIRE = 0;
        LOAD_A = 0;
        LOAD_B = 0;
        MUX_MR_WIRE = 0;
        LOAD_MDR = 0;
        BANCO_WIRE = 0;
        ALU_OUT_MUX_WIRE=0;
        SHIFT= 0;
        
        PROX_ESTADO = LD2;
     end
  

    4: //LBU
      begin
      end

    5: //LHU
      begin
      end

    6: //LWU
      begin
      end

  endcase
  end

  LD2:

   begin
    SAIDA_ESTADO = 14;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 0;
    ALU_SRCB = 0;
    ALU_SELECTOR = 0;
    LOAD_ALU_OUT = 0; 
    DMEM_RW = 0; 

    IR_WIRE =0 ;
    LOAD_A = 0;
    LOAD_B = 0;
    MUX_MR_WIRE = 0;
    LOAD_MDR = 1;
    BANCO_WIRE = 0;
    ALU_OUT_MUX_WIRE=0;
    SHIFT= 0;
    
    PROX_ESTADO = LD3;
   end
  
  LD3:

   begin
    SAIDA_ESTADO = 15;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 0;
    ALU_SRCB = 0;
    ALU_SELECTOR = 0;
    LOAD_ALU_OUT = 0; 
    DMEM_RW = 0; //0 => READ, 1 => WRITE 

    IR_WIRE= 0 ;
    LOAD_A = 0;
    LOAD_B = 0;
    MUX_MR_WIRE = 1;
    LOAD_MDR = 0;
    BANCO_WIRE = 1;
    ALU_OUT_MUX_WIRE=0;
    SHIFT= 0;
    
    PROX_ESTADO = BUSCA;
   end

  
     LD4:
      begin
       SAIDA_ESTADO = 16;
        PC_WRITE= 0;
       RESET_WIRE = 0;
       ALU_SRCA = 0;
       ALU_SRCB = 0;
       ALU_SELECTOR = 0;
       LOAD_ALU_OUT = 0; 
       DMEM_RW = 0; //0 => READ, 1 => WRITE 
       IR_WIRE= 0 ;
       LOAD_A = 0;
       LOAD_B = 0;
       MUX_MR_WIRE = 1;
       LOAD_MDR = 0;
       BANCO_WIRE = 1;
       ALU_OUT_MUX_WIRE=0;
       SHIFT= 0;
       
       PROX_ESTADO = BUSCA;
      end

  
  
  S:
  begin
  case(FUNCT3)
    7: //SD
    begin
      SAIDA_ESTADO = 17;
      PC_WRITE = 0;
      RESET_WIRE = 0;
      ALU_SRCA = 1;
      ALU_SRCB = 2;
      ALU_SELECTOR = 1;
      LOAD_ALU_OUT = 1;
      DMEM_RW = 0;
      IR_WIRE = 0;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      LOAD_MDR = 0;
      BANCO_WIRE = 0;
      ALU_OUT_MUX_WIRE=0;
      SHIFT= 0;
      
      PROX_ESTADO = SD2;
    end

    2: //SW
      begin
      end

    1: //SH
      begin
      end

    0: //SB
      begin
      end

  endcase
  end
SD2:

   begin
    SAIDA_ESTADO = 18;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 0;
    ALU_SRCB = 0;
    ALU_SELECTOR = 0;
    LOAD_ALU_OUT = 0; 
    DMEM_RW = 1; //0 => READ, 1 => WRITE 
    IR_WIRE = 0;
    IR_WIRE = 0;
    LOAD_A = 0;//0
    LOAD_B = 0;//0
    MUX_MR_WIRE = 0;
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    ALU_OUT_MUX_WIRE=0;
    SHIFT= 0;
    PROX_ESTADO = SD3;
   end

  SD3:

   begin
    SAIDA_ESTADO = 19;
    PC_WRITE = 0;
    RESET_WIRE = 0;
    ALU_SRCA = 0;//?
    ALU_SRCB = 0;//?
    ALU_SELECTOR = 0;//?
    LOAD_ALU_OUT = 0; //?
    DMEM_RW = 0; //0 => READ, 1 => WRITE 
    IR_WIRE = 0;//era 0
    IR_WIRE = 0;
    LOAD_A = 0;//0
    LOAD_B = 0;//0
    MUX_MR_WIRE = 0;
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    SHIFT= 0;
    ALU_OUT_MUX_WIRE=0;
    
    PROX_ESTADO = BUSCA;
   end

  BEQ1:
    begin
      SAIDA_ESTADO = 20;
      PC_WRITE = 0;
      RESET_WIRE = 0;
      ALU_SRCA = 1;
      ALU_SRCB = 0;
      ALU_SELECTOR = 7;
      LOAD_ALU_OUT = 0; 
      DMEM_RW = 0; //0 => READ, 1 => WRITE 
  
      IR_WIRE= 0 ;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      LOAD_MDR = 0;
      BANCO_WIRE = 0;
      SHIFT= 0;
      ALU_OUT_MUX_WIRE=0;
       
      if (IGUAL)
        begin
          PROX_ESTADO = BEQ2;
        end

      else
        begin
          PROX_ESTADO = BUSCA;
        end
    end

BEQ2:
  begin
    SAIDA_ESTADO = 21;
    PC_WRITE = 1;
    RESET_WIRE = 0;
    ALU_SRCA = 0;
    ALU_SRCB = 2;
    ALU_SELECTOR = 1;
    LOAD_ALU_OUT = 0; 
    DMEM_RW = 0; //0 => READ, 1 => WRITE 
    IR_WIRE= 0 ;
    LOAD_A = 0;
    LOAD_B = 0;
    MUX_MR_WIRE = 0;
    LOAD_MDR = 0;
    BANCO_WIRE = 0;
    ALU_OUT_MUX_WIRE=0;
    SHIFT= 0;
    PROX_ESTADO = BUSCA;
  end


  JALR_SB:
  begin
    case(FUNCT3)
     1: //BNE
      begin
        SAIDA_ESTADO = 22;
        PC_WRITE = 0;
        RESET_WIRE = 0;
        ALU_SRCA = 1;
        ALU_SRCB = 0;
        ALU_SELECTOR = 7;
        LOAD_ALU_OUT = 0; 
        DMEM_RW = 0; //0 => READ, 1 => WRITE 
        IR_WIRE= 0 ;
        LOAD_A = 0;
        LOAD_B = 0;
        MUX_MR_WIRE = 0;
        LOAD_MDR = 0;
        BANCO_WIRE = 0;
        SHIFT= 0;
        ALU_OUT_MUX_WIRE=0;
        
        if (!IGUAL)
          begin
            PROX_ESTADO = BNE2;
          end

        else
          begin
            PROX_ESTADO = BUSCA;
          end     
      end

      5: //BGE
        begin
          SAIDA_ESTADO = 23;
          PC_WRITE = 0;
          RESET_WIRE = 0;
          ALU_SRCA = 1;
          ALU_SRCB = 0;
          ALU_SELECTOR = 7;
          LOAD_ALU_OUT = 0; 
          DMEM_RW = 0; //0 => READ, 1 => WRITE 
          IR_WIRE= 0 ;
          LOAD_A = 0;
          LOAD_B = 0;
          MUX_MR_WIRE = 0;
          LOAD_MDR = 0;
          BANCO_WIRE = 0;
          SHIFT= 0;
          ALU_OUT_MUX_WIRE=0;
          // T
          if (!MENOR)
            begin
              PROX_ESTADO = BGE2;
            end

          else
            begin
              PROX_ESTADO = BUSCA;
            end
        end

      4: //BLT
        begin
          SAIDA_ESTADO = 24;
          PC_WRITE = 0;
          RESET_WIRE = 0;
          ALU_SRCA = 1;
          ALU_SRCB = 0;
          ALU_SELECTOR = 7;
          LOAD_ALU_OUT = 0; 
          DMEM_RW = 0; //0 => READ, 1 => WRITE 
          IR_WIRE= 0 ;
          LOAD_A = 0;
          LOAD_B = 0;
          MUX_MR_WIRE = 0;
          LOAD_MDR = 0;
          BANCO_WIRE = 0;
          SHIFT= 0;
          ALU_OUT_MUX_WIRE=0;
          // T
          if (MENOR)
            begin
              PROX_ESTADO = BLT2;
            end

          else
            begin
              PROX_ESTADO = BUSCA;
            end
	end
	endcase
 end

  JALR2: //salva pc em rd
    begin
    end

JALR3: //PC=(rs1+imm)*
  begin
  end

  BLT2:
   begin
      SAIDA_ESTADO = 25;
      PC_WRITE = 1;
      RESET_WIRE = 0;
      ALU_SRCA = 0;
      ALU_SRCB = 2;
      ALU_SELECTOR = 1;
      LOAD_ALU_OUT = 0; 
      DMEM_RW = 0; //0 => READ, 1 => WRITE 
      IR_WIRE= 0 ;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      LOAD_MDR = 0;
      BANCO_WIRE = 0;
      ALU_OUT_MUX_WIRE=0;
      SHIFT= 0;
      PROX_ESTADO = BUSCA;
  end
  BGE2:
    begin
      SAIDA_ESTADO = 26;
      PC_WRITE = 1;
      RESET_WIRE = 0;
      ALU_SRCA = 0;
      ALU_SRCB = 2;
      ALU_SELECTOR = 1;
      LOAD_ALU_OUT = 0; 
      DMEM_RW = 0; //0 => READ, 1 => WRITE 
      IR_WIRE= 0 ;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      LOAD_MDR = 0;
      BANCO_WIRE = 0;
      ALU_OUT_MUX_WIRE=0;
      SHIFT= 0;
      PROX_ESTADO = BUSCA;
    end

   BNE2:
       begin
      SAIDA_ESTADO = 27;
      PC_WRITE = 1;
      RESET_WIRE = 0;
      ALU_SRCA = 0;
      ALU_SRCB = 2;
      ALU_SELECTOR = 1;
      LOAD_ALU_OUT = 0; 
      DMEM_RW = 0; //0 => READ, 1 => WRITE 
      IR_WIRE= 0 ;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      LOAD_MDR = 0;
      BANCO_WIRE = 0;
      ALU_OUT_MUX_WIRE=0;
      SHIFT= 0;
      PROX_ESTADO = BUSCA;
    end
    LUI:
     begin
      SAIDA_ESTADO = 28;
      PC_WRITE = 0;
      RESET_WIRE = 0;
      ALU_SRCA = 2;
      ALU_SRCB = 2;
      ALU_SELECTOR = 1;
      LOAD_ALU_OUT = 1; 
      DMEM_RW = 0; //0 => READ, 1 => WRITE 
      IR_WIRE = 0 ;
      LOAD_A = 0;
      LOAD_B = 0;
      MUX_MR_WIRE = 0;
      BANCO_WIRE = 0;
      SHIFT= 0;
      ALU_OUT_MUX_WIRE=0;
      LOAD_MDR = 0;
      PROX_ESTADO = R2;
     end
    
    JAL:
      begin
      end
      BREAK: // EH O BREAK
        begin
         SAIDA_ESTADO = 29;
         PC_WRITE = 0;
         RESET_WIRE = 0;
         ALU_SRCA = 0;
         ALU_SRCB = 0;
         ALU_SELECTOR = 0;
         LOAD_ALU_OUT = 0; 
         DMEM_RW = 0; 
         IR_WIRE = 0;
         LOAD_A = 0;
         LOAD_B = 0;
         MUX_MR_WIRE = 0;
         LOAD_MDR = 0;
         BANCO_WIRE = 0;
         SHIFT= 0;
         ALU_OUT_MUX_WIRE=0;
         SHIFT= 0;
         PROX_ESTADO = BREAK;
        end
endcase
endmodule 