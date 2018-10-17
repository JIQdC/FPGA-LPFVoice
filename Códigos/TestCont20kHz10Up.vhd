LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY TestCont20kHz10Up IS
END TestCont20kHz10Up;
 
ARCHITECTURE behavior OF TestCont20kHz10Up IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Cont20kHz10Up
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         max_tick : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal max_tick : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Cont20kHz10Up PORT MAP (
          clk => clk,
          reset => reset,
          max_tick => max_tick
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

      wait for clk_period*15;
		
		--esperamos al rising edge del max tick
		wait until rising_edge(max_tick);
		wait for 2 ns;
		
		--veamos que el max tick dure 10 clks
		for i in 0 to 9 loop
			assert max_tick = '1' report "el max tick se baja antes de 10 clocks" severity failure;
			wait for clk_period;
		end loop;
		
		-- y ahora veamos que esto se repite luego de 1/20k
		wait for 4991*clk_period;
		assert max_tick = '1' report "el clk no tiene frecuencia de 20kHz" severity failure;

      --todo bien
		assert false report "todo bien :D" severity failure;

      wait;
   end process;

END;
