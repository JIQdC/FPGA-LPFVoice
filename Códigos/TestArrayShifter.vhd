LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.filterpack.ALL;
 
ENTITY TestArrayShifter IS
END TestArrayShifter;
 
ARCHITECTURE behavior OF TestArrayShifter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT array_shifter
    PORT(
		clk, reset: in std_logic;
		insert: in std_logic_vector(Bits_x_t-1 downto 0);
		start: in std_logic;
		done_tick: out std_logic;
		a_shift: out x_t(N-1 downto 0)
		);
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal insert : std_logic_vector(Bits_x_t-1 downto 0) := (others => '0');
   signal start : std_logic := '0';

 	--Outputs
   signal done_tick : std_logic;
   signal a_shift : x_t(N-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	-- Test constants
	constant zerosxtarray: x_t(N-1 downto 0) := (others =>(others => '0'));
	constant test1: std_logic_vector(Bits_x_t-1 downto 0) := "10101010";
	constant test2: std_logic_vector(Bits_x_t-1 downto 0) := "01010101";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: array_shifter PORT MAP (
          clk => clk,
          reset => reset,
          insert => insert,
          start => start,
          done_tick => done_tick,
          a_shift => a_shift
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
      -- hold reset state for 50 ns.
		reset <= '1';
      wait for 50 ns;
		reset <= '0';
      wait for clk_period*2;
		wait until falling_edge(clk);
		
      --primero me fijo que esté todo en cero
		assert a_shift = zerosxtarray report "la salida no esta en cero al ppio" severity failure;
		assert done_tick = '0' report "el done tick no esta en cero al ppio" severity failure;
		
		--ahora carguemos un valor cualquiera
		insert <= test1;
		start <= '1';
		wait until rising_edge(done_tick);
		assert a_shift(N-1) = test1 report "el valor test1 no se inserto bien" severity failure;
		assert a_shift(N-2 downto 0) = zerosxtarray(N-2 downto 0) report "el resto de valores no son cero desp de insertar test1" severity failure;
		
		
		start <= '0';
		wait for clk_period;
		
		--carguemos otro mas
		insert <= test2;
		start <= '1';
		wait until rising_edge(done_tick);
		assert a_shift(N-1) = test2 report "el valor test2 no se inserto bien" severity failure;
		assert a_shift(N-2) = test1 report "el valor test1 no se mantuvo en el array desp de insertar test2" severity failure;
		assert a_shift(N-3 downto 0) = zerosxtarray(N-3 downto 0) report "el resto de valores no son cero desp de insertar test2" severity failure;
		
		start <= '0';
		wait for clk_period;

      -- hold reset state for 50 ns.
		reset <= '1';
      wait for 50 ns;
		reset <= '0';
      wait for clk_period*2;
		wait until falling_edge(clk);
		
		start <= '1';
		--carguemos muchos valores en el array (de 0 a N-1)
		for i in 0 to N-1 loop
			insert <= std_logic_vector(to_unsigned(i,Bits_x_t));
			wait until rising_edge(done_tick);
		end loop;
		
		--veamos que todos los valores estan bien
		for i in 0 to N-1 loop
			assert a_shift(i) = std_logic_vector(to_unsigned(i,Bits_x_t)) report "algun valor de los insertados en orden esta mal" severity failure;
		end loop;
		
		--insertemos otro valor más, y verifiquemos que la muestra más antigua es la que se elimina
		insert <= std_logic_vector(to_unsigned(N,Bits_x_t));
		wait until rising_edge(done_tick);
		for i in 1 to N loop
			assert a_shift(i-1) = std_logic_vector(to_unsigned(i,Bits_x_t)) report "no se borró la muestra más antigua" severity failure;
		end loop;

		--todo bien
		assert false report "todo bien :D" severity failure;
   end process;

END;
