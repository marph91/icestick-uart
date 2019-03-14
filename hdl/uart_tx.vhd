library ieee;
  use ieee.std_logic_1164.all;

entity uart_tx is
  generic (
    C_BITS : integer range 5 to 8 := 8;
    C_CYCLES_PER_BIT : integer := 100
  );
  port (
    isl_clk : in std_logic;
    isl_valid : in std_logic;
    islv_data : in std_logic_vector(C_BITS-1 downto 0);
    osl_data : out std_logic
  );
end entity uart_tx;

architecture rtl of uart_tx is
  signal int_cycle_cnt : integer range 0 to C_CYCLES_PER_BIT-1 := 0;
  signal int_bit_cnt : integer range 0 to C_BITS+2 := 0;
  
  signal slv_data_n : std_logic_vector(C_BITS downto 0) := (others => '0'); -- low active
  signal isl_valid_d1 : std_logic := '0';

  signal sl_sending : std_logic := '0';

begin
  process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      -- delay signals to detect edge
      isl_valid_d1 <= isl_valid;

      -- initialize sending
      if sl_sending = '0' and isl_valid = '1' and isl_valid_d1 = '0' then
        sl_sending <= '1';
        int_cycle_cnt <= 0;
        int_bit_cnt <= 0;                      
        slv_data_n <= not islv_data & '1';
      end if;

      if sl_sending = '1' then
        if int_cycle_cnt < C_CYCLES_PER_BIT-1 then
          int_cycle_cnt <= int_cycle_cnt+1;
        elsif int_bit_cnt < C_BITS+1 then
          int_cycle_cnt <= 0;
          int_bit_cnt <= int_bit_cnt+1;
          slv_data_n <= '0' & slv_data_n(slv_data_n'LEFT downto 1);
        else
          sl_sending <= '0';
        end if;
      end if;
    end if;
  end process;
  osl_data <= not slv_data_n(0);
end architecture rtl;
