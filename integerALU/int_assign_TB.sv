// Mark W Welker
// Generic Test bench It drives only clock and reset.

//parameter Instruct1 = 32'h 10_02_00_01;
//parameter Instruct2 = 32'h 10_03_02_01;
//parameter Instruct3 = 32'h 11_04_03_01;
//parameter Instruct4 = 32'h 12_05_04_00;
//parameter Instruct5 = 32'h 13_06_05_01;

// This is the memory locations for the system.
/////////////////////////////////////////////
parameter MainMemEn = 0;
parameter RegisterEn = 1;
parameter InstrMemEn = 2;
parameter AluEn = 3;
parameter ExecuteEn = 4;
parameter IntAlu = 5;

module TestInteger  (Clk,nReset,TestDataOut, address,nWrite,nRead,IntDataOut);

    input logic [255:0]IntDataOut;
    
    output logic Clk,nReset,nWrite,nRead; // we are driving these signals from here. 
    output logic [255:0]TestDataOut;
    output logic [15:0]address;

integer fail = 0;

logic [255:0] registers [7];

	initial begin
		Clk = 0;
		nReset = 1;
		nWrite = 1;
		nRead = 1;
		address = 0;
		
	registers[1] = 64'h0008_0007_0006_0005;
	registers[0] = 64'h0001_0002_0003_0004;

	#3 nReset = 0;
	#10 nReset = 1;
	end
	
	always  #5 Clk = ~Clk;

initial begin  // manuallt send the commands to the integer ALU keep items in internal regsiters.  
// This is the hard way. you will appreciate the execution engine, as it does this using a state machine. 

//		write to int alu source 1
	
#12					address[15:12] = IntAlu;
					address [11:0] = 0; // write it to source 1
					nWrite = 0;
					TestDataOut = registers[0]; // 
#10 
                    nWrite = 1;
#10	 // write to integer ALU source 2
					address [11:0] = 1; // write it to source 2
					nWrite = 0;
					TestDataOut = registers[1]; // store the data from the bus
//		Ialu_Start: begin
#10					address[15:12] = IntAlu;
					address [11:0] = 3; // Status in to ALU bit 0 tells it to go
										// Eventualy you need to add in teh opcode to the ALU
					nRead = 1;
					nWrite = 0;
					TestDataOut = 8'h10;
#10 // read the data back out of the integer ALU:: assume it is done inm a clock and put the data on integerdataout. 
                    
                    registers[2] = IntDataOut;
// next instruction
#10             nWrite = 1;
                TestDataOut = registers[2];

#10					address[15:12] = IntAlu;
					address [11:0] = 0; // write it to source 1
					nWrite = 0;
					TestDataOut = registers[2]; // 
#10 
                    nWrite = 1;
#10	 // write to integer ALU source 2
					address [11:0] = 1; // write it to source 2
					nWrite = 0;
					TestDataOut = registers[1]; // store the data from the bus
//		Ialu_Start: begin
#10					address[15:12] = IntAlu;
					address [11:0] = 3; // Status in to ALU bit 0 tells it to go
										// Eventualy you need to add in teh opcode to the ALU
					nRead = 1;
					nWrite = 0;
					TestDataOut = 8'h10;
#10 // read the data back out of the integer ALU:: assume it is done inm a clock and put the data on integerdataout. 
                    registers[3] = IntDataOut;
// next instruction
                
#10             nWrite = 1;
                TestDataOut = registers[2];
#10					address[15:12] = IntAlu;
					address [11:0] = 0; // write it to source 1
					nWrite = 0;
					TestDataOut = registers[3]; // 
#10 
                    nWrite = 1;
#10	 // write to integer ALU source 2
					address [11:0] = 1; // write it to source 2
					nWrite = 0;
					TestDataOut = registers[1]; // store the data from the bus
//		Ialu_Start: begin
#10					address[15:12] = IntAlu;
					address [11:0] = 3; // Status in to ALU bit 0 tells it to go
										// Eventualy you need to add in teh opcode to the ALU
					nRead = 1;
					nWrite = 0;
					TestDataOut = 8'h11;
#10 // read the data back out of the integer ALU:: assume it is done inm a clock and put the data on integerdataout. 
                    registers[4] = IntDataOut;
// next instruction
#10             nWrite = 1;
                TestDataOut = registers[2];
#10					address[15:12] = IntAlu;
					address [11:0] = 0; // write it to source 1
					nWrite = 0;
					TestDataOut = registers[4]; // 
#10 
                    nWrite = 1;
#10	 // write to integer ALU source 2
					address [11:0] = 1; // write it to source 2
					nWrite = 0;
					TestDataOut = registers[0]; // store the data from the bus
//		Ialu_Start: begin
#10					address[15:12] = IntAlu;
					address [11:0] = 3; // Status in to ALU bit 0 tells it to go
										// Eventualy you need to add in teh opcode to the ALU
					nRead = 1;
					nWrite = 0;
					TestDataOut = 8'h12;
#10 // read the data back out of the integer ALU:: assume it is done inm a clock and put the data on integerdataout. 
                    registers[5] = IntDataOut;
// next instruction
#10             nWrite = 1;
                TestDataOut = registers[2];
#10					address[15:12] = IntAlu;
					address [11:0] = 0; // write it to source 1
					nWrite = 0;
					TestDataOut = registers[5]; // 
#10 
                    nWrite = 1;
#10	 // write to integer ALU source 2
					address [11:0] = 1; // write it to source 2
					nWrite = 0;
					TestDataOut = registers[1]; // store the data from the bus
//		Ialu_Start: begin
#10					address[15:12] = IntAlu;
					address [11:0] = 3; // Status in to ALU bit 0 tells it to go
										// Eventualy you need to add in teh opcode to the ALU
					nRead = 1;
					nWrite = 0;
					TestDataOut = 8'h13;
#10 // read the data back out of the integer ALU:: assume it is done inm a clock and put the data on integerdataout. 
                    registers[6] = IntDataOut;
// next instruction

// This is the check
if (registers[0] != 256'h0000000000000000000000000000000000000000000000000001000200030004) fail =1;
if (registers[1] != 256'h0000000000000000000000000000000000000000000000000008000700060005) fail =1;
if (registers[2] != 256'h0000000000000000000000000000000000000000000000000009000900090009) fail =1;
if (registers[3] != 256'h00000000000000000000000000000000000000000000000000110010000f000e) fail =1;
if (registers[4] != 256'h0000000000000000000000000000000000000000000000000009000900090009) fail =1;
if (registers[5] != 256'h0000000000000000000000000000000000000009001b0036005a0051003f0024) fail =1;
if (registers[6] != 256'h000000000000000000000000000000000000000000000000000120026403d085) fail =1;
if (fail ==1)
    $display( "System test failed");
else
    $display ( "System test passed");

$finish; 
end


	
	endmodule
