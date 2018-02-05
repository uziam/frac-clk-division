library ieee;
use ieee.std_logic_1164.all;

entity frac_divider_tb is
end frac_divider_tb;

architecture behavior of frac_divider_tb is

	-- output clock signal
	signal clk_out 	: std_logic;

	-- reset signal
	signal reset	: std_logic := '0';

	-- input clock signal
	signal clk_in 	: std_logic := '0';

	-- clock confg
	constant clk_period : time := 20 ns; -- f = 50 MHz
	signal finished 	: std_logic := '0';

	-- clock cycle counts
	signal count_in		: integer := 0; -- for clk_in
	signal count_out	: integer := 0; -- for clk_out

	-- fractional divider component
	component frac_divider is
		generic(	M 		: integer;
					N 		: integer;
					x 		: integer);
		port(		reset	: in std_logic;
					clk_in	: in std_logic;
					clk_out	: out std_logic);
	end component;

begin
	-- count the number of clock cycles in clk_in
	process(clk_in)
	begin
		if(reset = '0') then
			if(rising_edge(clk_in)) then
				count_in <= count_in + 1;
			end if;
		end if;
	end process;

	-- count the number of clock cycles in clk_out
	process(clk_out)
	begin
		if(reset = '0') then
			if(rising_edge(clk_out)) then
				count_out <= count_out + 1;
			end if;
		end if;
	end process;

	-- unit under test
	fd 	: frac_divider 
			-- M=25 and N=3 to get clk_out = 6 MHz
			generic map(M 		=> 25,
						N 		=> 3,
						x		=> 10)
			port map(	reset 	=> reset,
						clk_in 	=> clk_in,
						clk_out	=> clk_out);

	-- generate clock
	clk_in <= (not clk_in) after clk_period/2 when finished /= '1' else '0';

	-- testing
	process
	begin
		reset <= '1';
		wait for (10 * clk_period);
		reset <= '0';
		wait for (100000 * clk_period);
		finished <= '1';
		report "Output Frequency = " & real'image(real(real(count_out)*50.0/real(count_in))) & " MHz";
		wait;
	end process;

end architecture;