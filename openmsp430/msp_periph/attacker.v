module attacker (

// OUTPUTs
    per_dout,                       // Peripheral data output
    dma_addr,
    dma_en,
    dma_din,
    dma_we,

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                        // Main system reset
    dma_ready,
    dma_dout
);

// OUTPUTs
//=========
output      [15:0] per_dout;        // Peripheral data output
output             dma_en;
output      [15:1] dma_addr;
output      [15:0] dma_din;         // Direct Memory Access data input
output       [1:0] dma_we;

// INPUTs
//=========
input              mclk;            // Main system clock
input       [13:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc_rst;         // Main system reset
input              dma_ready;       // DMA ready
input       [15:0] dma_dout;        // DMA data out

//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0070;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  4;

// Register addresses offset
parameter [DEC_WD-1:0] ATT_ACTIVATE       =  'h0;


// Register one-hot decoder utilities
parameter              DEC_SZ      =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] ATT_ACTIVATE_D       = (BASE_REG << ATT_ACTIVATE);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};

// Register address decode
wire [DEC_SZ-1:0] reg_dec = (ATT_ACTIVATE_D       & {DEC_SZ{(reg_addr==ATT_ACTIVATE)}});

// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

reg  [15:1] dma_addr = 15'h0;
reg         dma_en   = 1'b0;
reg  [1:0]  dma_we   = 2'b00;

reg activated = 1'b0;

always @(posedge mclk or posedge puc_rst) begin
    if (puc_rst)                activated = 1'b0;
    if (reg_wr[ATT_ACTIVATE])   activated = 1'b1;
end

wire [15:0] per_dout   =  (per_addr == 14'h00B4 && activated) ? 16'h1 : 16'h0;

endmodule
