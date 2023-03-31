
// Mark W. Welker
// HDL 4321 Spring 2021
// Matrix addition assignment top module
//
// Main memory MUST be allocated in the mainmemory module as per teh next line.
//  logic [255:0]MainMemory[12]; // this is the physical memory
//
module top ();

logic [255:0] TestDataOut;
logic [255:0] IntDataOut;
logic nRead,nWrite,nReset,Clk;
logic [15:0] address;


IntegerAlu  U5(Clk,IntDataOut,TestDataOut, address, nRead,nWrite, nReset);

TestInteger  UTest(Clk,nReset,TestDataOut, address,nWrite,nRead,IntDataOut);

  initial begin //. setup to allow waveforms for edaplayground
   $dumpfile("dump.vcd");
   $dumpvars(1);
 end

endmodule


	
	

