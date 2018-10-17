library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MicToUart is
	port(
		clk, reset: in std_logic;
		--puertos desde y hacia el microfono
		SDATA   : in std_logic;
		SCLK     : out std_logic;
		nCS      : out std_logic;
		--puerto a la uart y warning de full
		tx	: out std_logic;
		tx_full: out std_logic
		);		
end MicToUart;

architecture arch of MicToUart is
	signal clk20up8: std_logic;
	signal data: std_logic_vector(11 downto 0);
	signal done: std_logic;
	signal writeTx: std_logic;

begin

	--clock de 20kHz que mantiene su max_tick arriba por 8 clocks
	Clock20kHz10Up: entity work.Cont20kHz10Up(arch)
		port map(clk => clk, reset => reset, max_tick => clk20up8); 	
		
	--modulo que interfacea con el microfono
	PmodMICInterface: entity work.PmodMICRefComp(PmodMic)
		port map(CLK => clk, rst => reset, SDATA => SDATA, SCLK => SCLK, nCS => nCS, DATA => data, START => clk20up8, DONE => done);

	--detector de rising edge
	REdgeDetect: entity work.REdgeToSignal(arch)
		port map(clk => clk, reset => reset, redge => done, output => writeTx);

	--modulo que manda los datos a la UART
	UartTx: entity work.uart_tx_unit(arch)
		port map (clk => clk, reset => reset, w_data => data(11 downto 4), wr_uart => writeTx,
					tx => tx, tx_full => tx_full);

end arch;

