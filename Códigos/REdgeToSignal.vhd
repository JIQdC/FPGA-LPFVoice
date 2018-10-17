library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REdgeToSignal is
	port(
		clk, reset: in std_logic;
		redge: in std_logic;
		output: out std_logic
		);
end REdgeToSignal;

architecture arch of REdgeToSignal is
	type state_type is (idle, risingedge);
	signal state_reg, state_next: state_type;

begin

	process(clk, reset)
	begin
		if(reset = '1') then
			state_reg <= idle;
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
		end if;
	end process;
	
	--next state logic
	process(state_reg, redge)
	begin
		--default
		state_next <= state_reg;
		
		case state_reg is
		
			when idle =>
				if (redge = '1') then
					state_next <= risingedge;
				end if;
			when risingedge =>
				if (redge  = '0') then
					state_next <= idle;
				end if;
				
		end case;
	end process;
	
	--output logic
	process(state_reg,redge)
	begin
		--default
		output <= '0';
		case state_reg is
			when idle =>
				if (redge = '1') then
					output <= '1';
				end if;
			
			when risingedge =>

		end case;
	end process;
					


end arch;

