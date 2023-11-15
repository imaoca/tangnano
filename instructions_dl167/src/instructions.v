// Hold mode

// TBD Fire a shell
// TBD Key repeat
// TBD STR  ram[8'adr],regs(sss)
// TBD LD   regs(sss),ram[8'adr]
// TBD ret 

module cpu(input rst,mode,clk,Abtn,Bbtn,[3:0]btn,output low,[7:0]col, output [7:0]row,output [5:0]leds);
    wire [7:0]dout=ram[regs[7]];
    wire [4:0]op=dout[7:3]; 
	reg c_flag,di,regMode;
	reg [1:0]op2;
	reg [7:0]regs[7:0];
    reg [7:0]vregs[7:0];
    reg [7:0]ram[255:0];
    reg [23:0] counter;
	wire[2:0]sss=dout[2:0]; 
    assign leds[3:0]=~regs[6][3:0];
    assign leds[4]=1;
    assign leds[5]=!c_flag;
    assign col=(regMode==1)?regs[counter[15:13]]:vregs[counter[15:13]];
    assign row = ~(1<<counter[15:13]);
    wire clock=(regMode==1)?counter[21]:counter[16];
    assign low=0;

	always @(posedge counter[22]) if (mode==0) regMode=~regMode;

    initial begin
 //       `include "short.asm"

    ram[0] <=8'b1101_0000;  // jmp 16 go to code
    ram[1] <=16;            // 16
    ram[2] <=8'b1101_0000;  // jmp 25 right key   
    ram[3] <=25;
    ram[4] <=8'b1101_0000;  // jmp 30 left key
    ram[5] <=30;

    ram[16] <=8'b1110_0011;  // mvi R3,1110_0000;
    ram[17] <=8'b1110_0000;  // 1110_0000
    ram[18] <=8'b1110_0010;  // mvi R2,0100_0000;
    ram[19] <=8'b0100_0000;  // 0100_0000


    ram[20] <=8'b10_110_010; // vpoke VR6,R2  
    ram[21] <=8'b10_111_011; // vpoke VR7,R3  
    
    ram[22] <=8'b1100_0001;  // di=0;
    ram[23] <=8'b1101_0000;  // jmp 23
    ram[24] <=23;    
    
    ram[25] <=8'b1101_0001;  // di=1;        
    ram[26] <=8'b01111_011;  // R_rotate R3
    ram[27] <=8'b01111_010;  // R_rotate R2
            
    ram[28] <=8'b1101_0000;  // jmp 20
    ram[29] <=20;
 
    ram[30] <=8'b1101_0001;  // di=1;    
    ram[31] <=8'b01110_011;  // L_rotate R3
    ram[32] <=8'b01110_010;  // L_rotate R2
     
    ram[33] <=8'b1101_0000;  // jmp 20
    ram[34] <=20;

// DI     8'b1100_0001: di=1;
// EI     8'b1101_0001: di=0;

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
//* JNC */	5'b1100z: op2=1;
//* JMP */  5'b1101z: op2=2;
/* MVI */	5'b1110z: begin regs[sss]=ram[regs[7]+1];regs[7]=regs[7]+1;end
/*VPOKE*/   5'b10zzz: vregs[op[2:0]]=regs[sss];      	

//* MVI */	5'b1110zzzz: begin regs[sss]=ram[regs[7]+1];regs[7]=regs[7]+1;end
//*VPOKE*/   5'b10zzzzzz: vregs[op[2:0]]=regs[sss];     
//* DI */    8'b1100_0001: di=1;
//* EI */    8'b1101_0001: di=0; 	
	   endcase
/* JNC */	if (dout==8'b1100_0000)op2=1;
/* JMP */   if (dout==8'b1101_0000)op2=2;		
            if (dout==8'b1100_0001) di=0;
            if (dout==8'b1101_0001) di=1;
       regs[7]=regs[7]+1;
//        if (dout[7]==0) regs[7]=regs[7]+1;
	   end
       else begin
        if (op2==1) begin regs[7]=(c_flag)?regs[7]+1:dout;c_flag=0;end
        if (op2==2) regs[7]=dout;
        op2=0;
       end

    if ((op2==0)&&(regs[5]!=0)&&(di==0)) begin 
//    if ((op2==0)&&(regs[5]!=0)) begin 
//        regs[4]=regs[7];
        if (regs[5]&8'b1000_0000) regs[7]=2;
        if (regs[5]&8'b0001_0000) regs[7]=4;
    end
end
    always @(posedge clk) counter <= counter + 1;
endmodule
