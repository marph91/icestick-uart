library ieee;
	use ieee.std_logic_1164.all;

entity uart_top is
	generic (
		constant C_BITS : integer := 8
	);
	port (
		isl_clk : in std_logic;
		isl_data : in std_logic;
		osl_data : out std_logic;
		oslv_data_debug : out std_logic_vector(C_BITS-1 downto 0)
	);
end uart_top;

architecture behavioral of uart_top is
	constant C_QUARTZ_FREQ : integer := 12000000; -- Hz
	constant C_BAUDRATE : integer := 115200; -- words / s

	constant C_CYCLES_PER_BIT : integer := C_QUARTZ_FREQ / C_BAUDRATE;

	signal sl_valid_out_tx : std_logic;
	signal slv_data_out_tx : std_logic_vector(C_BITS-1 downto 0);

begin
	oslv_data_debug <= slv_data_out_tx;
	uart_rx_inst: entity work.uart_rx
	generic map (
		C_BITS => C_BITS,
		C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
	)
	port map (
		isl_clk => isl_clk,
		isl_data => isl_data,
		oslv_data => slv_data_out_tx,
		osl_valid => sl_valid_out_tx
	);
	
	uart_tx_inst: entity work.uart_tx
	generic map (
		C_BITS => C_BITS,
		C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
	)
	port map (
		isl_clk => isl_clk,
		isl_valid => sl_valid_out_tx,
		islv_data => slv_data_out_tx,
		osl_data => osl_data
	);
end behavioral;