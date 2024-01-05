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



module buffer_arbiter_out_bridge#(
    parameter C_DATA_WIDTH = 32
    // Width of data bus in bits
    ,parameter DATA_WIDTH = 32
    // Width of address bus in bits
    ,parameter ADDR_WIDTH = 32
    // Width of wstrb (width of data bus in words)
    ,parameter STRB_WIDTH = (DATA_WIDTH/8)
)
(
    input wire clk
    ,input wire rstn
    
    ,output wire out_info_get_req_o
    ,input wire out_info_get_ack_i
    ,input wire [`M_DEF_W(C_DATA_WIDTH)] out_info_get_data_i
    ,input wire out_info_get_underflow_i

    ,output wire out_info_put_req_o
    ,input wire out_info_put_ack_i
    ,output wire [`M_DEF_W(C_DATA_WIDTH)] out_info_put_data_o
    
    ,input wire empty_i
    ,input wire empty_stick_i
    ,output wire clr_empty_stick_o


    ,input wire [ADDR_WIDTH-1:0]  reg_wr_addr_i
    ,input wire [DATA_WIDTH-1:0]  reg_wr_data_i
    ,input wire [STRB_WIDTH-1:0]  reg_wr_strb_i
    ,input wire                   reg_wr_en_i
    ,output  wire                   reg_wr_wait_o
    ,output  wire                   reg_wr_ack_o
    ,input wire [ADDR_WIDTH-1:0]  reg_rd_addr_i
    ,input wire                   reg_rd_en_i
    ,output  wire [DATA_WIDTH-1:0]  reg_rd_data_o
    ,output  wire                   reg_rd_wait_o
    ,output  wire                   reg_rd_ack_o
);


`SEG_FUNC_CLOG2

/*  */
genvar gvar0,gvar1 ;
integer fvar0 ;
integer fvar1 ;
integer fvar2 ;
integer fvar_col ;
integer fvar_row ;


reg out_info_get_req_ff,_out_info_get_req_ff ;
reg out_info_put_req_ff,_out_info_put_req_ff ;
reg [`M_DEF_W(C_DATA_WIDTH)] out_info_put_data_ff,_out_info_put_data_ff ;
reg                   reg_wr_wait_ff,_reg_wr_wait_ff ;
reg                   reg_wr_ack_ff,_reg_wr_ack_ff ;
reg [DATA_WIDTH-1:0]  reg_rd_data_ff,_reg_rd_data_ff ;
reg                   reg_rd_wait_ff,_reg_rd_wait_ff ;
reg                   reg_rd_ack_ff,_reg_rd_ack_ff ;
`M_REG_ASSIGN(out_info_get_req_ff)
`M_REG_ASSIGN(out_info_put_req_ff)
`M_REG_ASSIGN(out_info_put_data_ff)
`M_REG_ASSIGN(reg_wr_wait_ff)
`M_REG_ASSIGN(reg_wr_ack_ff)
`M_REG_ASSIGN(reg_rd_data_ff)
`M_REG_ASSIGN(reg_rd_wait_ff)
`M_REG_ASSIGN(reg_rd_ack_ff)

reg clr_empty_stick_ff,_clr_empty_stick_ff ;
`M_REG_ASSIGN(clr_empty_stick_ff)

reg sts_wr_busy,_sts_wr_busy ;
`M_REG_ASSIGN(sts_wr_busy)

wire _cond_wr_start = (~sts_wr_busy) && (reg_wr_en_i) ;

localparam C_TAG_BIT = 8 ;
reg [`M_DEF_W(C_TAG_BIT)] tag_out_get_req,_tag_out_get_req ;
`M_REG_ASSIGN(tag_out_get_req)

reg [`M_DEF_W(C_DATA_WIDTH)] tmp_info,_tmp_info ;
`M_REG_ASSIGN(tmp_info)

reg reg_wr_en_ff ;
reg reg_rd_en_ff ;

always @ ( posedge clk) begin
    reg_wr_en_ff <= reg_wr_en_i ;
    reg_rd_en_ff <= reg_rd_en_i ;
end

/* 
Add      Reg
'h0     R: empty_stick , WC
'h4     WS: get req
'h8     WS: put req
'hC     RW: info
 */
always @ (*) begin
    `M_COMB_ASSIGN(out_info_get_req_ff)
    `M_COMB_ASSIGN(out_info_put_req_ff)
    `M_COMB_ASSIGN(out_info_put_data_ff)
    `M_COMB_ASSIGN(reg_wr_wait_ff)
    `M_COMB_ASSIGN(reg_wr_ack_ff)
    `M_COMB_ASSIGN(reg_rd_data_ff)
    `M_COMB_ASSIGN(reg_rd_wait_ff)
    `M_COMB_ASSIGN(reg_rd_ack_ff)
    `M_COMB_ASSIGN(clr_empty_stick_ff)
    `M_COMB_ASSIGN(sts_wr_busy)
    `M_COMB_ASSIGN(tag_out_get_req)
    `M_COMB_ASSIGN(tmp_info)

    _reg_wr_ack_ff = 0 ;
    if (~reg_wr_wait_ff) begin
        if (reg_wr_en_i && ~reg_wr_en_ff) begin
            _reg_wr_wait_ff = 0 ;
            case (reg_wr_addr_i)
            default: begin
                _reg_wr_ack_ff = 1 ;
            end
            0: begin // 0
                _clr_empty_stick_ff = 1 ;
                _reg_wr_ack_ff = 1 ;
            end
            'h4: begin
                _out_info_get_req_ff = 1 ;
                _reg_wr_wait_ff = 1 ;
            end
            'h8: begin
                _out_info_put_req_ff = 1 ;
                _reg_wr_wait_ff = 1 ;
            end
            'hC: begin
                _tmp_info = reg_wr_data_i ;
                _reg_wr_ack_ff = 1 ;
            end
            endcase
        end
    end
    else begin
        case (reg_wr_addr_i)
        default: begin
            _reg_wr_wait_ff = 0 ;
            _reg_wr_ack_ff = 1 ;
        end
        'h4: begin
            if (out_info_get_ack_i) begin
                _out_info_get_req_ff = 0 ;
                _reg_wr_wait_ff = 0 ;
                _reg_wr_ack_ff = 1 ;
                _tmp_info = out_info_get_data_i ;
            end
        end
        'h8: begin
            if (out_info_put_ack_i) begin
                _out_info_put_req_ff = 0 ;
                _reg_wr_wait_ff = 0 ;
                _reg_wr_ack_ff = 1 ;
            end
        end
        endcase
    end

    _reg_rd_ack_ff = 0 ;
    if (~reg_rd_wait_ff) begin
        _reg_rd_wait_ff = 0 ;
        if (reg_rd_en_i && ~reg_rd_en_ff) begin
            case (reg_rd_addr_i)
            default: begin
                _reg_rd_data_ff = 0 ;
                _reg_rd_ack_ff = 1 ;
            end
            0: begin // 0
                _reg_rd_data_ff = {empty_stick_i,empty_i} ;
                _reg_rd_ack_ff = 1 ;
            end
            'hc: begin
                _reg_rd_data_ff = tmp_info ;
                _reg_rd_ack_ff = 1 ;
            end
            endcase
        end
    end
    else begin
        _reg_rd_wait_ff = 0 ;
    end


    if (~rstn) begin
        _out_info_get_req_ff = 0 ;
        _out_info_put_req_ff = 0 ;
        _reg_wr_wait_ff = 0 ;
        _reg_wr_ack_ff = 0 ;
        _reg_rd_wait_ff = 0 ;
        _reg_rd_ack_ff = 0 ;
        _clr_empty_stick_ff = 0 ;
        _sts_wr_busy = 0 ;
        _tag_out_get_req = 0 ;
    end
end
assign out_info_get_req_o = out_info_get_req_ff ;
assign out_info_put_req_o = out_info_put_req_ff ;
assign out_info_put_data_o = tmp_info ;
assign clr_empty_stick_o = clr_empty_stick_ff ;
assign reg_wr_wait_o = reg_wr_wait_ff ;
assign reg_wr_ack_o = reg_wr_ack_ff ;
assign reg_rd_data_o = reg_rd_data_ff ;
assign reg_rd_wait_o = reg_rd_wait_ff ;
assign reg_rd_ack_o = reg_rd_ack_ff ;
endmodule