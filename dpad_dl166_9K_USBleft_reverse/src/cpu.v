module cpu(
    input clk,
    input [3:0]btn,
    input Abtn,Bbtn,mode,rst,
    output [7:0]col, output [7:0]row,
//    output [0:7]col, output [0:7]row,
    output [5:0]leds,
    output low1,low2,low3);
    
    assign low1=0;
    assign low2=0;
    assign low3=0;
    assign high=1;
    wire [7:0]dout;
	reg c_flag;
	reg [3:0]regs[7:0];
    reg [7:0]ram[15:0];
    reg [23:0] counter;
    reg [2:0] x=0;
    reg [3:0] y=0;
    reg [1:0] modeReg=0;
    
    assign leds[0]=!regs[6][0];
    assign leds[1]=!regs[6][1];
    assign leds[2]=!regs[6][2];
    assign leds[3]=!regs[6][3];
    assign leds[4]=1;
    assign leds[5]=!c_flag;
//    assign col=(((counter[15:13]==y[2:0])&& (counter[21]))?1<<x:0)^((btn!=4'b1001)?(ram[counter[15:13]+(y&4'b1000)]):regs[counter[15:13]]);
//    assign col=(((counter[15:13]==y[2:0])&& (counter[21]))?1<<x:0)^((mode==1)?(ram[counter[15:13]+(y&4'b1000)]):regs[counter[15:13]]);
    assign col=(((counter[15:13]==y[2:0])&& ((mode==1)?(counter[21]):0)?1<<x:0))^((mode==1)?(ram[counter[15:13]+(y&4'b1000)]):regs[counter[15:13]]);

    assign row = ~(1<<counter[15:13]);
    assign dout = ram[regs[7]];

    initial begin
//        `include "short.asm"
    end

/*
	always @(posedge mode) begin
            modeReg[0]=Abtn;
            modeReg[1]=Bbtn;
    end
*/

/*
	always @(posedge counter[21]) begin 
      case(btn)
        4'b0111: x=x+1;
        4'b1101: y=y+1;
        4'b1011: y=y-1;
        4'b1110: x=x-1;
//        4'b1001: y=regs[7];
	  endcase
      if (mode==1) begin
        if (Abtn==0) ram[y][x]=1;
        if (Bbtn==0) ram[y][x]=0;
      end
//      if (mode==0) y=regs[7];
   end
*/

	always @(posedge counter[21]) begin 
        if (mode==1) begin
            if (btn[3]==0) x=x+1;
            if (btn[1]==0) y=y+1;
            if (btn[2]==0) y=y-1;
            if (btn[0]==0) x=x-1;
            if (Abtn==0) ram[y][x]=1;
            if (Bbtn==0) ram[y][x]=0;
     end 
        else if (btn==4'b1111) y=regs[7];
   end


//	always @(posedge counter[23]) begin
//            if (btn!=4'b1001) regs[7]=y;
	always @(posedge counter[23]) if (mode==0) begin
    if (Abtn==1) regs[7]=y;
    else begin
/*MOV*/     if (0==(dout&192)) regs[((dout&56)>>3)]=regs[dout&7]; 
/*ADD*/     if (64==(dout&248)) begin if (regs[0]+regs[dout&7]>15) c_flag=1;regs[0]=regs[dout&7]+regs[0];end
/*OR*/      if (72==(dout&248)) regs[0]=regs[0]|regs[dout&7];
/*AND*/     if (80==(dout&248)) regs[0]=regs[0]&regs[dout&7];
/*XOR*/     if (88==(dout&248)) regs[0]=regs[0]^regs[dout&7];
/*NOT*/     if (104==(dout&248)) regs[dout&7]=~regs[dout&7];
/*RLOTATE*/ if (112==(dout&248)) regs[dout&7]=((regs[dout&7])>>1)|((regs[dout&7]&1) << 3);
/*LLOTATE*/ if (120==(dout&248)) regs[dout&7]=((regs[dout&7])<<1)|((regs[dout&7]&8) >> 3);
/*INC*/     if (96==(dout&248)) begin if (regs[dout&7]+1>15) c_flag=1;regs[dout&7]=regs[dout&7]+1;end
/*JMP*/     if (144==(dout&240)) regs[7]=dout&15;
/*MVI*/     if (160==(dout&240)) regs[0]=dout&15;
/*JNC*/     if (128==(dout&240)) begin regs[7]=((c_flag)?regs[7]+1:dout&15);c_flag=0;end
/*PC++*/    if ((144!=(dout&240)&&(128!=(dout&240)))) regs[7]=regs[7]+1;	
    end
end
    always @(posedge clk) counter = counter + 1;
endmodule