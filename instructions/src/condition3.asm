ram[0] <=8'b1010_0001;  // mvi R0,1
ram[1] <=8'b00_001_000; // mov R1,R0
ram[2] <=8'b1010_1000;  // mvi R0,8
ram[3] <=8'b00_011_000; // mov R3,R0
ram[4] <=8'b1010_1110;  // mvi R0,14
ram[5] <=8'b00_110_001; // mov R6,R1
ram[6] <=8'b01100_000;  // inc R0
ram[7] <=8'b00_110_010; // mov R6,R2
ram[8] <=8'b1000_0101;  // jnc 5 
ram[9] <=8'b1010_1101;  // mvi R0,13
ram[10] <=8'b00_110_011;// mov R6,R3
ram[11] <=8'b01100_000; // inc R0
ram[12] <=8'b00_110_010;// mov R6,R2
ram[13] <=8'b1000_1010; // jnc 10
ram[14] <=8'b1001_1110; // jmp 14