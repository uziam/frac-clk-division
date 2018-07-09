.PHONY: comple run view clean
all: compile run view

compile:
	ghdl -a frac_divider.vhd
	ghdl -a frac_divider_tb.vhd
	ghdl -e frac_divider_tb

run:
	ghdl -r frac_divider_tb --vcd=tb.vcd

view:
	gtkwave tb.vcd

clean:
	rm -f frac_divider_tb
	rm -f frac_divider.o frac_divider_tb.o e~frac_divider_tb.o
	rm -f *.cf
	rm -f tb.vcd
