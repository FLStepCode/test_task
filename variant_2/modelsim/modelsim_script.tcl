vlib work
vlog ../tb.sv +incdir+../../

vsim work.tb

add wave tb/clk
add wave tb/rst_n

add wave -hex tb/rb/s_ar*
add wave -hex tb/rb/s_r*
add wave -hex tb/rb/m_ar*
add wave -hex tb/rb/m_r*

run -all
wave zoom full