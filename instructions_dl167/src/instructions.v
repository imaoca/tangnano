// Asm file to a separate file.

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
        `include "shooting1.asm"
    end
    
	always @(posedge clock  or negedge rst)
	  if(rst==0) {regs[0],regs[1],regs[2],regs[3],regs[4],regs[6],regs[7],c_flag,op2}=0;
	  else begin
        regs[5]=~{btn,Abtn,Bbtn,2'b11}; 
        regs[4]=counter[23:16];
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
/* MVI */	5'b1110z: begin regs[sss]=ram[regs[7]+1];regs[7]=regs[7]+1;end
/*VPOKE*/   5'b10zzz: vregs[op[2:0]]=regs[sss];      	
	   endcase
/* JNC */	if (dout==8'b1100_0000)op2=1;
/* JMP */   if (dout==8'b1101_0000)op2=2;		
            if (dout==8'b1100_0001) di=0;
            if (dout==8'b1101_0001) di=1;
       regs[7]=regs[7]+1;
	   end
       else begin
        if (op2==1) begin regs[7]=(c_flag)?regs[7]+1:dout;c_flag=0;end
        if (op2==2) regs[7]=dout;
        op2=0;
       end
    if ((op2==0)&&(regs[5]!=0)&&(di==0)) begin 
        if (regs[5]&8'b1000_0000) regs[7]=2;
        if (regs[5]&8'b0001_0000) regs[7]=4;
        if (regs[5]&8'b0000_1000) regs[7]=6;
        di = 1;
    end
end
    always @(posedge clk) counter <= counter + 1;
endmodule
