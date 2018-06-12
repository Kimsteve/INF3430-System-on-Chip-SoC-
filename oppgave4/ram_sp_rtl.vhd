library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use work.inf3430.all;

architecture ram_sp_rtl of ram_sp is


	component debouncer is
		generic (
		 cwidth : natural 
		  );
		port (
			rst       : in  std_logic;
			clk       : in  std_logic;
			bounced   : in  std_logic;
			debounced : out std_logic
		);
	end component;

  -- Deklarasjoner
  signal load_run_sp_i : std_logic;
  signal store_sp_en_i : std_logic;
  signal cs_ram_n_i    : std_logic;
  signal we_ram_n_i    : std_logic;
  signal oe_ram_n_i    : std_logic;
  signal lb_ram_n_i    : std_logic;
  signal ub_ram_n_i    : std_logic;


  signal adr_inc : std_logic;
  signal adr_rst : std_logic;
  signal adr_i   : unsigned(7 downto 0);
  signal d_out_i : std_logic_vector(15 downto 0);

  --Definisjoner av tilstander  
  type   ram_states is (idle_st, wr_en_st, wr_adr_inc_st, rd_en_st, rd_adr_inc_st, wait_st);
  signal current_state, next_state : ram_states;

begin

  sram_address :
    adr <= "0000000000" & std_logic_vector(adr_i);  -- skal benytte adresse 0 i sram

  --data to sram
  sram_data :
    d_out_i <= "000000000" & sp_in;
  d_out <= d_out_i;  -- Tristate buffere legges til i topnivået

  --ram control signal
  sram_control :
    cs_ram_n <= cs_ram_n_i;
  we_ram_n <= we_ram_n_i;
  oe_ram_n <= oe_ram_n_i;
  lb_ram_n <= lb_ram_n_i;
  ub_ram_n <= ub_ram_n_i;

--chip scope signaler

  chip_scope_out(0) <= load_run_sp_i;
  chip_scope_out(1) <= load_sp_mode;
  --Dekoder tilstandene for å vise tilstander i Chip scope fordi
  --vi kan ikke benytte enumererte typer som input til Chip scope

  with current_state select
    chip_scope_out(4 downto 2) <= "000" when idle_st,
    "001"                               when wr_en_st,
    "010"                               when wr_adr_inc_st,
    "011"                               when rd_en_st,
    "100"                               when others;

  chip_scope_out (7 downto 5)  <= std_logic_vector(adr_i(2 downto 0));
  chip_scope_out(15 downto 8)  <= d_out_i(7 downto 0);
  chip_scope_out(23 downto 16) <= d_in(7 downto 0);
  chip_scope_out(24)           <= cs_ram_n_i;
  chip_scope_out(25)           <= we_ram_n_i;
  chip_scope_out(26)           <= oe_ram_n_i;
  chip_scope_out(27)           <= lb_ram_n_i;
  chip_scope_out(28)           <= ub_ram_n_i;
  chip_scope_out(31 downto 29) <= (others => '0');

 -- debounce_1 : entity work.debouncer(debounce_rtl)
 debounce_1 : debouncer
    generic map (26)
    port map (
      rst       => rst,
      clk       => clk,
      bounced   => load_run_sp,
      debounced => load_run_sp_i
      );    

  --Tilstandsmaskin for lesing fra SRAM
  --Kombinatorisk del:  Nextstate logikk og utganger
  ram_ctrl_comb :
  process(current_state, load_run_sp_i, load_sp_mode)
  begin

    cs_ram_n_i    <= '1';               -- ram enabled 
    we_ram_n_i    <= '1';
    oe_ram_n_i    <= '1';
    lb_ram_n_i    <= '1';
    ub_ram_n_i    <= '1';
    adr_inc       <= '0';
    adr_rst       <= '0';
    store_sp_en_i <= '0';
    next_state    <= idle_st;
    case current_state is
      when idle_st =>
        if load_run_sp_i = '1' then
          if load_sp_mode = '1' then
            next_state <= wr_en_st;
          elsif load_sp_mode = '0' then
            next_state <= rd_en_st;
          else
            next_state <= idle_st;
          end if;
        else
          next_state <= idle_st;
        end if;
        
      when wr_en_st =>
        cs_ram_n_i <= '0';
        we_ram_n_i <= '0';
        lb_ram_n_i <= '0';
        ub_ram_n_i <= '0';
        next_state <= wr_adr_inc_st;
        
      when wr_adr_inc_st =>
        adr_inc    <= '1';
        next_state <= idle_st;
        
      when rd_en_st =>
        cs_ram_n_i    <= '0';
        oe_ram_n_i    <= '0';
        lb_ram_n_i    <= '0';
        ub_ram_n_i    <= '0';
        store_sp_en_i <= '1';
        next_state    <= rd_adr_inc_st;

      when rd_adr_inc_st =>
        adr_inc    <= '1';
        next_state <= idle_st;

      when wait_st =>
        if load_run_sp_i = '1' then
          next_state <= wait_st;
        else
          next_state <= idle_st;
        end if;
      when others =>
        next_state <= idle_st;
        
    end case;
  end process;

  --current state register
  ram_ctrl_state_reg :
  process(rst, clk)
  begin
    if rst = '1' then
      current_state <= idle_st;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  adr_reg :
  process(rst, clk)
  begin
    if rst = '1' then
      adr_i <= (others => '0');
    elsif rising_edge(clk) then
      if adr_rst = '1' then
        adr_i <= (others => '0');
      elsif adr_inc = '1' then
        adr_i <= adr_i + 1;
      end if;
    end if;
  end process;

  --input register
  sp_out_register :
  process(rst, clk)
  begin
    if rst = '1' then
      sp_out <= (others => '0');
    elsif rising_edge(clk) then
      if store_sp_en_i = '1' then
        sp_out <= "0" & d_in(6 downto 0);
      end if;
    end if;
  end process;
end ram_sp_rtl;
