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

module buffer_arbiter#(
    /* data width */
    parameter C_DATA_WIDTH = 32

    /* fifo read latency */
    ,parameter C_FIFO_READ_LATENCY = 1
)
(
    input wire clk
    ,input wire rstn

    ,input wire [`M_DEF_W(C_DATA_WIDTH)] init_info_data_i
    ,input wire init_info_data_vld_i
    ,output wire initial_done_o

    ,input wire in_info_get_req_i
    ,output wire in_info_get_ack_o
    ,output wire [`M_DEF_W(C_DATA_WIDTH)] in_info_get_data_o
    ,output wire in_info_get_overflow_o

    ,input wire in_info_put_req_i
    ,output wire in_info_put_ack_o
    ,input wire [`M_DEF_W(C_DATA_WIDTH)] in_info_put_data_i

    ,input wire out_info_get_req_i
    ,output wire out_info_get_ack_o
    ,output wire [`M_DEF_W(C_DATA_WIDTH)] out_info_get_data_o
    ,output wire out_info_get_underflow_o

    ,input wire out_info_put_req_i
    ,output wire out_info_put_ack_o
    ,input wire [`M_DEF_W(C_DATA_WIDTH)] out_info_put_data_i

    ,output wire exist_fifo_rstn_o
    ,output wire exist_fifo_wr_o
    ,output wire [`M_DEF_W(C_DATA_WIDTH)] exist_fifo_wr_data_o
    ,input wire exist_fifo_full_i
    ,output wire exist_fifo_rd_o
    ,input wire [`M_DEF_W(C_DATA_WIDTH)] exist_fifo_rd_data_i
    ,input wire exist_fifo_empty_i
    
    ,output wire null_fifo_rstn_o
    ,output wire null_fifo_wr_o
    ,output wire [`M_DEF_W(C_DATA_WIDTH)] null_fifo_wr_data_o
    ,input wire null_fifo_full_i
    ,output wire null_fifo_rd_o
    ,input wire [`M_DEF_W(C_DATA_WIDTH)] null_fifo_rd_data_i
    ,input wire null_fifo_empty_i

    ,output wire full_o
    ,output wire empty_o
    ,output wire full_stick_o
    ,output wire empty_stick_o
    ,input wire clr_full_stick_i
    ,input wire clr_empty_stick_i
);


`SEG_FUNC_CLOG2

/*  */
genvar gvar0,gvar1 ;
integer fvar0 ;
integer fvar1 ;
integer fvar2 ;
integer fvar_col ;
integer fvar_row ;

reg exist_fifo_rstn_ff,_exist_fifo_rstn_ff ;
reg exist_fifo_wr_ff,_exist_fifo_wr_ff ;
reg [`M_DEF_W(C_DATA_WIDTH)] exist_fifo_wr_data_ff,_exist_fifo_wr_data_ff ;
reg exist_fifo_rd_ff,_exist_fifo_rd_ff ;
reg [`M_DEF_W(C_DATA_WIDTH)] exist_fifo_rd_data_ff,_exist_fifo_rd_data_ff ;
reg null_fifo_rstn_ff,_null_fifo_rstn_ff ;
reg null_fifo_wr_ff,_null_fifo_wr_ff ;
reg [`M_DEF_W(C_DATA_WIDTH)] null_fifo_wr_data_ff,_null_fifo_wr_data_ff ;
reg null_fifo_rd_ff,_null_fifo_rd_ff ;

reg in_info_get_ack_ff,_in_info_get_ack_ff ;
reg [`M_DEF_W(C_DATA_WIDTH)] in_info_get_data_ff,_in_info_get_data_ff ;
reg in_info_get_overflow_ff,_in_info_get_overflow_ff ;
reg in_info_put_ack_ff,_in_info_put_ack_ff ;
reg out_info_get_ack_ff,_out_info_get_ack_ff ;
reg [`M_DEF_W(C_DATA_WIDTH)] out_info_get_data_ff,_out_info_get_data_ff ;
reg out_info_get_underflow_ff,_out_info_get_underflow_ff ;
reg out_info_put_ack_ff,_out_info_put_ack_ff ;

`M_REG_ASSIGN(in_info_get_ack_ff)
`M_REG_ASSIGN(in_info_get_data_ff)
`M_REG_ASSIGN(in_info_get_overflow_ff)
`M_REG_ASSIGN(in_info_put_ack_ff)
`M_REG_ASSIGN(out_info_get_ack_ff)
`M_REG_ASSIGN(out_info_get_data_ff)
`M_REG_ASSIGN(out_info_get_underflow_ff)
`M_REG_ASSIGN(out_info_put_ack_ff)
`M_REG_ASSIGN(exist_fifo_rstn_ff)
`M_REG_ASSIGN(exist_fifo_wr_ff)
`M_REG_ASSIGN(exist_fifo_wr_data_ff)
`M_REG_ASSIGN(exist_fifo_rd_ff)
`M_REG_ASSIGN(exist_fifo_rd_data_ff)
`M_REG_ASSIGN(null_fifo_rstn_ff)
`M_REG_ASSIGN(null_fifo_wr_ff)
`M_REG_ASSIGN(null_fifo_wr_data_ff)
`M_REG_ASSIGN(null_fifo_rd_ff)



localparam C_FSM_STS__IDLE = 0 ;
localparam C_FSM_STS__GET = 1 ;
localparam C_FSM_STS__PUT = 2 ;
localparam C_FSM_STS__INIT = 3 ;
localparam C_FSM_BIT = 2 ;

reg [`M_DEF_W(C_FSM_BIT)] fsm,_fsm ;
`M_REG_ASSIGN(fsm)

reg check_in,_check_in ;
`M_REG_ASSIGN(check_in)

reg mission_is_inPort,_mission_is_inPort ;
`M_REG_ASSIGN(mission_is_inPort)

reg buffer_sel_exist,_buffer_sel_exist ;
`M_REG_ASSIGN(buffer_sel_exist)

reg empty_ff,_empty_ff ;
reg full_ff,_full_ff ;
`M_REG_ASSIGN(empty_ff)
`M_REG_ASSIGN(full_ff)
reg full_stick_ff,_full_stick_ff ;
reg empty_stick_ff,_empty_stick_ff ;
`M_REG_ASSIGN(full_stick_ff)
`M_REG_ASSIGN(empty_stick_ff)

reg [`M_DEF_W(`CBIT(C_FIFO_READ_LATENCY))] fifo_latency_cnt,_fifo_latency_cnt ;
`M_REG_ASSIGN(fifo_latency_cnt)

reg initial_done_ff,_initial_done_ff ;
`M_REG_ASSIGN(initial_done_ff)

reg init_wait_fifo,_init_wait_fifo ;
`M_REG_ASSIGN(init_wait_fifo)

reg init_info_data_vld_ff ;
wire _init_info_data_vld_pose = (!init_info_data_vld_ff) && init_info_data_vld_i ;
reg clr_full_stick_ff ;
reg clr_empty_stick_ff ;
wire _clr_full_stick_pose = (!clr_full_stick_ff) && clr_full_stick_i ;
wire _clr_empty_stick_pose = (!clr_empty_stick_ff) && clr_empty_stick_i ;
always @ ( posedge clk) begin
    init_info_data_vld_ff <= init_info_data_vld_i ;
    clr_full_stick_ff <= clr_full_stick_i ;
    clr_empty_stick_ff <= clr_empty_stick_i ;
end


/* 
C_FSM_STS__IDLE: This is the default state where the FSM waits for incoming or outgoing data requests. It handles requests for getting or putting data into the FIFO.

C_FSM_STS__GET: In this state, the FSM retrieves data from the FIFO. It waits for a specified latency period before transitioning back to the idle state.

C_FSM_STS__PUT: Here, the FSM puts data into the FIFO. Similar to the GET state, it waits for a latency period before returning to the idle state.

C_FSM_STS__INIT: This state is responsible for initializing the FIFO. It waits for a certain condition (init_wait_fifo) before writing data into the FIFO and then transitions back to idle when initialization is complete.
 */
always @ (*) begin
    `M_COMB_ASSIGN(fsm)
    `M_COMB_ASSIGN(check_in)
    `M_COMB_ASSIGN(exist_fifo_rstn_ff)
    `M_COMB_ASSIGN(exist_fifo_wr_ff)
    `M_COMB_ASSIGN(exist_fifo_wr_data_ff)
    `M_COMB_ASSIGN(exist_fifo_rd_ff)
    `M_COMB_ASSIGN(exist_fifo_rd_data_ff)
    `M_COMB_ASSIGN(null_fifo_rstn_ff)
    `M_COMB_ASSIGN(null_fifo_wr_ff)
    `M_COMB_ASSIGN(null_fifo_wr_data_ff)
    `M_COMB_ASSIGN(null_fifo_rd_ff)
    `M_COMB_ASSIGN(mission_is_inPort)
    `M_COMB_ASSIGN(buffer_sel_exist)
    `M_COMB_ASSIGN(in_info_get_ack_ff)
    `M_COMB_ASSIGN(in_info_get_data_ff)
    `M_COMB_ASSIGN(in_info_get_overflow_ff)
    `M_COMB_ASSIGN(in_info_put_ack_ff)
    `M_COMB_ASSIGN(out_info_get_ack_ff)
    `M_COMB_ASSIGN(out_info_get_data_ff)
    `M_COMB_ASSIGN(out_info_get_underflow_ff)
    `M_COMB_ASSIGN(out_info_put_ack_ff)
    `M_COMB_ASSIGN(empty_ff)
    `M_COMB_ASSIGN(full_ff)
    `M_COMB_ASSIGN(fifo_latency_cnt)
    `M_COMB_ASSIGN(initial_done_ff)
    `M_COMB_ASSIGN(init_wait_fifo)
    `M_COMB_ASSIGN(full_stick_ff)
    `M_COMB_ASSIGN(empty_stick_ff)

    _null_fifo_rstn_ff = 1 ;
    _exist_fifo_rstn_ff = 1 ;
    _exist_fifo_rd_ff = 0 ;
    _exist_fifo_wr_ff = 0 ;
    _null_fifo_rd_ff = 0 ;
    _null_fifo_wr_ff = 0 ;

    case (fsm)
    default: begin //C_FSM_STS__IDLE
        _check_in = ~check_in ;
        _in_info_get_ack_ff = 0 ;
        _in_info_put_ack_ff = 0 ;
        _out_info_get_ack_ff = 0 ;
        _out_info_put_ack_ff = 0 ;
        _fifo_latency_cnt = 0 ;

        if (check_in) begin
            _mission_is_inPort = 1 ;
            if (in_info_get_req_i) begin
                _fsm = C_FSM_STS__GET ;
                if (full_ff) begin
                    _exist_fifo_rd_ff = 1 ;
                    _buffer_sel_exist = 1 ;
                    _in_info_get_overflow_ff = 1 ;
                end
                else begin
                    _null_fifo_rd_ff = 1 ;
                    _buffer_sel_exist = 0 ;
                    _in_info_get_overflow_ff = 0 ;
                end
            end
            else if (in_info_put_req_i) begin
                _fsm = C_FSM_STS__PUT ;
                _exist_fifo_wr_ff = 1 ;
                _exist_fifo_wr_data_ff = in_info_put_data_i ;
            end
        end
        else begin
            _mission_is_inPort = 0 ;
            if (out_info_get_req_i) begin
                _fsm = C_FSM_STS__GET ;
                if (empty_ff) begin
                    _null_fifo_rd_ff = 1 ;
                    _buffer_sel_exist = 0 ;
                    _out_info_get_underflow_ff = 1 ;
                end
                else begin
                    _exist_fifo_rd_ff = 1 ;
                    _buffer_sel_exist = 1 ;
                    _out_info_get_underflow_ff = 0 ;
                end
            end
            else if (out_info_put_req_i) begin
                _fsm = C_FSM_STS__PUT ;
                _null_fifo_wr_ff = 1 ;
                _null_fifo_wr_data_ff = out_info_put_data_i ;
            end
        end
    end

    C_FSM_STS__GET: begin
        _null_fifo_rd_ff = 0 ;
        _exist_fifo_rd_ff = 0 ;
        if (fifo_latency_cnt >= C_FIFO_READ_LATENCY) begin
            _fsm = C_FSM_STS__IDLE ;
            if (mission_is_inPort) begin
                _in_info_get_ack_ff = 1 ;
                if (buffer_sel_exist) begin
                    _in_info_get_data_ff = exist_fifo_rd_data_i ;
                end
                else begin
                    _in_info_get_data_ff = null_fifo_rd_data_i ;
                end
            end
            else begin
                _out_info_get_ack_ff = 1 ;
                if (buffer_sel_exist) begin
                    _out_info_get_data_ff = exist_fifo_rd_data_i ;
                end
                else begin
                    _out_info_get_data_ff = null_fifo_rd_data_i ;
                end
            end
        end
        else begin
            _fifo_latency_cnt = fifo_latency_cnt + 1 ;
        end
    end

    C_FSM_STS__PUT: begin
        _exist_fifo_wr_ff = 0 ;
        _null_fifo_wr_ff = 0 ;
        if (fifo_latency_cnt >= C_FIFO_READ_LATENCY) begin
            _fsm = C_FSM_STS__IDLE ;
            if (mission_is_inPort) begin
                _full_ff = null_fifo_empty_i ;
                _empty_ff = 0 ;
                _in_info_put_ack_ff = 1 ;
            end
            else begin
                _full_ff = 0 ;
                _empty_ff = exist_fifo_empty_i ;
                _out_info_put_ack_ff = 1 ;
            end
        end
        else begin
            _fifo_latency_cnt = fifo_latency_cnt + 1 ;
        end
    end

    C_FSM_STS__INIT: begin
        if (!init_wait_fifo) begin
            _null_fifo_wr_ff = _init_info_data_vld_pose ;
            if (_init_info_data_vld_pose) begin
                _null_fifo_wr_data_ff = init_info_data_i ;
                _init_wait_fifo = 1 ;
            end
        end
        else begin
            _null_fifo_wr_ff = 0 ;
            if (fifo_latency_cnt >= C_FIFO_READ_LATENCY) begin
                if (null_fifo_full_i) begin
                    _fsm = C_FSM_STS__IDLE ;
                    _empty_ff = 1 ;
                    _initial_done_ff = 1 ;
                end
                _init_wait_fifo = 0 ;
                _fifo_latency_cnt = 0 ;
            end
            else begin
                _fifo_latency_cnt = fifo_latency_cnt + 1 ;
            end
        end
    end

    endcase


    if (~full_stick_ff) begin
        _full_stick_ff = _full_ff ;
    end
    else begin
        if ((~rstn) || (_clr_full_stick_pose)) begin
            _full_stick_ff = 0 ;
        end
    end

    if (~empty_stick_ff) begin
        _empty_stick_ff = _empty_ff ;
    end
    else begin
        if ((~rstn) || (_clr_empty_stick_pose)) begin
            _empty_stick_ff = 0 ;
        end
    end


    if (~rstn) begin
        _fsm = C_FSM_STS__INIT ;
        _empty_ff = 0 ;
        _full_ff = 0 ;
        _initial_done_ff = 0 ;
        _init_wait_fifo = 0 ;
        _null_fifo_rstn_ff = 0 ;
        _exist_fifo_rstn_ff = 0 ;
        _check_in = 0 ;
        _null_fifo_wr_ff = 0 ;
        _null_fifo_rd_ff = 0 ;
        _exist_fifo_wr_ff = 0 ;
        _exist_fifo_rd_ff = 0 ;
        _in_info_get_ack_ff = 0 ;
        _in_info_put_ack_ff = 0 ;
        _out_info_get_ack_ff = 0 ;
        _out_info_put_ack_ff = 0 ;
        _fifo_latency_cnt = 0 ;
        _in_info_get_overflow_ff = 0 ;
        _out_info_get_underflow_ff = 0 ;
    end

    if (
        ~rstn 
        || (
            (_fsm == C_FSM_STS__IDLE)
            & (fsm != C_FSM_STS__IDLE)
        )
    ) begin
        // _null_fifo_wr_ff = 0 ;
        // _null_fifo_rd_ff = 0 ;
        // _exist_fifo_wr_ff = 0 ;
        // _exist_fifo_rd_ff = 0 ;
        // _in_info_get_ack_ff = 0 ;
        // _in_info_put_ack_ff = 0 ;
        // _out_info_get_ack_ff = 0 ;
        // _out_info_put_ack_ff = 0 ;
        // _fifo_latency_cnt = 0 ;
    end
end

assign exist_fifo_rstn_o = exist_fifo_rstn_ff ;
assign exist_fifo_wr_o = exist_fifo_wr_ff ;
assign exist_fifo_wr_data_o = exist_fifo_wr_data_ff ;
assign exist_fifo_rd_o = exist_fifo_rd_ff ;
assign exist_fifo_rd_data_o = exist_fifo_rd_data_ff ;
assign null_fifo_rstn_o = null_fifo_rstn_ff ;
assign null_fifo_wr_o = null_fifo_wr_ff ;
assign null_fifo_wr_data_o = null_fifo_wr_data_ff ;
assign null_fifo_rd_o = null_fifo_rd_ff ;
assign in_info_get_ack_o = in_info_get_ack_ff ;
assign in_info_get_data_o = in_info_get_data_ff ;
assign in_info_get_overflow_o = in_info_get_overflow_ff ;
assign in_info_put_ack_o = in_info_put_ack_ff ;
assign out_info_get_ack_o = out_info_get_ack_ff ;
assign out_info_get_data_o = out_info_get_data_ff ;
assign out_info_get_underflow_o = out_info_get_underflow_ff ;
assign out_info_put_ack_o = out_info_put_ack_ff ;
assign initial_done_o = initial_done_ff ;
assign full_o = full_ff ;
assign empty_o = empty_ff ;
assign full_stick_o = full_stick_ff ;
assign empty_stick_o = empty_stick_ff ;
endmodule