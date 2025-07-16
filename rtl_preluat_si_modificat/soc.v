/*********************************************************
 MODULE:		Top Level System On A Chip Design

 FILE NAME:	soc.v
 DATE:		May 7th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of System On a Chip Verilog code.
 It will instantiate the following blocks in the ASIC:

 1)   Vertex STARTUP
 2)	DLL
 3)	RISC uProcessor
 4)	DMA Cntrl
 5)	LRU Data Cache
 6)	LRU Instruction Cache
 7)	Bus Arbiter
 8)	UART
 9)	Timer
 10)  Flash Controller
 11)	SDRAM Controller

 Hossein Amidi
 (C) May 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module soc(	// Inputs
						clk,
						reset,
						irq,
						ser_rxd,
						flash_datain,
						mem_datain,
						// Outputs
						pll_lock,
						addr,
						cs,
						ras,
						cas,
						we,
						dqm,
						cke,
						ba,
						pllclk,
						halted,
						ser_txd,
						flash_cle,
						flash_ale,
						flash_ce,
						flash_re,
						flash_we,
						flash_wp,
						flash_rb,
						flash_irq,
						flash_dataout,
						mem_dataout,
						mem_addr,
						mem_req,
						mem_rdwr,
						// Inouts
						dq
						);

// Parameter
`include        "parameter.v"


// Inputs
input clk;
input reset;
input irq;
input ser_rxd;
input [flash_size - 1 : 0]flash_datain;
input [data_size - 1 : 0]mem_datain;

// Outputs
output pll_lock;
output [add_size - 1 : 0]addr;
output [cs_size  - 1 : 0]cs;
output ras;
output cas;
output we;
output [dqm_size - 1 : 0]dqm;
output cke;
output [ba_size - 1 : 0]ba;
output pllclk;
output halted;
output ser_txd;
output flash_cle;
output flash_ale;
output flash_ce;
output flash_re;
output flash_we;
output flash_wp;
output flash_rb;
output flash_irq;
output [flash_size - 1 : 0]flash_dataout;
output [data_size -1 : 0]mem_dataout;
output [padd_size - 1 : 0]mem_addr;
output mem_req;
output mem_rdwr;

// Inouts
inout [data_size - 1 : 0]dq;


// Signal Declarations
wire clk;
wire reset;
wire irq;
wire [add_size - 1 : 0]addr;
wire [cs_size - 1 : 0]cs;
wire ras;
wire cas;
wire we;
wire [dqm_size - 1 : 0]dqm;
wire cke;
wire [ba_size - 1 : 0]ba;
wire pllclk;
wire halted;
wire [data_size - 1 : 0]dq;

wire system_irq;

// RISC Signal Declarations
wire [irq_size - 1 : 0]interrupt;
wire cmdack;
wire [arbiter_bus_size - 1 : 0]bus_grant;
wire [data_size - 1 : 0]dcache_host_datain;
wire [data_size - 1 : 0]icache_host_datain;
wire dcache_hit;
wire dcache_miss;
wire icache_hit;
wire icache_miss;
wire [data_size - 1 : 0]dma_host_datain;
wire [padd_size - 1 : 0]host_addr;
wire [cmd_size - 1 : 0]host_cmd;
wire [dqm_size - 1 : 0]host_dm;
wire [arbiter_bus_size - 1 : 0]bus_request;
wire dcache_request;
wire icache_request;
wire [data_size - 1 : 0]dma_host_dataout; 
wire [data_size - 1 : 0]dcache_host_dataout;
wire [data_size - 1 : 0]icache_host_dataout;

// DMA Signal Declarations
wire [fifo_size - 1 : 0]dma_rd_datain;
wire [fifo_size - 1 : 0]dma_wr_datain;
wire dma_irq;
wire [padd_size - 1 : 0]dma_rd_addr;
wire [padd_size - 1 : 0]dma_wr_addr;
wire [cmd_size - 1 : 0]dma_rd_cmd;
wire [fifo_size - 1 : 0]dma_wr_dataout; 
wire [fifo_size - 1 : 0]dma_rd_dataout; 
wire dma_busy;


// LRU Data Cache Signal Declarations
wire [data_size - 1 : 0]dcache_datain;
wire [padd_size - 1 : 0]dcache_addr;
wire [cmd_size - 1 : 0]dcache_cmd;
wire [data_size - 1 : 0]dcache_dataout; 
wire [padd_size - 1 : 0]sdram_addr;
wire [cmd_size - 1 : 0]sdram_cmd;


// LRU Instruction Cache Signal Declarations
wire [data_size - 1 : 0]icache_datain;
wire [padd_size - 1 : 0]icache_addr;
wire [cmd_size - 1 : 0]icache_cmd;
wire [data_size - 1 : 0]icache_dataout; 


// Bus Arbiter Signal Declarations
wire [data_size - 1 : 0]sdram_datain;
wire [data_size - 1 : 0]sdram_dataout;


// SDRAM Controller Signal Declarations


// UART Signal Declarations
wire uart_cs;
wire uart_rd;
wire uart_wr;
wire ser_rxd;
wire ser_txd;
wire [data_size - 1 : 0]uart_host_datain;
wire [data_size - 1 : 0]uart_host_dataout;

// Timer Signal Declarations
wire [data_size - 1 : 0]timer_host_datain;
wire timer_irq;
wire [data_size - 1 : 0]timer_host_dataout;


// Flash Controller Signal Decelaration
wire [data_size - 1 : 0]flash_host_dataout;
wire [flash_size - 1 : 0]flash_datain;
wire [data_size - 1 : 0]flash_host_datain;
wire flash_cle;
wire flash_ale;
wire flash_ce;
wire flash_re;
wire flash_we;
wire flash_wp;
wire flash_rb;
wire flash_irq;
wire [flash_size - 1 : 0]flash_dataout;


// Memory
wire [data_size - 1 :0]mem_dataout;
wire [data_size - 1 :0]mem_datain;
wire mem_req;
wire mem_rdwr;
wire [padd_size - 1 : 0]mem_addr;

//STARTUP_VIRTEX u22 (.GSR(reset));

/*--------------------------- DLL Instantiation Block ----------------------------*/
wire CLKIN_w;
wire clk0;

wire CLK0_dll, CLK90_dll, CLK180_dll, CLK2X_dll, CLKDV2_dll;
wire clk0_90, clk0_180, clk0_2x, clk0_dv2;
wire pll_lock;

// PAD Declarations

wire 				  clk_w          ;
wire 				  reset_w        ;
wire 				  irq_w          ;
wire 				  ser_rxd_w      ;
wire [flash_size-1:0] flash_datain_w ; //flash_size = 8;
wire [data_size-1:0]  mem_datain_w   ; //data_size  = 32;
					
wire                  pll_lock_w     ;
wire                  ras_w 	     ;
wire                  cas_w          ;
wire                  we_w           ;
wire                  cke_w          ;
wire                  pllclk_w       ;
wire                  halted_w       ;
wire                  ser_txd_w      ;
wire                  flash_cle_w    ;
wire                  flash_ale_w    ;
wire                  flash_ce_w     ;
wire                  flash_re_w     ;
wire                  flash_we_w     ;
wire                  flash_wp_w     ;
wire                  flash_rb_w     ;
wire                  flash_irq_w    ;
wire                  mem_req_w      ;
wire                  mem_rdwr_w     ;            
wire [add_size-1:0]   addr_w         ; //add_size	= 12;
wire [cs_size-1:0]    cs_w           ; //cs_size    = 2;
wire [dqm_size-1:0]   dqm_w          ; //dqm_size   = 4;
wire [ba_size-1:0]    ba_w           ; //ba_size    = 2;
wire [flash_size-1:0] flash_dataout_w; //flash_size = 8;
wire [data_size-1:0]  mem_dataout_w  ; //data_size  = 32;
wire [padd_size-1:0]  mem_addr_w     ; //padd_size  = 24;
wire                  mem_dataout_en;


VDD_EW i_vdd ( );
VSS_EW i_vss ( );
IOVDD_EW i_iovdd ( );
IOVSS_EW i_iovss ( );



// PAD Inputs

I1025_EW clk_pad   						  ( .DOUT( clk_w                 ), .PADIO( clk                 ), .R_EN( 1'b1 ) );  //input clk;
I1025_EW reset_pad 						  ( .DOUT( reset_w               ), .PADIO( reset               ), .R_EN( 1'b1 ) );  //input reset;
I1025_EW irq_pad   						  ( .DOUT( irq_w                 ), .PADIO( irq                 ), .R_EN( 1'b1 ) );  //input irq;
I1025_EW ser_rxd_pad   					  ( .DOUT( ser_rxd_w             ), .PADIO( ser_rxd             ), .R_EN( 1'b1 ) );  //input ser_rxd;
I1025_EW flash_datain_pad [flash_size-1:0]( .DOUT( flash_datain_w        ), .PADIO( flash_datain        ), .R_EN( 1'b1 ) );  //input [flash_size - 1 : 0]flash_datain;
I1025_EW mem_datain_pad   [data_size-1:0] ( .DOUT( mem_datain_w          ), .PADIO( mem_datain          ), .R_EN( 1'b1 ) );  //input [data_size - 1 : 0]mem_datain;



// PAD Outputs

D8I1025_EW pll_lock_pad                      ( .DIN( pll_lock_w     ), .EN( 1'b1 ), .PADIO ( pll_lock     ) );    //output pll_lock;
D8I1025_EW ras_pad 		                     ( .DIN( ras_w 	        ), .EN( 1'b1 ), .PADIO ( ras	      ) );    //output ras;
D8I1025_EW cas_pad 		                     ( .DIN( cas_w          ), .EN( 1'b1 ), .PADIO ( cas          ) );    //output cas;
D8I1025_EW we_pad 		                     ( .DIN( we_w           ), .EN( 1'b1 ), .PADIO ( we           ) );    //output we;
D8I1025_EW cke_pad 		                     ( .DIN( cke_w          ), .EN( 1'b1 ), .PADIO ( cke          ) );    //output cke;
D8I1025_EW pllclk_pad 	                     ( .DIN( pllclk_w       ), .EN( 1'b1 ), .PADIO ( pllclk       ) );    //output pllclk;
D8I1025_EW halted_pad 	                     ( .DIN( halted_w       ), .EN( 1'b1 ), .PADIO ( halted       ) );    //output halted;
D8I1025_EW ser_txd_pad 	                     ( .DIN( ser_txd_w      ), .EN( 1'b1 ), .PADIO ( ser_txd      ) );    //output ser_txd;
D8I1025_EW flash_cle_pad                     ( .DIN( flash_cle_w    ), .EN( 1'b1 ), .PADIO ( flash_cle    ) );    //output flash_cle;
D8I1025_EW flash_ale_pad                     ( .DIN( flash_ale_w    ), .EN( 1'b1 ), .PADIO ( flash_ale    ) );    //output flash_ale;
D8I1025_EW flash_ce_pad                      ( .DIN( flash_ce_w     ), .EN( 1'b1 ), .PADIO ( flash_ce     ) );    //output flash_ce;
D8I1025_EW flash_re_pad                      ( .DIN( flash_re_w     ), .EN( 1'b1 ), .PADIO ( flash_re     ) );    //output flash_re;
D8I1025_EW flash_we_pad                      ( .DIN( flash_we_w     ), .EN( 1'b1 ), .PADIO ( flash_we     ) );    //output flash_we;
D8I1025_EW flash_wp_pad                      ( .DIN( flash_wp_w     ), .EN( 1'b1 ), .PADIO ( flash_wp     ) );    //output flash_wp;
D8I1025_EW flash_rb_pad                      ( .DIN( flash_rb_w     ), .EN( 1'b1 ), .PADIO ( flash_rb     ) );    //output flash_rb;
D8I1025_EW flash_irq_pad                     ( .DIN( flash_irq_w    ), .EN( 1'b1 ), .PADIO ( flash_irq    ) );    //output flash_irq;
D8I1025_EW mem_req_pad                       ( .DIN( mem_req_w      ), .EN( 1'b1 ), .PADIO ( mem_req      ) );    //output mem_req;
D8I1025_EW mem_rdwr_pad                      ( .DIN( mem_rdwr_w     ), .EN( 1'b1 ), .PADIO ( mem_rdwr     ) );    //output mem_rdwr;
                                                                                                          
D8I1025_EW addr_pad          [add_size-1:0]  ( .DIN( addr_w         ), .EN( 1'b1 ), .PADIO ( addr         ) );    //output [add_size - 1 : 0]addr;
D8I1025_EW cs_pad            [cs_size-1:0]   ( .DIN( cs_w           ), .EN( 1'b1 ), .PADIO ( cs           ) );    //output [cs_size  - 1 : 0]cs;
D8I1025_EW dqm_pad           [dqm_size-1:0]  ( .DIN( dqm_w          ), .EN( 1'b1 ), .PADIO ( dqm          ) );    //output [dqm_size - 1 : 0]dqm;
D8I1025_EW ba_pad            [ba_size-1:0]   ( .DIN( ba_w           ), .EN( 1'b1 ), .PADIO ( ba           ) );    //output [ba_size - 1 : 0]ba;
D8I1025_EW flash_dataout_pad [flash_size-1:0]( .DIN( flash_dataout_w), .EN( 1'b1 ), .PADIO ( flash_dataout) );    //output [flash_size - 1 : 0]flash_dataout;
D8I1025_EW mem_dataout_pad   [data_size-1:0] ( .DIN( mem_dataout_w  ), .EN( mem_dataout_en ), .PADIO ( mem_dataout  ) );    //output [data_size -1 : 0]mem_dataout;
D8I1025_EW mem_addr_pad      [padd_size-1:0] ( .DIN( mem_addr_w     ), .EN( 1'b1 ), .PADIO ( mem_addr     ) );    //output [padd_size- 1 : 0]mem_addr;






// Assignment statments
assign mem_addr_w = host_addr;
assign system_irq = irq_w;
assign interrupt = {timer_irq,dma_irq,system_irq};

/*--------------------------- Module Instantiation ----------------------------*/



//IBUFG clkpad (.I(clk), .O(CLKIN_w));
//assign CLKIN_w = clk;

//CLKDLL dll_0 (.CLKIN(CLKIN_w), .CLKFB(clk0), .RST(reset), 
//            .CLK0(CLK0_dll), .CLK90(CLK90_dll), .CLK180(CLK180_dll), .CLK270(),
//            .CLK2X(CLK2X_dll), .CLKDV(CLKDV2_dll), .LOCKED(pll_lock));

PLL pll(
	.DVDD	   (	   ),
	.AVSS      (	   ),
	.AVDD      (	   ),
	.DVSS      (	   ),
	.REF_CLK   (clk_w  ),
	.FB_CLK    (clk0   ),
	.FB_MODE   (1'b1   ),
	.PLL_BYPASS(1'b0   ),
			   
	.CLK_X4    (clk0_2x),
	.CLK_X2    (clk0   ),
	.CLK_X1    (	   )
);

//BUFG  u1 (.I(CLK0_dll),   .O(clk0));
//BUFG  u2 (.I(CLK180_dll),  .O(clk0_180));
//BUFG  u3 (.I(CLK2X_dll), .O(clk0_2x));
//assign clk0 = CLK0_dll;
//assign clk0_180 = CLK180_dll;
//assign clk0_2x = CLK2X_dll;
//assign pllclk = clk0_180;

assign pllclk_w = clk0;




/****************************** Sub Level Block Instantiation ****************************/

risc uProcessor0(	// Input
						.reset(reset_w),
						.clk0(clk0),
						.pll_lock(1'b1),
						.interrupt(interrupt),
						.cmdack(cmdack),
						.dcache_datain(dcache_host_datain),
						.dcache_hit(dcache_hit),
						.dcache_miss(dcache_miss),
						.icache_datain(icache_host_datain),
						.icache_hit(icache_hit),
						.icache_miss(icache_miss),
						.dma_datain(dma_host_datain),
						.dma_busy(dma_busy),
						.timer_host_datain(timer_host_datain),
						.flash_host_datain(flash_host_datain),
						.uart_host_datain(uart_host_datain),
						.mem_datain(mem_datain_w),
						// Output
						.paddr(host_addr),
						.cmd(host_cmd),
						.dm(host_dm),
						.dcache_request(dcache_request),
						.icache_request(icache_request),
						.dma_dataout(dma_host_dataout),
						.dcache_dataout(dcache_host_dataout),
						.icache_dataout(icache_host_dataout),
						.timer_host_dataout(timer_host_dataout),
						.flash_host_dataout(flash_host_dataout),
						.uart_host_dataout(uart_host_dataout),
						.mem_dataout(mem_dataout_w),
						.mem_dataout_en(mem_dataout_en),
						.mem_req(mem_req_w),
						.mem_rdwr(mem_rdwr_w),
						.halted(halted_w)
						);


dma_cntrl dma_cntrl0(// Input
							.reset(reset_w),
							.clk0(clk0),
							.dma_host_addr(host_addr),
							.dma_host_cmd(host_cmd),
							.dma_host_datain(dma_host_dataout),
							.dma_bus_grant(bus_grant[2]),
							.dma_rd_datain(dma_rd_datain),
							.dma_wr_datain(dma_wr_datain),
							// Output
							.dma_host_dataout(dma_host_datain),
							.dma_irq(dma_irq),
							.dma_bus_req(bus_request[2]),
							.dma_rd_addr(dma_rd_addr),
							.dma_wr_addr(dma_wr_addr),
							.dma_wr_dataout(dma_wr_dataout),
							.dma_rd_cmd(dma_rd_cmd),
							.dma_busy(dma_busy),
							.uart_cs(uart_cs),
							.uart_rd(uart_rd),
							.uart_wr(uart_wr),
							.dma_rd_dataout(dma_rd_dataout)
							);



lru_data_cache lru_data_cache0(// Input
										.reset(reset_w),
										.clk0(clk0),
										.cache_host_addr(host_addr),
										.cache_host_cmd(host_cmd),
										.cache_request(dcache_request),
										.cache_host_datain(dcache_host_dataout),
										.cache_bus_grant(bus_grant[0]),
										.cache_datain(dcache_datain),
										// Output
										.cache_host_dataout(dcache_host_datain),
										.cache_hit(dcache_hit),
										.cache_miss(dcache_miss),
										.cache_bus_request(bus_request[0]),
										.cache_addr(dcache_addr),
										.cache_cmd(dcache_cmd),
										.cache_dataout(dcache_dataout)
										);


lru_instruction_cache lru_inst_cache0(// Input
													.reset(reset_w),
													.clk0(clk0),
													.cache_host_addr(host_addr),
													.cache_host_cmd(host_cmd),
													.cache_request(icache_request),
													.cache_host_datain(icache_host_dataout),
													.cache_bus_grant(bus_grant[1]),
													.cache_datain(icache_datain),
													// Output
													.cache_host_dataout(icache_host_datain),
													.cache_hit(icache_hit),
													.cache_miss(icache_miss),
													.cache_bus_request(bus_request[1]),
													.cache_addr(icache_addr),
													.cache_cmd(icache_cmd),
													.cache_dataout(icache_dataout)
													);


bus_arbiter  bus_arbiter0(	// Input
									.reset(reset_w),
									.clk0(clk0),
									.bus_request(bus_request),
									.dma_dataout(dma_wr_dataout),
									.dma_addr(dma_rd_addr),
									.dma_cmd(dma_rd_cmd),
									.dcache_dataout(dcache_dataout),
									.dcache_addr(dcache_addr),
									.dcache_cmd(dcache_cmd),
									.icache_dataout(icache_dataout),
									.icache_addr(icache_addr),
									.icache_cmd(icache_cmd),
									.sdram_dataout(sdram_dataout),
									// Output
									.bus_grant(bus_grant),
									.dma_datain(dma_wr_datain),
									.dcache_datain(dcache_datain),
									.icache_datain(icache_datain),
									.sdram_addr(sdram_addr),
									.sdram_cmd(sdram_cmd),
									.sdram_datain(sdram_datain)
									);


uart  uart0(// Input
				.reset(reset_w),
				.clk0(clk0),
				.uart_addr(dma_wr_addr),
				.uart_host_addr(host_addr),
				.uart_host_cmd(host_cmd),
				.uart_cmd(dma_rd_cmd),
				.uart_host_datain(uart_host_dataout),
				.uart_cs(uart_cs),
				.uart_rd(uart_rd),
				.uart_wr(uart_wr),
				.ser_rxd(ser_rxd_w),
				.uart_datain(dma_rd_dataout),
				// Output
				.ser_txd(ser_txd_w),
				.uart_host_dataout(uart_host_datain),
				.uart_dataout(dma_rd_datain)
				);


timer 	timer0(	// Input
						.reset(reset_w),
						.clk0(clk0),
						.timer_host_datain(timer_host_dataout),
						.timer_cmd(host_cmd),
						.timer_addr(host_addr),
						// Output
						.timer_host_dataout(timer_host_datain),
						.timer_irq(timer_irq)
						);


flash_ctrl flash_ctrl0(// Inputs
								.reset(reset_w),
								.clk0(clk0),
								.flash_host_addr(host_addr),
								.flash_host_cmd(host_cmd),
								.flash_host_dataout(flash_host_dataout),
								.flash_datain(flash_datain_w),
								// Outputs
								.flash_host_datain(flash_host_datain),
								.flash_cle(flash_cle_w),
								.flash_ale(flash_ale_w),
								.flash_ce(flash_ce_w),
								.flash_re(flash_re_w),
								.flash_we(flash_we_w),
								.flash_wp(flash_wp_w),
								.flash_rb(flash_rb_w),
								.flash_irq(flash_irq_w),
								.flash_dataout(flash_dataout_w)
								);



sdram_ctrl sdram_ctrl0(// Inputs
								.clk0(clk0),
								.clk0_2x(clk0_2x),
								.reset(reset_w),
								.paddr(sdram_addr),
								.cmd(sdram_cmd),
								.dm(host_dm),
								.datain(sdram_datain),
								// Outputs
								.cmdack(cmdack),
								.addr(addr_w),
								.cs(cs_w),
								.ras(ras_w),
								.cas(cas_w),
								.we(we_w),
								.dqm(dqm_w),
								.cke(cke_w),
								.ba(ba_w),
								.dataout(sdram_dataout),
								// Inouts
								.dq(dq)
								);

endmodule
