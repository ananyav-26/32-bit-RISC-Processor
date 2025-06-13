library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_unit is
    port (
        id_rs1       : in  std_logic_vector(4 downto 0); -- Source reg 1 in decode stage
        id_rs2       : in  std_logic_vector(4 downto 0); -- Source reg 2 in decode stage
        ex_rd        : in  std_logic_vector(4 downto 0); -- Destination reg in execute stage
        ex_mem_read  : in  std_logic;                    -- Is execute-stage instruction a load?
        stall        : out std_logic                     -- Output signal to stall pipeline
    );
end entity;

architecture rtl of hazard_unit is
begin
    process(id_rs1, id_rs2, ex_rd, ex_mem_read)
    begin
        -- Default: no stall
        stall <= '0';

        -- Load-use hazard detection
        if (ex_mem_read = '1') then
            if (ex_rd /= "00000") and 
               ((ex_rd = id_rs1) or (ex_rd = id_rs2)) then
                stall <= '1';
            end if;
        end if;
    end process;
end architecture;
