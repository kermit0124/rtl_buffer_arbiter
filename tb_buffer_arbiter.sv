`timescale 1ns / 100ps
/* *******************************************************

# Macro: Verilog Universal
Version: 0.0.0
Date: 2023.03.26

*/

/* *******************************************************
# Notes

Macro:
- MKDEBUG
- KEEP_HIER
- SEG_FUNC_CLOG2
- M_REG_ASSIGN
- M_COMB_ASSIGN
- Mod cnt

## MKDEBUG
Chose one to comment as you want.""
```
// `define MKDEBUG `MKDBG_T
`define MKDEBUG
```

## KEEP_HIER
Chose one to comment as you want.
```
// `define KEEP_HIER (* keep_hierarchy="yes" *)
`define KEEP_HIER
```

## clog2
Call `SEG_FUNC_CLOG2 in the module.
Call `CBIT(value) when define reg/wire.

## Register and combination assign
Call `M_REG_ASSIGN(reg) after define combination and register.
Call `M_COMB_ASSIGN(reg) when always * as default stage.

## mod counter
Call `M_SEG_DEF_CNT_FLAG_GROUP(cnt) after define mod counter comb/reg.
Call `M_SEG_MOD_CNT_UPDATE_FLAG_GROUP(cnt) when always * as final stage. This segment generate flags(max/zero) whatever counter operation.
Call `M_SEG_MOD_CNT_INCR(cnt) or `M_SEG_MOD_CNT_DECR(cnt) when any operation if you want, make sure the counter is under mod value.
 */


/* *** Macro: Verilog Universal [BEGIN] *** */
`define MKDBG_T	(* MARK_DEBUG="true" *)
`define MKDBG_F	(* MARK_DEBUG="false" *)
// `define MKDEBUG `MKDBG_T
`define MKDEBUG
// `define KEEP_HIER (* keep_hierarchy="yes" *)
`define KEEP_HIER

`define CBIT(value) clog2(``value``)


`define SEG_FUNC_CLOG2  \
function integer clog2; \
    input integer value; \
    begin \
    for (clog2=0; value>0; clog2=clog2+1) \
    value = value>>1; \
    end \
endfunction

/* Register and combination assign */
`define M_REG_ASSIGN(regName)  \
always @ ( posedge clk) begin         \
    regName <= _``regName ;           \
end                                   \
// 
`define M_COMB_ASSIGN(regName)  \
    _``regName = regName ;           \
// 

/* Counter and flag macros --- v*/
/* flag max reg/combination name */
`ifndef _M_MOD_CNT_COMB_PREFIX
`define _M_MOD_CNT_COMB_PREFIX _
`endif
`ifndef _M_MOD_CNT_FLAG_MAX_SUFF
`define _M_MOD_CNT_FLAG_MAX_SUFF _flagMax
`endif
`ifndef _M_MOD_CNT_FLAG_ZERO_SUFF
`define _M_MOD_CNT_FLAG_ZERO_SUFF _flagZero
`endif
`define M_MOD_CNT_NAME(pre,name,suff) pre``name``suff
`define M_MOD_CNT_COMB(cnt_name,suff) `M_MOD_CNT_NAME(`_M_MOD_CNT_COMB_PREFIX,cnt_name,suff)
`define M_MOD_CNT_REG(cnt_name,suff) `M_MOD_CNT_NAME( ,cnt_name,suff)
`define M_MOD_CNT_FLAG_MAX_REG(cnt_name) `M_MOD_CNT_NAME( ,cnt_name,`_M_MOD_CNT_FLAG_MAX_SUFF )
`define M_MOD_CNT_FLAG_MAX_COMB(cnt_name) `M_MOD_CNT_NAME(`_M_MOD_CNT_COMB_PREFIX,cnt_name,`_M_MOD_CNT_FLAG_MAX_SUFF)
`define M_MOD_CNT_FLAG_ZERO_REG(cnt_name) `M_MOD_CNT_NAME( ,cnt_name,`_M_MOD_CNT_FLAG_ZERO_SUFF )
`define M_MOD_CNT_FLAG_ZERO_COMB(cnt_name) `M_MOD_CNT_NAME(`_M_MOD_CNT_COMB_PREFIX,cnt_name,`_M_MOD_CNT_FLAG_ZERO_SUFF)
`define M_MOD_CNT_PARAM_MOD_VALUE(cnt_name) `M_MOD_CNT_NAME(__,cnt_name,_MOD_VALUE)

/* Define macro for flag max */
`define M_SEG_DEF_CNT_FLAG_GROUP(cnt_name,mod_value)\
reg `M_MOD_CNT_FLAG_MAX_REG(cnt_name),`M_MOD_CNT_FLAG_MAX_COMB(cnt_name) ;\
reg `M_MOD_CNT_FLAG_ZERO_REG(cnt_name),`M_MOD_CNT_FLAG_ZERO_COMB(cnt_name) ;\
localparam `M_MOD_CNT_PARAM_MOD_VALUE(cnt_name) = mod_value ;\
always @ (posedge clk) begin\
    `M_MOD_CNT_FLAG_MAX_REG(cnt_name) <= `M_MOD_CNT_FLAG_MAX_COMB(cnt_name) ;\
    `M_MOD_CNT_FLAG_ZERO_REG(cnt_name) <= `M_MOD_CNT_FLAG_ZERO_COMB(cnt_name) ;\
end\
// 

`define M_SEG_MOD_CNT_INCR(cnt_name)\
`M_MOD_CNT_COMB(cnt_name, ) = `M_MOD_CNT_REG(cnt_name, ) + 1 ;\
if (`M_MOD_CNT_FLAG_MAX_REG(cnt_name)) begin\
    `M_MOD_CNT_COMB(cnt_name, ) = 0 ;\
end\
//

`define M_SEG_MOD_CNT_DECR(cnt_name)\
if (`M_MOD_CNT_FLAG_ZERO_REG(cnt_name)) begin\
    `M_MOD_CNT_COMB(cnt_name, ) = (`M_MOD_CNT_PARAM_MOD_VALUE(cnt_name))-1 ;\
end\
else begin\
    `M_MOD_CNT_COMB(cnt_name, ) = `M_MOD_CNT_REG(cnt_name, ) - 1 ;\
end\
//

`define M_SEG_MOD_CNT_UPDATE_FLAG_GROUP(cnt_name)\
`M_MOD_CNT_FLAG_MAX_COMB(cnt_name) = (`M_MOD_CNT_COMB(cnt_name, ) + 1) >= (`M_MOD_CNT_PARAM_MOD_VALUE(cnt_name)) ;\
`M_MOD_CNT_FLAG_ZERO_COMB(cnt_name) = (`M_MOD_CNT_COMB(cnt_name, )) == (0) ;\
// 
/* Counter and flag macros --- ^*/

// 
/* *** Macro: Verilog Universal [END] *** */

`define M_DEF_W(wid) wid-1:0

module tb_buffer_arbiter#(
    parameter C_BUFFER_DEPTH = 16
    ,parameter C_DATA_WIDTH = 32
    ,parameter C_FIFO_READ_LATENCY = 1
)
(
);


`SEG_FUNC_CLOG2

/*  */
genvar gvar0,gvar1 ;
integer fvar0 ;
integer fvar1 ;
integer fvar2 ;
integer fvar_col ;
integer fvar_row ;

reg clk = 0 ;
reg rstn = 0 ;

reg [`M_DEF_W(C_DATA_WIDTH)] init_info_data_i = 0 ;
reg init_info_data_vld_i = 0 ;
wire initial_done_o ;

reg in_info_get_req_i = 0 ;
wire in_info_get_ack_o ;
wire [`M_DEF_W(C_DATA_WIDTH)] in_info_get_data_o ;
wire in_info_get_overflow_o ;

reg in_info_put_req_i = 0 ;
wire in_info_put_ack_o ;
reg [`M_DEF_W(C_DATA_WIDTH)] in_info_put_data_i = 0 ;

reg out_info_get_req_i = 0 ;
wire out_info_get_ack_o ;
wire [`M_DEF_W(C_DATA_WIDTH)] out_info_get_data_o ;
wire out_info_get_underflow_o ;

reg out_info_put_req_i = 0 ;
wire out_info_put_ack_o ;
reg [`M_DEF_W(C_DATA_WIDTH)] out_info_put_data_i = 0 ;

wire exist_fifo_rstn_o ;
wire exist_fifo_wr_o ;
wire [`M_DEF_W(C_DATA_WIDTH)] exist_fifo_wr_data_o ;
reg exist_fifo_full_i = 0 ;
wire exist_fifo_rd_o ;
reg [`M_DEF_W(C_DATA_WIDTH)] exist_fifo_rd_data_i = 0 ;
reg exist_fifo_empty_i = 0 ;

wire null_fifo_rstn_o ;
wire null_fifo_wr_o ;
wire [`M_DEF_W(C_DATA_WIDTH)] null_fifo_wr_data_o ;
reg null_fifo_full_i = 0 ;
wire null_fifo_rd_o ;
reg [`M_DEF_W(C_DATA_WIDTH)] null_fifo_rd_data_i = 0 ;
reg null_fifo_empty_i = 0 ;

wire  full_o ;
wire  empty_o ;
wire  full_stick_o ;
wire  empty_stick_o ;
reg clr_full_stick_i = 0 ;
reg clr_empty_stick_i = 0 ;

`define CLK_HALF 5
`define DLY(cycle) # (`CLK_HALF*2*cycle) @ (posedge clk)

initial begin
    forever clk = #(`CLK_HALF) ~clk;
end

reg _cond_in_get = 0 ;
reg _cond_in_put = 0 ;
reg _cond_out_get = 0 ;
reg _cond_out_put = 0 ;

reg [`M_DEF_W(C_DATA_WIDTH)] in_info_data ;
reg [`M_DEF_W(C_DATA_WIDTH)] out_info_data ;

reg in_busy = 0 ;
reg out_busy = 0 ;

`define M_IN_GET             \
    `DLY(2)                  \
    _cond_in_get <= 1 ;      \
    @(negedge _cond_in_get); \
// 

`define M_OUT_GET             \
    `DLY(2)                   \
    _cond_out_get <= 1 ;      \
    @(negedge _cond_out_get); \
    //

`define M_IN_PUT             \
    `DLY(2) \
    _cond_in_put <= 1 ; \
    @(negedge _cond_in_put); \
    // 
    
`define M_OUT_PUT             \
    `DLY(2) \
    _cond_out_put <= 1 ; \
    @(negedge _cond_out_put); \
    //

integer r ;

initial begin
    `DLY(20)
    rstn <= ~rstn ;

    `DLY(16)
    for ( fvar0 = 0 ; fvar0 < C_BUFFER_DEPTH  ; fvar0=fvar0+1) begin 
        `DLY(2)
        init_info_data_i <= fvar0 ;
        init_info_data_vld_i <= 1 ;
        `DLY(1)
        init_info_data_vld_i <= 0 ;
    end

    // `define _TEST_1
    `define _TEST_2
    `ifdef _TEST_1
    `M_IN_GET
    `M_IN_PUT
    `M_OUT_GET
    `M_OUT_PUT
    
    `M_IN_GET
    `M_IN_PUT
    `M_OUT_GET
    `M_OUT_PUT
    
    `M_IN_GET
    `M_IN_PUT
    `M_OUT_GET
    `M_OUT_PUT
    
    for ( fvar0 = 0 ; fvar0 < C_BUFFER_DEPTH+1  ; fvar0=fvar0+1) begin 
        `M_IN_GET
        `M_IN_PUT
    end
    `endif

    `ifdef _TEST_2
    for ( fvar0 = 0 ; fvar0 < 10000  ; fvar0=fvar0+1) begin 
        `DLY(1)
        r = $random() ;
        if (r & 1) begin
            if (in_busy) begin
                `M_IN_PUT
            end
            else begin
                `M_IN_GET
            end
        end
        else begin
            if (out_busy) begin
                `M_OUT_PUT
            end
            else begin
                `M_OUT_GET
            end
        end
    end
    `endif
end

always @ ( posedge _cond_in_get) begin
    in_info_get_req_i <= 1 ;
    @ (posedge in_info_get_ack_o)
    `DLY(1)
    in_info_get_req_i <= 0 ;
    in_info_data <= in_info_get_data_o ;
    in_busy <= 1 ;
    
    _cond_in_get = 0 ;
end

always @ ( posedge _cond_out_get) begin
    out_info_get_req_i <= 1 ;
    @ (posedge out_info_get_ack_o)
    `DLY(1)
    out_info_get_req_i <= 0 ;
    out_info_data <= out_info_get_data_o ;
    out_busy <= 1 ;
    
    _cond_out_get = 0 ;
end

always @ ( posedge _cond_in_put) begin
    in_info_put_req_i <= 1 ;
    in_info_put_data_i <= in_info_data ;
    @ (posedge in_info_put_ack_o)
    `DLY(1)
    in_info_put_req_i <= 0 ;
    in_busy <= 0 ;
    
    _cond_in_put = 0 ;
end

always @ ( posedge _cond_out_put) begin
    out_info_put_req_i <= 1 ;
    out_info_put_data_i <= out_info_data ;
    @ (posedge out_info_put_ack_o)
    `DLY(1)
    out_info_put_req_i <= 0 ;
    out_busy <= 0 ;
    
    _cond_out_put = 0 ;
end



buffer_arbiter#(
    . C_BUFFER_DEPTH(C_BUFFER_DEPTH)
    ,. C_DATA_WIDTH(C_DATA_WIDTH)
    ,. C_FIFO_READ_LATENCY(C_FIFO_READ_LATENCY)
)
dut
(
    .*
);



fifo_generator_0#(

)
null_fifo
(
    .clk(clk)
    ,.srst(~null_fifo_rstn_o)
    ,.full(null_fifo_full_i)
    ,.din(null_fifo_wr_data_o)
    ,.wr_en(null_fifo_wr_o)
    ,.empty(null_fifo_empty_i)
    ,.dout(null_fifo_rd_data_i)
    ,.rd_en(null_fifo_rd_o)
) ;

fifo_generator_0#(

)
exist_fifo
(
    .clk(clk)
    ,.srst(~exist_fifo_rstn_o)
    ,.full(exist_fifo_full_i)
    ,.din(exist_fifo_wr_data_o)
    ,.wr_en(exist_fifo_wr_o)
    ,.empty(exist_fifo_empty_i)
    ,.dout(exist_fifo_rd_data_i)
    ,.rd_en(exist_fifo_rd_o)
) ;

endmodule