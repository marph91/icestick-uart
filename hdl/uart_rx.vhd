library ieee;
  use ieee.std_logic_1164.all;

entity uart_rx is
  generic (
    C_BITS : integer range 5 to 8 := 8;
    C_CYCLES_PER_BIT : integer := 100
  );
  port (
    isl_clk : in std_logic;
    isl_data : in std_logic;
    oslv_data : out std_logic_vector(C_BITS-1 downto 0);
    osl_valid : out std_logic
  );
end entity uart_rx;

architecture rtl of uart_rx is
  signal int_cycle_cnt : integer range 0 to C_CYCLES_PER_BIT-1 := 0;
  signal int_bit_cnt : integer range 0 to C_BITS+1 := 0;
  
  signal slv_data : std_logic_vector(C_BITS-1 downto 0) := (others => '0');
  signal isl_data_d1 : std_logic := '0';

  signal sl_receiving : std_logic := '0';
  signal sl_receiving_d1 : std_logic := '0';

begin
  process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      -- delay signals to detect edge
      isl_data_d1 <= isl_data;
      sl_receiving_d1 <= sl_receiving;

      -- initialize receiving
      if sl_receiving = '0' and isl_data_d1 = '1' and isl_data = '0' then
        int_cycle_cnt <= C_CYCLES_PER_BIT / 2;
        int_bit_cnt <= 0;
        sl_receiving <= '1';
      end if;

      if sl_receiving = '1' then
        if int_bit_cnt < C_BITS+1 then
          if int_cycle_cnt < C_CYCLES_PER_BIT-1 then 
            int_cycle_cnt <= int_cycle_cnt+1;
          else
            int_cycle_cnt <= 0; 
            int_bit_cnt <= int_bit_cnt+1;
            slv_data <= isl_data & slv_data(slv_data'LEFT downto 1);
          end if;
        else
          sl_receiving <= '0';
        end if;
      end if;
    end if;
  end process;
  oslv_data <= slv_data;
  osl_valid <= '1' when sl_receiving = '0' and sl_receiving_d1 = '1' else '0';
end architecture rtl;
