library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        instr_in   : in  std_logic_vector(31 downto 0);
        -- Decoded fields
        opcode     : out std_logic_vector(6 downto 0);
        rs1        : out std_logic_vector(4 downto 0);
        rs2        : out std_logic_vector(4 downto 0);
        rd         : out std_logic_vector(4 downto 0);
        imm        : out std_logic_vector(31 downto 0)  -- Sign-extended immediate
    );
end entity;

architecture behavioral of decode is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                opcode <= (others => '0');
                rs1    <= (others => '0');
                rs2    <= (others => '0');
                rd     <= (others => '0');
                imm    <= (others => '0');
            else
                opcode <= instr_in(31 downto 25);
                rs1    <= instr_in(25 downto 21);
                rs2    <= instr_in(20 downto 16);
                rd     <= instr_in(15 downto 11);

                -- Sign-extend 11-bit immediate (instr_in(10 downto 0)) to 32 bits
                imm <= std_logic_vector(resize(signed(instr_in(10 downto 0)), 32));
            end if;
        end if;
    end process;
end architecture;
