module sequencer(input rst,clk,btn3,[3:0]btn,output Vin,low,input Abtn,Bbtn,output [7:0]col,[7:0]row);
    assign low=0;
	reg [7:0]regs[7:0];
    reg [28:0] counter;
    reg [2:0] x,y;
    reg [15:0] cnt[7:0];
    wire[7:0]  mixer;
    wire[2:0] j; 
    wire[15:0] frq[7:0];
    reg [7:0] period;


    assign frq[0]=27000000/440;
    assign frq[1]=27000000/494;
    assign frq[2]=27000000/523;
    assign frq[3]=27000000/587;
    assign frq[4]=27000000/659;
    assign frq[5]=27000000/698;
    assign frq[6]=27000000/784;
    assign frq[7]=27000000/880;


    assign col=(((counter[15:13]==y)&& (counter[21]))?1<<x:0)^(regs[counter[15:13]] );
    assign row = ~(1<<counter[15:13]);

	always @(posedge counter[21]  or negedge rst)
	  if(rst==0) {regs[0],regs[1],regs[2],regs[3],regs[4],regs[5],regs[6],regs[7],x,y}=0;
	  else begin 
      if (btn3==1) begin
      case(btn)
        4'b0111: x=x+1;
        4'b1101: y=y+1;
        4'b1011: y=y-1;
        4'b1110: x=x-1;
	  endcase
      if (Abtn==0) regs[y][x]=1;
      if (Bbtn==0) regs[y][x]=0;
    end
    if (btn3==0) y = counter[26:24];
   end

   always @(posedge clk) counter <= counter + 1;

   initial begin
   end

    always @(posedge clk) counter=counter+1;
/*
    always @(posedge clk)  cnt[0]= (cnt[0]==27000000/440)? 0:cnt[0] + 1;    // A
    always @(posedge clk)  cnt[1]= (cnt[1]==27000000/494)? 0:cnt[1] + 1;    // B
    always @(posedge clk)  cnt[2]= (cnt[2]==27000000/523)? 0:cnt[2] + 1;    // C
    always @(posedge clk)  cnt[3]= (cnt[3]==27000000/587)? 0:cnt[3] + 1;    // D
    always @(posedge clk)  cnt[4]= (cnt[4]==27000000/659)? 0:cnt[4] + 1;    // E
    always @(posedge clk)  cnt[5]= (cnt[5]==27000000/698)? 0:cnt[5] + 1;    // F
    always @(posedge clk)  cnt[6]= (cnt[6]==27000000/784)? 0:cnt[6] + 1;    // G
    always @(posedge clk)  cnt[7]= (cnt[7]==27000000/880)? 0:cnt[7] + 1;    // A
*/
    integer k;
    always @(posedge clk)
        for (k=0;k<8;k=k+1) if (counter%frq[k]==0) period[k]=~period[k]; 

    assign j = counter[6:4];
    assign mixer=((regs[counter[26:24]]&(1<<j))!=0)?cnt[j][(j==7)?14:15]<<j:0;
    assign Vin = (btn3==0)?mixer[counter[3:1]]:0;

endmodule