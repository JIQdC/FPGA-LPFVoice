library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.filterpack.ALL;

entity LPFVoiceTop is
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
end LPFVoiceTop;

architecture arch of LPFVoiceTop is
	
	signal clk20up8: std_logic;
	signal data: std_logic_vector(11 downto 0);
	signal done: std_logic;
	signal startshift: std_logic;
	signal startfilter: std_logic;
	signal datafilt: std_logic_vector(Bits_x_t + Bits_cte_t - 2 downto 0);
	signal auxshifted: x_t (N-1 downto 0);
	signal writeTx: std_logic;
	
	signal filtcte: cte_t(N-1 downto 0);

begin
	
	--clock de 20kHz que mantiene su max_tick arriba por 8 clocks
	Clock20kHz10Up: entity work.Cont20kHz10Up(arch)
		port map(clk => clk, reset => reset, max_tick => clk20up8);
		
	--modulo que interfacea con el microfono
	PmodMICInterface: entity work.PmodMICRefComp(PmodMic)
		port map(CLK => clk, rst => reset, SDATA => SDATA, SCLK => SCLK, nCS => nCS, DATA => data, START => clk20up8, DONE => done);

	--detector de rising edge
	REdgeDetect: entity work.REdgeToSignal(arch)
		port map(clk => clk, reset => reset, redge => done, output => startshift);
		
	--array shifter
	ArrayShifter: entity work.array_shifter(arch)
		port map(clk => clk, reset => reset, insert => data(11 downto 4), start => startshift, done_tick => startfilter, a_shift => auxshifted);
	
	--constantes del filtro
	ConstFilt: entity work.FiltCte(arch)
		port map(ctes => filtcte);
		
	--filtro pasabajo
	LPF: entity work.LPFilter(arch)
		port map (clk => clk, reset => reset, a => auxshifted, cte => filtcte, start => startfilter, result => datafilt, done_tick => writeTx);	
	
	--modulo que manda los datos a la UART
	UartTx: entity work.uart_tx_unit(arch)
		port map (clk => clk, reset => reset, w_data => datafilt(Bits_x_t + Bits_cte_t - 2 downto Bits_cte_t - 1), wr_uart => writeTx,	tx => tx, tx_full => tx_full);

end arch;

