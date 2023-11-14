// Move the cannon to the left.
// Increase clock frequency in game mode.
// vpoke vram[ddd] = regs[sss] 

// TBD inkey (assign to R5) 
// TBD STR  ram[8'adr],regs(sss)
// TBD LD   regs(sss),ram[8'adr]
// TBD interrupt
module cpu(input rst,mode,clk,Abtn,Bbtn,[3:0]btn,output low,[7:0]col, output [7:0]row,output [5:0]leds);
    wire [7:0]dout=ram[regs[7]];
    wire [4:0]op=dout[7:3]; 
	reg c_flag;
	reg [1:0]op2;
	reg [7:0]regs[7:0];
    reg [7:0]vregs[7:0];
    reg [7:0]ram[255:0];
    reg [23:0] counter;
	wire[2:0]sss=dout[2:0]; 
    assign leds[3:0]=~regs[6][3:0];
    assign leds[4]=1;
    assign leds[5]=!c_flag;
    assign col=(mode==1)?regs[counter[15:13]]:vregs[counter[15:13]];
    assign row = ~(1<<counter[15:13]);
    wire clock=(mode==1)?counter[21]:counter[18];
    assign low=0;

    initial begin
 //       `include "short.asm"

    ram[0] <=8'b1110_0110;  // mvi R6,1110_0000;
    ram[1] <=8'b1110_0000;  // 1110_0000
    ram[2] <=8'b1110_0100;  // mvi R4,0100_0000;
    ram[3] <=8'b0100_0000;  // 0100_0000

    ram[4] <=8'b01111_110;  // rotate R6
    ram[5] <=8'b01111_100;  // rotate R4

    ram[6] <=8'b10_110_100; // vpoke VR6,R4  
    ram[7] <=8'b10_111_110; // vpoke VR7,R6  
    ram[8] <=8'b1101_0000;  // jmp 4
    ram[9] <=8'b0000_0100;  // 4

/*
    ram[0] <=8'b1110_0110;  // mvi R6,1110_0000;
    ram[1] <=8'b1110_0000;  // 1110_0000
    ram[2] <=8'b1110_0100;  // mvi R4,0100_0000;
    ram[3] <=8'b0100_0000;  // 0100_0000

    ram[] <=8'b00
    ram[] <=8'b00_000_101;  // mov R0,R5
    ram[]
    ram[] <=8'b00_111_000;  // mov R7,R0
             
    ram[4] <=8'b01111_110;  // rotate R6
    ram[5] <=8'b01111_100;  // rotate R4

    ram[6] <=8'b10_110_100; // vpoke VR6,R4  
    ram[7] <=8'b10_111_110; // vpoke VR7,R6  
    ram[8] <=8'b1101_0000;  // jmp 4
    ram[9] <=8'b0000_0100;  // 4

    ram[255] <=8'b00_000_000; // mov R0,R0
*/
    end
    
	always @(posedge clock  or negedge rst)
	  if(rst==0) {regs[0],regs[1],regs[2],regs[3],regs[4],regs[6],regs[7],c_flag,op2}=0;
	  else begin
       regs[5]=~{btn,Abtn,Bbtn,2'b11}; 
	   if (op2==0) begin
 	   casez(op)
/* MOV */	5'b00zzz: regs[op[2:0]]=regs[sss];
/* ADD */	5'b01000: begin regs[0]=regs[0]+regs[sss]; c_flag = (regs[0]+regs[sss] > 255)?1:0;end
/* OR  */	5'b01001: regs[0]=regs[0]|regs[sss];
/* AND */	5'b01010: regs[0]=regs[0]&regs[sss];
/* XOR */	5'b01011: regs[0]=regs[0]^regs[sss];
/* INC */	5'b01100: begin regs[sss]=regs[sss]+1; c_flag = ((regs[sss]+1) > 255)?1:0;end
/* NOT */	5'b01101: regs[sss]=!regs[sss];
/*RROTATE*/	5'b01110: regs[sss]=regs[sss]>>1| (regs[sss]<<7 & 8'b10000000);
/*LROTATE*/	5'b01111: regs[sss]=regs[sss]<<1| (regs[sss]>>7 & 8'b00000001);	

/* JNC */	5'b1100z: op2=1;
/* JMP */   5'b1101z: op2=2;


/* MVI */	5'b1110z: begin regs[sss]=ram[regs[7]+1];regs[7]=regs[7]+1;end
/*VPOKE*/   5'b10zzz: vregs[op[2:0]]=regs[sss];      	
	   endcase		
       regs[7]=regs[7]+1;
//        if (dout[7]==0) regs[7]=regs[7]+1;
	   end

       else begin
        if (op2==1) begin regs[7]=(c_flag)?regs[7]+1:dout;c_flag=0;end
        if (op2==2) regs[7]=dout;
        op2=0;
       end

end
    always @(posedge clk) counter <= counter + 1;
endmodule
