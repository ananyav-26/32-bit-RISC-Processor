library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_stage is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        mem_read     : in  std_logic;
        mem_write    : in  std_logic;
        addr         : in  std_logic_vector(31 downto 0);
        write_data   : in  std_logic_vector(31 downto 0);
        read_data    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of mem_stage is
    type ram_type is array (0 to 255) of std_logic_vector(31 downto 0);
    signal data_mem : ram_type := (others => (others => '0'));
    signal rdata    : std_logic_vector(31 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rdata <= (others => '0');
            else
                -- Write operation
                if mem_write = '1' then
                    data_mem(to_integer(unsigned(addr(9 downto 2)))) <= write_data;
                end if;

                -- Read operation
                if mem_read = '1' then
                    rdata <= data_mem(to_integer(unsigned(addr(9 downto 2))));
                else
                    rdata <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Output
    read_data <= rdata;

end architecture;
