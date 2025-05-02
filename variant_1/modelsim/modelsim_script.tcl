vlib work
vlog ../tb.sv +incdir+../../

vsim work.tb

add wave tb/clk
add wave tb/rst_n

add wave -hex tb/vv/s_*
add wave -hex tb/vv/s_data_i_FIFO
add wave -hex tb/vv/m_*

run -all
wave zoom full