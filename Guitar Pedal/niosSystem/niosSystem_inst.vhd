	component niosSystem is
		port (
			clk_clk           : in  std_logic                    := 'X'; -- clk
			reset_reset_n     : in  std_logic                    := 'X'; -- reset_n
			green_leds_export : out std_logic_vector(7 downto 0)         -- export
		);
	end component niosSystem;

	u0 : component niosSystem
		port map (
			clk_clk           => CONNECTED_TO_clk_clk,           --        clk.clk
			reset_reset_n     => CONNECTED_TO_reset_reset_n,     --      reset.reset_n
			green_leds_export => CONNECTED_TO_green_leds_export  -- green_leds.export
		);

