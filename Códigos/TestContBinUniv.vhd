LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY TestContBinUniv IS
END TestContBinUniv;
 
ARCHITECTURE behavior OF TestContBinUniv IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT univ_bin_counter
    PORT(
         up : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         q : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal up : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal q : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	-- constants
	constant ones : std_logic_vector(7 downto 0) := (others => '1');
	constant zeros : std_logic_vector(7 downto 0) := (others => '0');
	
	--aux signals
	signal aux: std_logic_vector(7 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: univ_bin_counter PORT MAP (
          up => up,
          clk => clk,
          reset => reset,
          q => q
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
		
		--chequeo que todo este en cero al ppio
		assert q = zeros report "la salida al ppio no está en cero" severity failure;
		
		--vamos sumando y viendo que efectivamente sume
		for i in 1 to to_integer(unsigned(ones)) loop
			up <= '1';
			wait for clk_period;
			up <= '0';
			assert q = std_logic_vector(to_unsigned(i,8)) report "no suma bien" severity failure;
		end loop;
		
		--si sumo uno más debería volver a cero
		up <= '1';
		wait for clk_period;
		up <= '0';
		assert q = zeros report "no ciclea de nuevo a cero" severity failure;
		
		--todo bien
		assert false report "todo bien :D" severity failure;

   end process;

END;
