-- fetch.vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        pc_src  : in  std_logic;
        branch_addr : in std_logic_vector(31 downto 0);
        pc_out  : out std_logic_vector(31 downto 0);
        instr   : out std_logic_vector(31 downto 0)
    );
end fetch;

architecture behavioral of fetch is
    signal pc : std_logic_vector(31 downto 0) := (others => '0');
    type memory_array is array (0 to 255) of std_logic_vector(31 downto 0);
    signal instr_mem : memory_array := (
        0 => x"00000013", -- NOP (ADDI x0,x0,0)
        1 => x"00100093", -- ADDI x1,x0,1
        others => (others => '0')
    );
begin
    process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if pc_src = '1' then
                pc <= branch_addr;
            else
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;
        end if;
    end process;

    pc_out <= pc;
    instr  <= instr_mem(to_integer(unsigned(pc(9 downto 2))));
end behavioral;
