--este array shifter inserta un elemento en la posicion N del
--array que recibe como input, y tira el elemento 0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filterpack.ALL;

entity array_shifter is
	port(
		clk, reset: in std_logic;
		insert: in std_logic_vector(Bits_x_t-1 downto 0);
		start: in std_logic;
		done_tick: out std_logic;
		a_shift: out x_t(N-1 downto 0)
		);
end array_shifter;

architecture arch of array_shifter is
	type state_type is (idle, op, done);
	signal state_reg, state_next: state_type;
	signal areg, anext: x_t(N-1 downto 0);
	
begin	
	
	--state register
	process(clk, reset)
	begin
		if(reset = '1') then
			state_reg <= idle;
			areg <= (others =>(others => '0'));
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
			areg <= anext;
		end if;
	end process;
	
	--next state logic
	process(state_reg,areg,insert,start)
	begin
		state_next <= state_reg;
		anext <= areg;
		
		case state_reg is
			when idle =>
				if(start = '1') then
					state_next <= op;
				end if;
			
			when op =>
				anext <= insert & areg(N-1 downto 1);
				state_next <= done;
			
			when done =>
				state_next <= idle;
	
		end case;
	end process;
	
	--output logic
	process(state_reg,areg)
	begin
		a_shift <= areg;
		done_tick <= '0';
		
		case state_reg is
			when idle =>
			
			when op =>
			
			when done =>
				done_tick <= '1';
				
		end case;
	end process;
	
end arch;