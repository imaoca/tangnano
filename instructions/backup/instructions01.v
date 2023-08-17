module cpu(input rst,input clk,input[3:0] btn,
    output [7:0]col, output [7:0]row,
    output [5:0]leds);

    wire [7:0]dout;
	reg c_flag;
	reg [3:0]regs[7:0];
    reg [7:0]ram[15:0];
    reg [23:0] counter;

    assign leds[0]=!c_flag;
    assign leds[1]=1;
    assign leds[2]=1;
    assign leds[3]=1;
    assign leds[4]=1;
    assign leds[5]=1;
    assign col={4'b0000,regs[counter[15:13]]};
    assign row[0]=(counter[15:13]==0?0:1);
    assign row[1]=(counter[15:13]==1?0:1);
    assign row[2]=(counter[15:13]==2?0:1);
    assign row[3]=(counter[15:13]==3?0:1);
    assign row[4]=(counter[15:13]==4?0:1);
    assign row[5]=(counter[15:13]==5?0:1);
    assign row[6]=(counter[15:13]==6?0:1);
    assign row[7]=(counter[15:13]==7?0:1);

    assign dout = ram[regs[7]];

    initial begin
        `include "jnc2.asm"
    end
    
	always @(posedge counter[23]  or negedge rst)
	  if(rst==0) {regs[0],regs[1],regs[2],regs[3],regs[4],regs[6],regs[7],c_flag}=0;
	  else begin
	   regs[5]=btn;
       if (8'h70==(dout&8'hf8)) regs[dout&7]=((regs[dout&7])>>1)|((regs[dout&7]&1) << 3);
       if (8'h78==(dout&8'hf8)) regs[dout&7]=((regs[dout&7])<<1)|((regs[dout&7]&8) >> 3);
       if (8'h00==(dout&8'hc0)) regs[(dout&8'h38)>>3]=regs[dout&7]; 
       if (8'h60==(dout&8'hf8)) begin if (regs[dout&7]+1>15) c_flag=1;regs[dout&7]=regs[dout&7]+1;end
       if (8'h40==(dout&8'hf8)) begin if (regs[0]+regs[dout&7]>15) c_flag=1;regs[0]=regs[dout&7]+regs[0];end
       if (8'h48==(dout&8'hf8)) regs[0]=regs[0]|regs[dout&7];
       if (8'h50==(dout&8'hf8)) regs[0]=regs[0]&regs[dout&7];
       if (8'h58==(dout&8'hf8)) regs[0]=regs[0]^regs[dout&7];
       if (8'h68==(dout&8'hf8)) regs[dout&7]=~regs[dout&7];
       if (8'h90==(dout&8'hf0)) regs[7]=dout&15;
       if (8'ha0==(dout&8'hf0)) regs[0]=dout&15;
       if (8'h80==(dout&8'hf0)) begin regs[7]=((c_flag)?regs[7]+1:dout&15);c_flag=0;end
       if ((8'h90!=(dout&8'hf0)&&(8'h80!=(dout&8'hf0)))) regs[7]=regs[7]+1;	
end

    always @(posedge clk) counter <= counter + 1;

endmodule