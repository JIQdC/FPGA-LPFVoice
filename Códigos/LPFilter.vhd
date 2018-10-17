			library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filterpack.ALL;

entity LPFilter is
	port(
		clk, reset: std_logic;
		--entradas del filtro: a son datos, cte son las ctes del filtro
		a: in x_t(N-1 downto 0);
		cte: in cte_t(N-1 downto 0);
		start: in std_logic;
		--salidas
		result: out std_logic_vector(Bits_x_t + Bits_cte_t - 2 downto 0);
		done_tick: out std_logic
		);
end LPFilter;

architecture arch of LPFilter is
	--estados
	type state_type is (idle, oper, done);
	signal state_reg,state_next: state_type;
	--registro para sumar
	signal sumreg, sumnext: signed(2*(Bits_x_t + Bits_cte_t) - 1 downto 0);
	--registro para contar hasta N
	signal nreg, nnext: unsigned(N_idx-1 downto 0);
	--senales auxiliares para preparar la mult
	signal auxdata, auxcte: std_logic_vector(Bits_x_t + Bits_cte_t -1 downto 0);
	--constantes ceros y unos
	constant zerosxt: std_logic_vector(Bits_x_t-1 downto 0) := (others => '0');
	constant onesxt: std_logic_vector(Bits_x_t-1 downto 0) := (others => '1');
	constant zerosctet: std_logic_vector(Bits_cte_t-2 downto 0) := (others => '0');
	
	
begin
	--state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= idle;
			sumreg <= (others => '0');
			nreg <= (others => '0');
		elsif (rising_edge(clk)) then
			state_reg <= state_next;
			sumreg <= sumnext;
			nreg <= nnext;
		end if;
	end process;
	
	--next state logic
	process(state_reg,nreg,sumreg,a,cte,start,auxdata,auxcte)
	begin
		--default
		state_next <= state_reg;
		nnext <= nreg;
		sumnext <= sumreg;
		--aux signals
		auxdata <= (others => '0');
		auxcte  <= (others => '0');
		
		case state_reg is
			when idle =>
				nnext <= (others => '0');
				sumnext <= (others => '0');
				if (start = '1') then
					state_next <= oper;
				end if;
			
			when oper =>
				auxdata <= '0' & a(N -1 - to_integer(nreg)) & zerosctet;
				if (nreg > to_unsigned(N - 1,N_idx)) then
					state_next <= done;
				elsif (cte(to_integer(nreg))(Bits_cte_t-1) = '1') then
					auxcte <= onesxt & cte(to_integer(nreg));		
				else
					auxcte <= zerosxt & cte(to_integer(nreg));	
				end if;
				sumnext <= sumreg + (signed(auxcte)*signed(auxdata));
				nnext <= nreg + 1;
			
			when done =>
				state_next <= idle;
			
		end case;
	end process;
	
	--output
	process(state_reg,sumreg)
	begin
		--default
		done_tick <= '0';
		result <= (others => '0');
		
		case state_reg is
			when idle =>
			
			when oper =>
			
			when done =>
				done_tick <= '1';
				result <= std_logic_vector(sumreg((Bits_x_t + 2*Bits_cte_t - 3) downto Bits_cte_t - 1 ));
				
		end case;
	end process;
end arch;