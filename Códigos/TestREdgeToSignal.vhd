LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY TestREdgeToSignal IS
END TestREdgeToSignal;
 
ARCHITECTURE behavior OF TestREdgeToSignal IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT REdgeToSignal
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         redge : IN  std_logic;
         output : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal redge : std_logic := '0';

 	--Outputs
   signal output : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: REdgeToSignal PORT MAP (
          clk => clk,
          reset => reset,
          redge => redge,
          output => output
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

      --veamos que la salida esté en cero al principio
		assert output = '0' report "la salida no está en cero al ppio" severity failure;
		
		--prendamos la entrada, y veamos cuánto dura la salida
		redge <= '1';
		wait until rising_edge(output);
		wait for 2 ns;
		wait for clk_period;
		assert output = '0' report "la salida dura más de un clk" severity failure;
		
		--todo bien
		assert false report "todo bien :D" severity failure;

      wait;
   end process;

END;
