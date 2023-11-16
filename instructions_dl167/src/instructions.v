// setjmp,logjmp
// TBD call,ret 

module cpu(input rst,mode,clk,Abtn,Bbtn,[3:0]btn,output low,[7:0]col, output [7:0]row,output [5:0]leds);
    wire [7:0]dout=ram[regs[7]];
    wire [4:0]op=dout[7:3]; 
	reg c_flag,di;
	reg [1:0]op2,regMode;
	reg [7:0]regs[7:0];
    reg [7:0]vregs[7:0];
    reg [7:0]ram[255:0];
    reg [7:0]x,y;
    reg [23:0] counter;
	wire[2:0]sss=dout[2:0]; 
    assign low=0;
    assign leds[3:0]=~regs[6][3:0];
    assign leds[4]=1;
    assign leds[5]=!c_flag;
//    assign col=(regMode==1)?regs[counter[15:13]]:vregs[counter[15:13]];
    assign col=(regMode==2)?ram[counter[15:13]+y*8] :((regMode==1)?regs[counter[15:13]]:vregs[counter[15:13]]);
    assign row = ~(1<<counter[15:13]);
    wire clock=(regMode==0)?counter[16]:counter[21];


//	always @(posedge counter[22]) if (mode==0) regMode=~regMode;
	always @(posedge counter[22]) if (rst==0) regMode=0;else if (mode==0) regMode=regMode+1;
	always @(posedge counter[22]) if (rst==0) y=0;
        else begin if (btn==4'b1011) y=y-1; if (btn==4'b1101) y=y+1;end 

    initial begin
//        `include "shooting.asm"

    ram[0] <=8'b11010000;  // jmp 16 go to code
    ram[1] <=16;  

    ram[16] <=8'b11100_001; // mvi r1,24
    ram[17] <=24;
    ram[18] <=8'b11001_001; // setjmp (r1)
    ram[19] <=0;
    ram[20] <=8'b11011_001; // longjmp (r1)

    end
    
	always @(posedge clock  or negedge rst)
	  if(rst==0) {regs[0],regs[1],regs[2],regs[3],regs[4],regs[6],regs[7],c_flag,op2}=0;
	  else begin
        regs[5]=~{btn,Abtn,Bbtn,2'b11}; 
//        regs[4]=counter[23:16];
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
/* MVI */	5'b11100: begin regs[sss]=ram[regs[7]+1];regs[7]=regs[7]+1;end
/* LD  */	5'b11101: begin regs[sss]=ram[ram[regs[7]+1]];regs[7]=regs[7]+1;end
/* STR */	5'b11110: begin ram[ram[regs[7]+1]]=regs[sss];regs[7]=regs[7]+1;end
/*RANDOM*/  5'b11111: regs[sss]=counter[23:16];
/*setjmp*/	5'b11001: begin ram[regs[sss]]=regs[7];end
/*longjmp*/	5'b11011: begin regs[7]=ram[regs[sss]];end

/*VPOKE*/   5'b10zzz: vregs[op[2:0]]=regs[sss];      	
	   endcase
/* JNC */	if (dout==8'b11000_000)op2=1;
/* JMP */   if (dout==8'b11010_000)op2=2;		
/* EI  */   if (dout==8'b11000_001) di=0;
/* DI  */   if (dout==8'b11010_001) di=1;
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
