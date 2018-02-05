compile:
	ghdl -a frac_divider.vhd
	ghdl -a frac_divider_tb.vhd
	ghdl -e frac_divider_tb
	ghdl -r frac_divider_tb --vcd=tb.vcd

view:
	gtkwave tb.vcd