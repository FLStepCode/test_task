vlib work
vlog ../tb.sv +incdir+../../

vsim work.tb

add wave tb/clk
add wave tb/rst_n

add wave -hex tb/s_ar*
add wave -hex tb/s_r*
add wave -hex tb/m_ar*
add wave -hex tb/m_r*

add wave -hex tb/rb/s_arid_FIFO 
add wave -hex tb/rb/FIFO_head 
add wave -hex tb/rb/FIFO_tail 
add wave -hex tb/rb/m_rdata_buffer

run -all
wave zoom full