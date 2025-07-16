
module instruction_cache_way (
	A,
	CLK,
	D,
	WE,
	SPO);

input [4 : 0] A;
input CLK;
input [52 : 0] D;
input WE;
output [52 : 0] SPO;

// synopsys translate_off

	C_DIST_MEM_V4_1 #(
		5,	// c_addr_width
		"0",	// c_default_data
		1,	// c_default_data_radix
		32,	// c_depth
		0,	// c_family
		1,	// c_generate_mif
		1,	// c_has_clk
		1,	// c_has_d
		0,	// c_has_dpo
		0,	// c_has_dpra
		0,	// c_has_i_ce
		0,	// c_has_qdpo
		0,	// c_has_qdpo_ce
		0,	// c_has_qdpo_clk
		0,	// c_has_qdpo_rst
		0,	// c_has_qdpo_srst
		0,	// c_has_qspo
		0,	// c_has_qspo_ce
		0,	// c_has_qspo_rst
		0,	// c_has_qspo_srst
		0,	// c_has_rd_en
		1,	// c_has_spo
		0,	// c_has_spra
		1,	// c_has_we
		0,	// c_latency
		"instruction_cache_way0.mif",	// c_mem_init_file
		1,	// c_mem_type
		0,	// c_mux_type
		0,	// c_qce_joined
		0,	// c_qualify_we
		0,	// c_read_mif
		0,	// c_reg_a_d_inputs
		0,	// c_reg_dpra_input
		0,	// c_sync_enable
		53)	// c_width
	inst (
		.A(A),
		.CLK(CLK),
		.D(D),
		.WE(WE),
		.SPO(SPO));


// synopsys translate_on

SRAM1RW32x32 mem0 (
    .A  ( A ),      // Address input
    .WEB( !WE ),              // Write enable input
    .I  ( D[31:0] ),      // Data input
    .CE ( CLK ),
    .CSB( 1'b0 ),
    .OEB( WE ),
    .O  ( SPO[31:0] ) // Data output
);

SRAM1RW32x32 mem1 (
    .A  ( A ),      // Address input
    .WEB( !WE ),              // Write enable input
    .I  ( D[52:32] ),      // Data input
    .CE ( CLK ),
    .CSB( 1'b0 ),
    .OEB( WE ),
    .O  ( SPO[52:32] ) // Data output
);

endmodule

