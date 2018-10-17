library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_test is
	port(
		clk, reset: in std_logic;
		tx: out std_logic;
		tx_full: out std_logic
		);
end uart_tx_test;

architecture arch of uart_tx_test is
	signal data: std_logic_vector(7 downto 0);
	signal contup, uartup, up20: std_logic;
	signal max20: std_logic;
	
	begin
	
	--sintetizo componentes
	--contador de 00 a FF, avanza controlado por upcont
	Cont8Bits: entity work.univ_bin_counter(arch)
		generic map (N => 8)
		port map (up => max20, clk => clk, reset => reset, q => data);
	
	UartTx: entity work.uart_tx_unit(arch)
		port map (clk => clk, reset => reset, w_data => data, wr_uart => max20,
					tx => tx, tx_full => tx_full);
	
	Clk20kHz: entity work.Cont20kHz(arch)
		generic map (N => 13)
		port map (clk => clk, reset => reset, max_tick => max20);
		
end arch;