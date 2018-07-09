library ieee;
use ieee.std_logic_1164.all;

entity frac_divider_tb is
end frac_divider_tb;

architecture behavior of frac_divider_tb is
    -- output clock signal
    signal rst          : std_logic := '0';
    signal clk_i        : std_logic := '0';
    signal clk_o        : std_logic;

    -- clock configuration
    constant clk_period : time := 20 ns; -- f = 50 MHz
    signal finished     : std_logic := '0';

    -- clock cycle counts
    signal count_in     : integer := 0;
    signal count_out    : integer := 0;
begin
    -- count the number of clock cycles in clk_i
    process (clk_i)
    begin
        if (rst = '0') then
            if rising_edge(clk_i) then
                count_in <= count_in + 1;
            end if;
        end if;
    end process;

    -- count the number of clock cycles in clk_o
    process (clk_o)
    begin
        if (rst = '0') then
            if rising_edge(clk_o) then
                count_out <= count_out + 1;
            end if;
        end if;
    end process;

    -- unit under test
    u_frac_divider  : entity work.frac_divider 
        generic map (
            -- M=25 and N=3 to get clk_o = 6 MHz
            M       => 25,
            N       => 3,
            x       => 10
        )
        port map (
            rst     => rst,
            clk_i   => clk_i,
            clk_o   => clk_o
        );

    -- generate clock
    clk_i <= (not clk_i) after clk_period/2 when finished /= '1' else '0';

    -- testing
    process
    begin
        rst <= '1';
        wait for (10 * clk_period);
        rst <= '0';
        wait for (100000 * clk_period);
        finished <= '1';
        report "Output Frequency = " & real'image(real(real(count_out) * 50.0 /
                                        real(count_in))) & " MHz";
        wait;
    end process;
end architecture;
