		LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.filterpack.ALL; 
 
ENTITY TestLPFilter IS
END TestLPFilter;
 
ARCHITECTURE behavior OF TestLPFilter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LPFilter
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
			a: in x_t(N-1 downto 0);
			cte: in cte_t(N-1 downto 0);
			start: in std_logic;
			result: out std_logic_vector(Bits_x_t + Bits_cte_t - 2 downto 0);
         done_tick : OUT  std_logic
        );
    END COMPONENT;
    

   --LPF Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal a : x_t(N-1 downto 0) := (others =>(others => '0'));
   signal cte : cte_t(N-1 downto 0) := (others =>(others => '0'));
   signal start : std_logic := '0';

 	--LPF Outputs
   signal result : std_logic_vector(Bits_x_t + Bits_cte_t - 2 downto 0);
   signal done_tick : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;

	-- Constantes
	constant zerosresult : std_logic_vector(Bits_x_t + Bits_cte_t - 2 downto 0) := (others => '0');
	constant zerosxtarray : x_t(N-1 downto 0) := (others =>(others => '0'));
 
	-- Array auxiliar para ir guardando el resultado
	signal resultctearray : cte_t(N-1 downto 0) := (others => (others => '0'));
	signal resultxtarray: x_t(N-1 downto 0) := (others =>(others => '0'));
	
	type result_t is array(integer range <>) of std_logic_vector(Bits_x_t + Bits_cte_t - 2 downto 0);	
	signal resultarray: result_t(N-1 downto 0) := (others =>(others => '0'));
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LPFilter PORT MAP (
          clk => clk,
          reset => reset,
          a => a,
          cte => cte,
          start => start,
          result => result,
          done_tick => done_tick
        );
	
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '1';
		wait for 50 ns;
		reset <= '0';

      wait for clk_period*2;
		wait until falling_edge(clk);
		
		--primero me fijo que esté todo en cero
		assert done_tick = '0' report "el done_tick no está en cero al ppio" severity failure;
		assert result = zerosresult report "result no está en cero al ppio" severity failure;
		
		wait for clk_period;
		
		--tengo que hardcodear las constantes
		cte(0) <= "000000000011110110";
		cte(1) <= "000000000000011011";
		cte(2) <= "111111111000110001";
		cte(3) <= "111111110100000010";
		cte(4) <= "000000000001110001";
		cte(5) <= "000000011111111011";
		cte(6) <= "000000100110111100";
		cte(7) <= "111111101110101100";
		cte(8) <= "111110011000011101";
		cte(9) <= "111110011011010100";
		cte(10) <= "000001011010111100";
		cte(11) <= "000110100010110110";
		cte(12) <= "001010100110000101";
		cte(13) <= "001010100110000101";
		cte(14) <= "000110100010110110";
		cte(15) <= "000001011010111100";
		cte(16) <= "111110011011010100";
		cte(17) <= "111110011000011101";
		cte(18) <= "111111101110101100";
		cte(19) <= "000000100110111100";
		cte(20) <= "000000011111111011";
		cte(21) <= "000000000001110001";
		cte(22) <= "111111110100000010";
		cte(23) <= "111111111000110001";
		cte(24) <= "000000000000011011";
		cte(25) <= "000000000011110110";
	
		wait for clk_period;
		
		--deberia seguir todo en cero despues de hacer esto
		assert done_tick = '0' report "el done_tick no está en cero desp de las ctes" severity failure;
		assert result = zerosresult report "result no está en cero desp de las ctes" severity failure;
		
		--respuesta al impulso: tengo que llevar un 1 desde la posicion N-1 hasta la 0, y fijarme que lo que salga sean los coeficientes del filtro
		for i in 0 to N-1 loop
			a <= zerosxtarray;
			a(N-1-i) <= std_logic_vector(to_unsigned(1,Bits_x_t));
			start <= '1';
			wait until (rising_edge(done_tick));
			start <= '0';
			resultctearray(N-1-i) <= result(Bits_cte_t - 1 downto 0);
			resultxtarray(N-1-i) <= result(Bits_cte_t + Bits_x_t - 2 downto Bits_cte_t - 1);
		end loop;
		
		assert resultctearray = cte report "lo que sale del filtro no son los coef del filtro" severity failure;
		--todo bien
		assert false report "todo bien :D" severity failure;

   end process;

END;
