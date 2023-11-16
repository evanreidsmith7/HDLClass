// Mark W. Welker and Evan Smith
// Spring 2021

//offsets for address that tell where in memory things are
parameter m1 = 0;
parameter m2 = 1;
parameter r1 = 2;
parameter r2 = 3;
parameter r3 = 4;
parameter r4 = 5;
parameter r5 = 6;
parameter r6 = 7;
parameter r7 = 8;
parameter r8 = 9;
parameter i1 = 10;
parameter i2= 11;
parameter ir1 = 12;
parameter ir2 = 13;


module MainMemory(Clk,MemDataOut,DataIn, address, nRead,nWrite, nReset);


input logic [255:0] DataIn; // from the CPU
input logic nRead,nWrite, nReset, Clk;
input logic [15:0] address;

output logic [255:0] MemDataOut; // to the CPU 

 logic [255:0]MainMemory[14]; // this is the physical memory

always_ff @(negedge Clk or negedge nReset)
begin
	if (~nReset) begin
	MemDataOut = 0;
   MainMemory[m1] <= 256'h0008_000c_0008_0006_000c_0010_000d_0009_000a_0009_0005_000d_000c_0003_000a_0006;
	MainMemory[m2] <= 256'h0003_0004_0007_0008_0007_0008_000e_0007_0010_0009_000c_000b_000c_0005_0005_0006;
	MainMemory[2] <= 256'h0;
	MainMemory[3] <= 256'h0;
	MainMemory[4] <= 256'h0;
	MainMemory[5] <= 256'h0;
	MainMemory[6] <= 256'h0;
	MainMemory[7] <= 256'h0;
	MainMemory[8] <= 256'h0;
	MainMemory[9] <= 256'h0;
	MainMemory[10] <= 256'h6;
	MainMemory[11] <= 256'hd;
	MainMemory[12] <= 256'h0;
	MainMemory[13] <= 256'h0;
	
	
      MemDataOut <= 0;
	end

  else if(address[15:12] == MainMemEn) // talking to Instruction
		begin
			if (~nRead)begin
				MemDataOut <= MainMemory[address[11:0]]; // data will remain on dataout until it is changed.
			end
			if(~nWrite)begin
		    MainMemory[address[11:0]] <= DataIn;
			end
		end
end // from negedge nRead	
endmodule


