library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Cont20kHz10Up is
	generic(N: integer := 13);
	port(
		clk, reset: in std_logic;
		max_tick: out std_logic
	);
end Cont20kHz10Up;

architecture arch of Cont20kHz10Up is
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
	
	r_next <= zeros when r_reg = std_logic_vector(to_unsigned(5000,N)) else
				 std_logic_vector(sum);
				 
	--output logic
	max_tick <= '1' when (r_reg<=(std_logic_vector(to_unsigned(9,N)))) else '0';
		

end arch;

