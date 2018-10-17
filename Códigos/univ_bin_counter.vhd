library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity univ_bin_counter is
	generic(N: integer := 8);
	port(
		up: in std_logic;
		clk, reset: in std_logic;
		q: out std_logic_vector(N-1 downto 0)
	);
end univ_bin_counter;

architecture arch of univ_bin_counter is
	signal sum: unsigned(N-1 downto 0);
	signal r_reg, r_next: std_logic_vector(N-1 downto 0);
	constant ones: std_logic_vector(N-1 downto 0) := (others => '1');
	constant zeros: std_logic_vector(N-1 downto 0) := (others => '0');
	

	
begin
	--register
	process(clk,reset)
	begin
		if (reset = '1') then
			r_reg <= (others => '0');
		elsif (rising_edge(clk)) then
			r_reg <= r_next;
		end if;
	end process;
	
	--next state logic
	sum <= 1 + unsigned(r_reg);
	
	r_next <= r_reg when up = '0' else
				 zeros when r_reg = ones else
				 std_logic_vector(sum);
				 
	--output logic
	q <= r_reg;
		

end arch;

