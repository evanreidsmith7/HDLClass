//Evan Smith

parameter src1 = 0;
parameter src2 = 1;
//parameter dest = 2;

parameter memAdrr = 0;
parameter instrMem = 1;
parameter matrixAlu = 2;
parameter intAlu = 3;
parameter internal = 4;
parameter exeEngine = 5;

parameter SRC1 = 0;
parameter SRC2 = 1;
parameter RES = 2;
parameter SI = 3;
parameter SO = 4;

parameter stopCode = 8'hff;
parameter intMod = 4'h3;
parameter matrixMod = 4'h2;

//modified for matrix
module Execution(Clk,InstructDataOut,MemDataOut,MatrixDataOut,IntDataOut, ExeDataOut, address, nRead,nWrite, nReset);

input logic Clk, nReset;
input logic [255:0] IntDataOut;
input logic [255:0] InstructDataOut;
input logic [255:0] MemDataOut;
input logic [255:0] MatrixDataOut; //this used to IntDataOut

output logic [255:0] ExeDataOut;
output logic nRead, nWrite;
output logic [15:0] address;

logic [255:0]InternalReg[3];
logic [255:0]resReg;
logic [255:0]source1;
logic [255:0]source2;

logic [31:0]instr;
logic [7:0]opcode;
logic [7:0]destReg;
logic [3:0]dest;
logic [7:0]src1reg;
logic [3:0]s1off;
logic [7:0]src2reg;
logic [3:0]s2off;
logic [11:0]offset;

assign opcode = instr[31:24];
assign destReg = instr[23:16];
assign dest = destReg[3:0]; //offset for dest
assign src1reg = instr[15:8];
assign s1off = src1reg[3:0]; //offset for src1
assign src2reg = instr[7:0];
assign s2off = src2reg[3:0];
assign offset = address[11:0];
int count;

enum {inf1, inf2, dec, load1, getReg1, load2, getReg2,
      sendSrc1, src1received, sendSrc2, src2received,
      sendOp, exe1, exe2, wb1, wb2} state, nextState;

always_ff@(posedge Clk or negedge nReset)
begin
   if (!nReset)
   begin
      ExeDataOut = 0;
      for (int i = 0; i < 3; i++)
      begin
         InternalReg[i] <= 0;
      end
      source1 = 0;
      source2 = 0;
      resReg = 0;
      count = 0;
   end
   else
   begin
      state <= nextState;
   end
end
   
always_comb
begin
   if (nReset)
   begin
      case(state)
/*IF1*/  inf1: //read instruction from iMem
         begin
            if (nReset)
            begin
               address[15:12] = instrMem;
               address[11:0] = count;
               nWrite = 1;
               nRead = 0;
               nextState = inf2;
            end           
         end
/*IF2*/  inf2://receive instruction
         begin
            address[15:12] = exeEngine;
            //testing^
            instr = InstructDataOut[31:0];
            nWrite = 1;
            nRead = 1;
            nextState = dec;
         end
/*dec*/  dec: //decode instruction
         begin //
            if (opcode == stopCode)
            begin
               $stop;
            end
            else
            begin
               nextState = load1;
            end
         end
/*L1*/   load1: //assign internal reg0 aka src1
         begin
            case(src1reg[7:4])
               0:
               begin
                  address = {8'h0, src1reg}; //this may work
                  nRead = 0;
                  nWrite = 1;
                  nextState = getReg1;
               end
               1:
               begin
                  source1 = InternalReg[s1off];
                  address[11:0] = 0;               
                  nRead = 1;
                  nWrite = 0;
                  nextState = load2;
               end
            endcase
         end
/*gr1*/  getReg1: //get data from mem module
         begin
            source1 = MemDataOut;
            address[15:12] = internal;
            nRead = 1;
            nWrite = 1;
            nextState = load2;
         end
/*L2*/   load2: //assign src2
         begin
            case(src2reg[7:4])
               0: //we gotta get src2 from mem
               begin
                  address = {8'h0, src2reg};
                  nRead = 0;
                  nWrite = 1;
                  nextState = getReg2;
               end
               1:
               begin //send internal reg 
                  source2 = InternalReg[s2off];
                  address[11:0] = 1;
                  nRead = 1;
                  nWrite = 0;
                  nextState = sendSrc1;
               end
            endcase
         end
/*gr2*/  getReg2:
         begin
            source2 = MemDataOut;
            address[15:12] = internal;
            address[11:0] = src2; 
            nRead = 1;
            nWrite = 1;
            nextState = sendSrc1;
         end
/*sSc1*/ sendSrc1: //send src1 to alu
         begin
            case(opcode[7:4])
               0:
               begin
                  address[15:12] = matrixMod;
               end
               1:
               begin
                  address[15:12] = intMod;
               end
            endcase
         address[11:0] = 0;
         if (address[15:12] == matrixMod)
         begin
            ExeDataOut = source1;
         end
         else
         begin
            ExeDataOut = source1[15:0];
         end
         nWrite = 0;
         nRead = 1;
         nextState = src1received;
         end
/*s1r*/  src1received:
         begin
            address[15:12] = exeEngine;
            nWrite = 1;
            nRead = 1;
            nextState = sendSrc2;
         end
/*sSc2*/ sendSrc2: //send src1 to alu
         begin
            case(opcode[7:4])
               0:
               begin
                  address[15:12] = matrixMod;
               end
               1:
               begin
                  address[15:12] = intMod;
               end
            endcase
            address[11:0] = 1;
            if (address[15:12] == matrixMod)
            begin
               ExeDataOut = source2;
            end
            else
            begin
               ExeDataOut = source2[15:0];
            end
            nWrite = 0;
            nRead = 1;
            nextState = src2received;
         end
/*s2r*/  src2received:
         begin
            address[15:12] = exeEngine;
            nWrite = 1;
            nRead = 1;
            nextState = sendOp;
         end
/*sOp*/  sendOp: //send op code and wait for result to be done
         begin
            case(opcode[7:4])
               0:
               begin
                  address[15:12] = matrixMod;
               end
               1:
               begin
                  address[15:12] = intMod;
               end 
            endcase
            address[11:0] = 3;
            //ExeDataOut[7:0] = opcode;
            ExeDataOut = {248'h0, opcode};
            nWrite = 0;
            nRead = 1;
            nextState = exe1;
         end
/*EXE1*/ exe1: //set up read to get result out of alu
         begin
            nWrite = 1;
            nRead = 0;
            nextState = exe2;                  
         end
/*EXE2*/ exe2: //get result
         begin
            if (opcode[7:4] == 1)
            begin
               resReg = IntDataOut; 
            end
            else
            begin
               resReg = MatrixDataOut; 
            end
            nWrite = 1;                
            nRead = 1;
            nextState = wb1;
         end
/*wb1*/  wb1: //32'h 10_10_0a_0b
         begin
            case(destReg[7:4])
               0: //
               begin
                  address[15:12] = 0;
                  address[11:0] = destReg[3:0];
                  ExeDataOut = resReg;
                  nWrite = 0;
                  nRead = 1;
                  nextState = wb2;
               end
               1: //store result internal
               begin
                  address[15:12] = 4'h4;
                  address[11:0] = destReg[3:0];
                  ExeDataOut = resReg;
                  nWrite = 0;
                  nRead = 1;
                  nextState = wb2;
               end
            endcase               
         end
 /*wb1*/ wb2:
         begin
            if (address[15:12] == 4'h4)
            begin
               InternalReg[dest] = ExeDataOut;
            end
            nWrite = 1;
            nRead = 1;
            address = 16'h5000;
            count = count + 1;
            nextState = inf1;
         end
         default: nextState <= inf1;
      endcase
   end
   else
   begin
      nextState = inf1;
   end
end

endmodule
