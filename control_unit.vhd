library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port (
        opcode      : in  std_logic_vector(6 downto 0);
        reg_write   : out std_logic;
        mem_to_reg  : out std_logic;
        mem_read    : out std_logic;
        mem_write   : out std_logic;
        alu_src     : out std_logic;
        branch      : out std_logic;
        alu_op      : out std_logic_vector(3 downto 0)  -- 00: add, 01: sub, etc.
    );
end entity;

architecture rtl of control_unit is
begin
    process(opcode)
    begin
        -- Default values
        reg_write   <= '0';
        mem_to_reg  <= '0';
        mem_read    <= '0';
        mem_write   <= '0';
        alu_src     <= '0';
        branch      <= '0';
        alu_op      <= "0000";

        case opcode is
            when "0110011" =>  -- R-type (add, sub)
                reg_write   <= '1';
                alu_src     <= '0';
                alu_op      <= "0010";  -- Look at funct7/funct3 in ALU control
            when "0010011" =>  -- I-type (addi)
                reg_write   <= '1';
                alu_src     <= '1';
                alu_op      <= "0000";
            when "0000011" =>  -- lw
                reg_write   <= '1';
                alu_src     <= '1';
                mem_to_reg  <= '1';
                mem_read    <= '1';
                alu_op      <= "0000";
            when "0100011" =>  -- sw
                reg_write   <= '0';
                alu_src     <= '1';
                mem_write   <= '1';
                alu_op      <= "0000";
            when "1100011" =>  -- beq
                reg_write   <= '0';
                branch      <= '1';
                alu_op      <= "0001";
            when "0110111" =>  -- lui
                reg_write   <= '1';
                alu_src     <= '1';
                alu_op      <= "0011";  -- Load upper immediate
            when "1101111" =>  -- jal
                reg_write   <= '1';
                alu_src     <= '1';
                alu_op      <= "0000";  -- PC + immediate
            when others =>
                null;
        end case;
    end process;
end architecture;
