ram[0] <=8'b1010_0001; 	// mvi R0,1
ram[1] <=8'b00_001_000; // mov R1,R0
ram[2] <=8'b0110_000; 	// inc R0
ram[3] <=8'b01010_001; 	// and R0,R1
ram[4] <=8'b1001_0010;  // jmp 	2