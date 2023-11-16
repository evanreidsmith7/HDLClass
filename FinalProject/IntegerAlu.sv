//Evan Smith


module IntegerAlu (Clk,IntDataOut,ExeDataOut, address, nRead,nWrite, nReset);
   output logic [255:0]IntDataOut;
   
   input logic Clk,nReset,nWrite,nRead; 
   input logic [255:0]ExeDataOut;
   input logic [15:0]address;
   
   logic [255:0]reggie[3];
   
   always_ff @(negedge Clk or negedge nReset)
   begin
      if (!nReset)
      begin
         IntDataOut = 0;
         for (int i = 0; i < 3; i++)
         begin
            reggie[i] = 0;
         end    
      end
      else if (address[15:12] == 3)
      begin
         if (!nRead)
         begin
            IntDataOut = reggie[RES];
         end
         if (!nWrite)
         begin
            case (address[11:0])
               0: //src1 = testdataout
               begin
                  reggie[SRC1] = ExeDataOut;
               end
               1: //src2 = testdataout
               begin
                  reggie[SRC2] = ExeDataOut;
               end
               3: //op case
               begin
                  case (ExeDataOut[7:0])
                     8'h10: // +
                     begin
                        reggie[RES] = reggie[SRC1] + reggie[SRC2];
                     end
                     8'h11: // -
                     begin
                        reggie[RES] = reggie[SRC1] - reggie[SRC2];
                     end
                        8'h12: // *
                     begin
                        reggie[RES] = reggie[SRC1] * reggie[SRC2];
                     end
                        8'h13: // /
                     begin
                        //reggie[RES] = reggie[SRC1] / reggie[SRC2];
                        reggie[RES] = reggie[SRC2] / reggie[SRC1];                        
                     end
                  endcase //end op case
               end //end :3 
            endcase //end offset case
         end
      end
   end //end always_ff

    
endmodule