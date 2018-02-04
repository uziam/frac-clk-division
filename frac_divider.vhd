library ieee;
use ieee.std_logic_1164.all;

entity frac_divider is
	generic(	N 		: integer;
				M 		: integer;
				x 		: integer := 1);
	port(		reset	: in std_logic;
				clk_in	: in std_logic;
				clk_out	: out std_logic);
end frac_divider;

architecture behavior of frac_divider is
	
	constant L: integer := integer(M/N) + 1;
	constant J: integer := L - 1;
	constant C: integer := x * N;
	constant B: integer := C*L - C*M/N;

	signal cycle_counter	: integer range 0 to C-1;
	signal modulus			: integer range 0 to L-1;
	signal mod_counter	: integer range 0 to L-1;
	signal mod_flag		: std_logic; -- flag raised when mod_counter reaches 0
	signal out_reg			: std_logic; -- output register

begin
	-- this is the cycle counter, counts from C-1 downto 0
	-- count decrements everytime mod_flag is raised
	-- goes back to C-1 after reaching 0
	-- synchoronus reset
	p_cycle_count: process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(reset = '1') then
				cycle_counter <= C-1;
			else
				if(mod_flag = '1') then
					if(cycle_counter = 0) then
						cycle_counter <= C-1; -- reset count
					else
						cycle_counter <= cycle_counter - 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- mux to select between J and L based on B (0..B will be J, then B..C = A will be L)
	modulus <= (J-1) when (cycle_counter < B) else (L-1);

	-- this is the dual-modulus counter
	-- counts from modulus downto 0
	-- updates counter to current modulus everytime count reaches 0
	-- synchronus reset
	p_mod_count: process(clk_in)
	begin
		if(rising_edge(clk_in)) then
			if(reset = '1') then
				mod_counter <= modulus;
			else
				if(mod_flag = '1') then
					mod_counter <= modulus;
				else
					mod_counter <= mod_counter - 1;
				end if;
			end if;
		end if;
	end process;

	-- raise the flag if mod_counter reaches 0
	-- this is the ouput but with twice the frequency required
	mod_flag <= '1' when(mod_counter = 0) else '0';

	-- this is a divide-by-two counter
	-- divides mod_flag frequency by 2
	p_div_by_2: process(clk_in)
	begin
		if(rising_edge(clk_in))
			if(reset = '1') then
				out_reg <= '0';
			elsif(mod_flag = '1') then
				out_reg <= not out_reg;
			end if;
		end if;
	end process;

	-- output clock
	clk_out <= out_reg;
end behavior; 