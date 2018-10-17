LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY TestCont20kHz IS
END TestCont20kHz;
 
ARCHITECTURE behavior OF TestCont20kHz IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Cont20kHz
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
   uut: Cont20kHz PORT MAP (
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

      wait for clk_period*5;

      -- esperamos al rising edge del reloj
		wait until rising_edge(max_tick);
		wait for 2 ns;
		
		--un período después, debería apagarse
		wait for clk_period;
		assert max_tick = '0' report "el max tick no dura un clock" severity failure;
		
		--debería tener frecuencia de 20kHz, o lo que es lo mismo, prenderse cada 5000 períodos de la placa
		wait for 5000*clk_period;
		assert max_tick = '1' report "el reloj no tiene frecuencia de 20kHz" severity failure;
		
		--todo bien
		assert false report "todo bien :D" severity failure;
		

      wait;
   end process;

END;
