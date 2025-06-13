library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity risc_pipeline_tb is
end risc_pipeline_tb;

architecture sim of risc_pipeline_tb is

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- DUT component
    component risc_pipeline_top
        port (
            clk : in std_logic;
            rst : in std_logic
        );
    end component;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Reset process
    stim_proc : process
    begin
        rst <= '1';
        wait for 50 ns;
        rst <= '0';

        -- Run simulation for some time
        wait for 2000 ns;

        -- End simulation
        assert false report "End of simulation." severity failure;
    end process;

    -- Instantiate DUT
    DUT: risc_pipeline_top
        port map (
            clk => clk,
            rst => rst
        );

end sim;
