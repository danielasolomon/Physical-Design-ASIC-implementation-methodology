
module dma_fifo (
	clk,
	sinit,
	din,
	wr_en,
	rd_en,
	dout,
	full,
	empty);

input clk;
input sinit;
input [7 : 0] din;
input wr_en;
input rd_en;
output [7 : 0] dout;
output full;
output empty;


wire [7 : 0] dout;
wire full;
wire empty;
wire mem_wr_en;
wire mem_rd_en;

// synopsys translate_off

	SYNC_FIFO_V2_0 #(
		1,	// c_dcount_width
		0,	// c_enable_rlocs
		0,	// c_has_dcount
		0,	// c_has_rd_ack
		0,	// c_has_rd_err
		0,	// c_has_wr_ack
		0,	// c_has_wr_err
		1,	// c_memory_type
		0,	// c_ports_differ
		1,	// c_rd_ack_low
		1,	// c_rd_err_low
		8,	// c_read_data_width
		512,	// c_read_depth
		8,	// c_write_data_width
		512,	// c_write_depth
		1,	// c_wr_ack_low
		1)	// c_wr_err_low
	inst (
		.CLK(clk),
		.SINIT(sinit),
		.DIN(din),
		.WR_EN(wr_en),
		.RD_EN(rd_en),
		.DOUT(dout),
		.FULL(full),
		.EMPTY(empty));


// synopsys translate_on

reg [8:0] wptr;
reg [8:0] rptr;

always @(posedge clk) begin
    if (sinit) begin
        wptr <= 9'b0;
    end
    else begin
        if (wr_en & !full) begin
            wptr <= wptr + 1;
        end
    end
end

always @(posedge clk) begin
    if (sinit) begin
        rptr <= 9'b0;
    end
    else begin
        if (rd_en & !empty) begin
            rptr <= rptr + 1;
        end
    end
end

assign mem_wr_en = !( wr_en & !full );
assign mem_rd_en = !( rd_en & !empty );

SRAM2RW512x8 fifo_mem (
    .A1   ( wptr      ),
    .WEB1 ( mem_wr_en ),
    .I1   ( din       ),
    .CE1  ( clk       ),
    .OEB1 ( 1'b1      ),
    .CSB1 ( 1'b0      ),
    .O1   (           ),
    .A2   ( rptr      ),
    .WEB2 ( 1'b1      ),
    .I2   ( 8'b0      ),
    .CE2  ( clk       ),
    .OEB2 ( mem_rd_en ),
    .CSB2 ( 1'b0      ),
    .O2   ( dout      )
);    
  
assign full = (wptr + 1) == rptr;
assign empty = wptr == rptr;


endmodule

