module ate(clk,reset,pix_data,bin,threshold);
input clk;
input reset;
input [7:0] pix_data;
output bin;
output [7:0] threshold;
reg [7:0] threshold;
reg bin;

reg [7:0] data [63:0];	
reg [6:0]counter; 
reg [7:0]min0;
reg [7:0]max0; 
reg [4:0]block; 
integer i;	
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			block <= 5'd0;
		end
		else
			begin
				if((counter == 7'd63)&&(block == 5'd5))
				begin
					block <= 5'd0;
				end
				else if(counter == 7'd63)
				begin
					block <= block + 5'd1;
				end
			end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			counter <= 7'd0;
		end
		else
		begin
			counter <= counter + 7'd1;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			for(i = 0; i < 64; i = i + 1)
			begin
				data[i] <= 8'd0;
			end
		end
		else
		begin
			data[counter] <= pix_data;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			max0 <= 8'd0;
		end
		else
		begin
		   if(counter == 7'd0)
		   begin
		      max0 <= pix_data;
		   end
			else if(max0 < pix_data)
			begin
				max0 <= pix_data;
			end
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			min0 <= 8'hff;
		end
		else
		begin
		   if(counter == 7'd0)
		   begin
		      min0 <= pix_data;
		   end
			else if(min0 > pix_data)
			begin
				min0 <= pix_data;
			end
		end
	end

	//output
	wire dout;
	wire [7:0]avg;
	wire [7:0]thout;
	wire [8:0]sum;
	
	assign sum = {1'b0, min0} + {1'b0, max0};
	assign avg = (sum[0]) ? (sum + 9'd01) >> 1 : sum >> 1;
	assign dout = (((block == 5'd1)||(block == 5'd0))) ? 1'b0 :
	              ((counter == 7'd0)&&(data[0] >= avg)) ? 1'b1 : 
	              ((counter != 7'd0)&&(data[counter] >= threshold)) ? 1'b1 : 1'b0;
	              
				 
	assign thout = (((block == 5'd1)||(block == 5'd0))) ? 8'd0 : avg;
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			bin <= 1'b0;
		end
		else
		begin
			bin <= dout;
		end
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			threshold <= 8'd0;
		end
		else
		begin
			if(counter == 7'd0)
			begin
				threshold <= thout;
			end
		end
	end
	
endmodule
