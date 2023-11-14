/*
Extended MVI instruction
We can use that's kind of instruction
    ram['b000] <=8'b1010_0110;  // mvi R6,1111000;
*/

module cpu(input rst,input clk,input[3:0] btn,output [7:0]col, output [7:0]row,output [5:0]leds);
    wire [7:0]dout=ram[regs[7]];
    wire [4:0]op=dout[7:3]; 
	reg c_flag;
	reg [1:0]op2;
//	reg [3:0]regs[7:0];
//  reg [7:0]ram[15:0];
	reg [7:0]regs[7:0];
    reg [7:0]ram[255:0];

    reg [23:0] counter;
	wire[2:0]sss=dout[2:0]; 
    assign leds[3:0]=~regs[6][3:0];
    assign leds[4]=1;
    assign leds[5]=!c_flag;
//    assign col={4'b0000,regs[counter[15:13]]};
    assign col=regs[counter[15:13]];
    assign row = ~(1<<counter[15:13]);
//    assign dout = ram[regs[7]];

    initial begin
        `include "short.asm"
/*
    ram[0] <=8'b1010_0000;  // mvi r0,8'B10100101
    ram[1] <=8'b1010_0101;  // 
    ram[2] <=8'b1001_0000;  // jmp  2 
    ram[3] <=8'b0000_0010;
*/

    ram['b000] <=8'b1010_0110;  // mvi R6,1111000;
    ram['b001] <=8'b1111_0000;  // 1111_0000  
    ram['b010] <=8'b0110_0110;  // inc R6
    ram['b011] <=8'b1000_0000;  // jnc 2
    ram['b100] <=8'b0000_0010;  // 2
    ram['b101] <=8'b1001_0000;  // jmp 0
    ram['b110] <=8'b0000_0000;  // 0 

    end
    
	always @(posedge counter[21]  or negedge rst)
	  if(rst==0) {regs[0],regs[1],regs[2],regs[3],regs[4],regs[6],regs[7],c_flag,op2}=0;
	  else begin
//	   regs[5]={~btn,4'b1111};
       regs[5]=0; 
//*MOV*/     if (0==(dout&192)) regs[(dout&56)>>3]=regs[dout&7]; 
//*ADD*/     if (64==(dout&248)) begin if (regs[0]+regs[dout&7]>15) c_flag=1;regs[0]=regs[dout&7]+regs[0];end
//*OR*/      if (72==(dout&248)) regs[0]=regs[0]|regs[dout&7];
//*AND*/     if (80==(dout&248)) regs[0]=regs[0]&regs[dout&7];
//*XOR*/     if (88==(dout&248)) regs[0]=regs[0]^regs[dout&7];
//*NOT*/     if (104==(dout&248)) regs[dout&7]=~regs[dout&7];
//*RLOTATE*/ if (112==(dout&248)) regs[dout&7]=((regs[dout&7])>>1)|((regs[dout&7]&1) << 3);
//*LLOTATE*/ if (120==(dout&248)) regs[dout&7]=((regs[dout&7])<<1)|((regs[dout&7]&8) >> 3);
//*INC*/     if (96==(dout&248)) begin if (regs[dout&7]+1>15) c_flag=1;regs[dout&7]=regs[dout&7]+1;end
//*JMP*/     if (144==(dout&240)) regs[7]=dout&15;
//*MVI*/     if (160==(dout&240)) regs[0]=dout&15;
//*JNC*/     if (128==(dout&240)) begin regs[7]=((c_flag)?regs[7]+1:dout&15);c_flag=0;end
//*PC++*/    if ((144!=(dout&240)&&(128!=(dout&240)))) regs[7]=regs[7]+1;	
	   if (op2==0) begin
 	   casez(op)
/* MOV */	5'b00zzz: regs[op[2:0]]=regs[sss];
/* ADD */	5'b01000: begin regs[0]=regs[0]+regs[sss]; c_flag = (regs[0]+regs[sss] > 255)?1:0;end
/* OR  */	5'b01001: regs[0]=regs[0]|regs[sss];
/* AND */	5'b01010: regs[0]=regs[0]&regs[sss];
/* XOR */	5'b01011: regs[0]=regs[0]^regs[sss];
/* INC */	5'b01100: begin regs[sss]=regs[sss]+1; c_flag = ((regs[sss]+1) > 255)?1:0;end
/* NOT */	5'b01101: regs[sss]=!regs[sss];
/*RROTATE*/	5'b01110: regs[sss]=regs[sss]>>1| (regs[sss]<<3 & 4'b1000);
/*LROTATE*/	5'b01111: regs[sss]=regs[sss]<<1| (regs[sss]>>3 & 4'b0001);	
/* JNC */	5'b1000z: op2=1;
/* JMP */   5'b1001z: op2=2;
//* MVI */	5'b1010z: op2=3;
 /* MVI */	5'b1010z: begin regs[sss]=ram[regs[7]+1];regs[7]=regs[7]+1;end	
	   endcase		
//* PC++ */  if(op[4:1]!=4'b1000 && op[4:1]!=4'b1001) regs[7]=regs[7]+1;      
//       if (op[4:1]!=4'1010) regs[7]=regs[7]+1; 
         regs[7]=regs[7]+1; 
	   end
/*
       else begin
        if (op2==1) begin regs[7]=(c_flag)?regs[7]+1:dout;c_flag=0;op2=0;end
        if (op2==2) begin regs[7]=dout; op2=0; end
        if (op2==3) begin regs[0]=dout; regs[7]=regs[7]+1;op2=0;end
       end
*/
       else begin
        if (op2==1) begin regs[7]=(c_flag)?regs[7]+1:dout;c_flag=0;end
        if (op2==2) regs[7]=dout;
//        if (op2==3) begin regs[0]=dout; regs[7]=regs[7]+1;end
        op2=0;
       end
end

    always @(posedge clk) counter <= counter + 1;
endmodule
