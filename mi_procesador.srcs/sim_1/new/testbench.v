module testbench ();
	reg clk;
	reg reset;
	wire [31:0] WriteData, DataAdr;
	wire MemWrite;

	// instantiate device to be tested
	top dut(
		.clk(clk),
		.reset(reset),
		.WriteData(WriteData),
		.Adr(DataAdr),
		.MemWrite(MemWrite)
	);

	//initicializando test

	initial begin
		reset <=1; #(22); reset <= 0;
	end

	//generando clocks
	always begin
		clk <= 1; #(5); clk <= 0; #(5);
	end

	//check results
	always @(negedge clk)
		begin
			if(MemWrite) begin
				if(DataAdr == 88 & WriteData === 32'h2ffffffe) begin
					$display("Simulation succeeded");
					$stop;
				end else begin
					$display("Simulation failed");
					$stop;
				end
			end
			end
endmodule