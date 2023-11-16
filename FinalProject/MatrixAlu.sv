//Evan Smith

parameter MMult1     = 8'h00;
parameter MMult2a    = 8'h01;
parameter MMult2b    = 8'h02;
parameter Madd       = 8'h03;
parameter Msub       = 8'h04;
parameter Mtranspose = 8'h05;
parameter MScale     = 8'h06;
parameter MScaleImm  = 8'h07;

parameter IntAdd     = 8'h10;
parameter IntSub     = 8'h11;
parameter IntMult    = 8'h12;
parameter IntDiv     = 8'h13;

module MatrixAlu (Clk,MatrixDataOut,ExeDataOut, address, nRead,nWrite, nReset);
   input logic Clk,nRead,nWrite,nReset;
   input logic [15:0] address;
   input logic [255:0] ExeDataOut;
   
   output logic [255:0] MatrixDataOut;
   int start_bit;
   int idx;
   logic [7:0] opcode;
   assign opcode = ExeDataOut[7:0];
   logic two;
   
   logic [15:0] ms1[3:0][3:0];
   logic [15:0] ms2[3:0][3:0];
   logic [15:0] imm;
   logic [15:0] mres[3:0][3:0];

   
   always_ff @(negedge Clk or negedge nReset)
   begin
      if (!nReset)
      begin
         two = 0;
         MatrixDataOut = 0;
         for (int i = 0; i < 4; i++)
         begin
            for (int j = 0; j < 4; j++) 
            begin
               mres[i][j] = 0;
               ms2[i][j] = 0;
               ms1[i][j] = 0;
            end
         end   
      end
      else if ((address[15:12] == 2) && !nWrite)
      begin
         $display("address is: %b_%b", address[15:12], address[11:0]);
         $display("exedataout is: %h", ExeDataOut);
         //implement state machine
         case(address[11:0])
            SRC1: //receive src1 from exe engine, a 4x4 matrix of 16 bits
            begin
               for (int i = 0; i < 4; i++)
               begin
                  for (int j = 0; j < 4; j++) 
                  begin
                     start_bit = (i * 4 + j) * 16;
                     ms1[i][j] = ExeDataOut[start_bit +: 16];
                  end
               end            
               
               // Display the matrix in a formatted table
               $write("\n");
               for (int i = 0; i < 4; i++)
               begin
                  for (int j = 0; j < 4; j++) 
                  begin
                     $write("%5h ", ms1[i][j]);
                  end
                  $write("\n");
               end
                                             
            end
            SRC2: //receive src2 from exe engine
            begin
               imm = ExeDataOut;
               for (int i = 0; i < 4; i++)
               begin
                  for (int j = 0; j < 4; j++) 
                  begin
                     start_bit = (i * 4 + j) * 16;
                     ms2[i][j] = ExeDataOut[start_bit +: 16];
                  end
               end
               
               // Display the matrix in a formatted table
               $write("\n");
               for (int i = 0; i < 4; i++)
               begin
                  for (int j = 0; j < 4; j++) 
                  begin
                     $write("[i:%1d][j:%1d]%5h ", i, j, ms2[i][j]);
                  end
                  $write("\n");
               end
               $write("\n");
            end
            
            SI: //signal from exe saying to do the operations
            begin
               $display("Value of op is %h", opcode);
               case(opcode)
                  MMult1:
                  begin
                     $display("MMult1"); //4x4
                     for (int i = 0; i < 4; i++) 
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           mres[i][j] = 16'h0; // Initialize mres element to 0
                           for (int k = 0; k < 4; k++)
                           begin
                              mres[i][j] += ms1[i][k] * ms2[k][j]; // Multiply and accumulate
                           end
                        end
                     end
                     
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           $write("%5h ", mres[i][j]);
                        end
                        $write("\n");
                     end                     
                     $write("\n");
                  end
                  MMult2a:
                  begin
                     $display("*MMult2a"); //
                     for (int i = 0; i < 4; i++) 
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           mres[i][j] = 16'h0; // Initialize mres element to 0
                           for (int k = 0; k < 2; k++)
                           begin
                              mres[i][j] += ms1[i][k] * ms2[k][j]; // Multiply and accumulate
                           end
                        end
                     end                
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           //$write("%5h ", mres[i][j]);
                           $write("[i:%1d][j:%1d]%5h ", i, j, mres[i][j]);
                        end
                        $write("\n");
                     end
                     $write("\n");
                  end
                  MMult2b:
                  begin
                     //clear res its gonna be smaller
                     two = 1;
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++)
                        begin
                           mres[i][j] = 16'h0;
                        end
                     end
                     $display("*MMult2b"); //mult 2x4 * 4x2 for 2x2 result
                     for (int i = 0; i < 2; i++) 
                     begin
                        for (int j = 0; j < 2; j++) 
                        begin
                           mres[i][j] = 16'h0; // Initialize mres element to 0
                           for (int k = 0; k < 4; k++)
                           begin
                              mres[i][j] += ms1[i][k] * ms2[k][j]; // Multiply and accumulate
                           end
                        end
                     end
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           $write("[i:%1d][j:%1d]%5h ", i, j, mres[i][j]);
                        end
                        $write("\n");
                     end
                     $write("\n");
                  end
                  Madd:
                  begin
                     $display("MAdd");
                     for(int i = 0; i<4; i++)
                     begin
                        for(int j = 0; j<4; j++)
                        begin
                           mres[i][j] = ms1[i][j] + ms2[i][j];
                        end
                     end
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           $write("%5h ", mres[i][j]);
                        end
                        $write("\n");
                     end
                     
                  end //end Madd
                  Msub:
                  begin
                     $display("MSub");
                     
                     for(int i = 0; i<4; i++)
                     begin
                        for(int j = 0; j<4; j++)
                        begin
                           mres[i][j] = ms1[i][j] - ms2[i][j];
                        end
                     end
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           $write("%5h ", mres[i][j]);
                        end
                        $write("\n");
                     end
                     
                  end
                  Mtranspose:
                  begin
                     $display("Mtranspose");
                     for(int i = 0; i<4; i++)
                     begin
                        for(int j = 0; j<4; j++)
                        begin
                           mres[i][j] = ms1[j][i];
                        end
                     end
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           $write("%5h ", mres[i][j]);
                        end
                        $write("\n");
                     end
                  end
                  MScale:
                  begin
                     $display("MScale");
                  end
                  MScaleImm:
                  begin
                     $display("MScaleImm ");
                     $write("hex imm: %h \n", imm);
                     for(int i = 0; i<4; i++)
                     begin
                        for(int j = 0; j<4; j++)
                        begin
                           mres[i][j] = ms1[i][j] * imm;
                        end
                     end
                     // Display the matrix in a formatted table
                     $write("result: \n");
                     for (int i = 0; i < 4; i++)
                     begin
                        for (int j = 0; j < 4; j++) 
                        begin
                           $write("%5h ", mres[i][j]);
                        end
                        $write("\n");
                     end
                     $write("\n");
                  end //end for scaleImm
               endcase //for op           
            end
         endcase //for adress
      end
      else if ((address[15:12] == 2) && !nRead) //send data 
      begin
         if (!two)
         begin
            start_bit = 0;
            for (int i = 0; i < 4; i++)
            begin
              for (int j = 0; j < 4; j++) 
              begin
                MatrixDataOut[start_bit +: 16] = mres[i][j];
                start_bit += 16;
              end
            end            
         end //if end
         else
         begin
            idx = 0;
            for (int i = 0; i < 2; i++) 
            begin
                for (int j = 0; j < 2; j++) 
                begin
                    MatrixDataOut[idx +: 16] = mres[i][j];
                    idx += 16;
                end
            end
            MatrixDataOut[255:64] = 0;
            
                     
         end //else end
      end
   end //END FF
   
endmodule