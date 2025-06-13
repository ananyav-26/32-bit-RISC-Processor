library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_stage is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        alu_op        : in  std_logic_vector(3 downto 0);  -- ALU operation select
        operand_a     : in  std_logic_vector(31 downto 0);
        operand_b     : in  std_logic_vector(31 downto 0);
        pc_in         : in  std_logic_vector(31 downto 0); -- For branch/jump calc
        imm           : in  std_logic_vector(31 downto 0); -- Immediate
        alu_src       : in  std_logic;                     -- 1: use imm, 0: use reg
        alu_result    : out std_logic_vector(31 downto 0);
        zero_flag     : out std_logic
    );
end entity;

architecture rtl of ex_stage is
    signal alu_in_b  : std_logic_vector(31 downto 0);
    signal result    : std_logic_vector(31 downto 0);
    signal zero      : std_logic;
begin

    -- Select ALU input B: either operand B or immediate
    alu_in_b <= operand_b when alu_src = '0' else imm;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                result    <= (others => '0');
                zero      <= '0';
            else
                case alu_op is
                    when "0000" =>  -- ADD
                        result <= std_logic_vector(signed(operand_a) + signed(alu_in_b));
                    when "0001" =>  -- SUB
                        result <= std_logic_vector(signed(operand_a) - signed(alu_in_b));
                    when "0010" =>  -- AND
                        result <= operand_a and alu_in_b;
                    when "0011" =>  -- OR
                        result <= operand_a or alu_in_b;
                    when "0100" =>  -- XOR
                        result <= operand_a xor alu_in_b;
                    when others =>
                        result <= (others => '0');
                end case;

                if result = x"00000000" then
                    zero <= '1';
                else
                    zero <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Output assignments
    alu_result <= result;
    zero_flag  <= zero;

end rtl;
