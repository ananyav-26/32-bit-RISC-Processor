library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wb_stage is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        reg_write     : in  std_logic;                        -- Write enable
        mem_to_reg    : in  std_logic;                        -- 1: mem_data, 0: alu_result
        mem_data      : in  std_logic_vector(31 downto 0);    -- Data from memory
        alu_result    : in  std_logic_vector(31 downto 0);    -- Data from ALU
        write_reg     : in  std_logic_vector(4 downto 0);     -- Destination register
        reg_file_out  : out std_logic_vector(31 downto 0)     -- Output value of write_reg (for test/debug)
    );
end entity;

architecture rtl of wb_stage is
    type reg_file_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_file : reg_file_type := (others => (others => '0'));
    signal write_data : std_logic_vector(31 downto 0);
begin

    -- Select write-back data
    write_data <= mem_data when mem_to_reg = '1' else alu_result;

    -- Synchronous write to register file
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_file <= (others => (others => '0'));
            elsif reg_write = '1' then
                if write_reg /= "00000" then  -- x0 is hardwired to 0
                    reg_file(to_integer(unsigned(write_reg))) <= write_data;
                end if;
            end if;
        end if;
    end process;

    -- Optional observation output for testbench/debug
    reg_file_out <= reg_file(to_integer(unsigned(write_reg)));

end architecture;
