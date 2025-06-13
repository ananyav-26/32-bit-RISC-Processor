library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity risc_pipeline_top is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic
    );
end entity;

architecture rtl of risc_pipeline_top is

    -- === Wires between stages ===
    signal pc              : std_logic_vector(31 downto 0);
    signal instr           : std_logic_vector(31 downto 0);

    -- Decode stage wires
    signal opcode_d        : std_logic_vector(6 downto 0);
    signal rs1_addr, rs2_addr, rd_addr_d : std_logic_vector(4 downto 0);
    signal imm_d           : std_logic_vector(10 downto 0);
    signal imm_ext : std_logic_vector(31 downto 0);
    signal rs1_data, rs2_data : std_logic_vector(31 downto 0);

    -- Control signals
    signal alu_op          : std_logic_vector(3 downto 0);
    signal mem_read, mem_write, alu_src, reg_write, mem_to_reg : std_logic;

    -- Execute stage wires
    signal alu_result      : std_logic_vector(31 downto 0);
    signal zero_flag       : std_logic;

    -- Memory stage wires
    signal mem_data_out    : std_logic_vector(31 downto 0);

    -- Writeback stage wires
    signal writeback_data  : std_logic_vector(31 downto 0);

begin

    -- === FETCH STAGE ===
    fetch_inst: entity work.fetch
        port map (
            clk         => clk,
            rst         => rst,
            pc_src      => '0',                -- No branch logic added
            branch_addr => (others => '0'),
            pc_out      => pc,
            instr       => instr
        );

    -- === DECODE STAGE ===
    decode_inst: entity work.decode
        port map (
            clk      => clk,
            rst      => rst,
            instr_in => instr,
            opcode   => opcode_d,
            rs1      => rs1_addr,
            rs2      => rs2_addr,
            rd       => rd_addr_d,
            imm      => imm_ext
        );

    -- === REGISTER FILE ===
    regfile_inst: entity work.reg_file
        port map (
            clk       => clk,
            rst       => rst,
            rs1_addr  => rs1_addr,
            rs2_addr  => rs2_addr,
            rd_addr   => rd_addr_d,
            rd_data   => writeback_data,
            reg_write => reg_write,
            rs1_data  => rs1_data,
            rs2_data  => rs2_data
        );

    -- === CONTROL UNIT ===
    control_unit_inst: entity work.control_unit
        port map (
            opcode      => opcode_d,
            alu_op      => alu_op,
            mem_read    => mem_read,
            mem_write   => mem_write,
            alu_src     => alu_src,
            reg_write   => reg_write,
            mem_to_reg  => mem_to_reg
        );

  -- Extend immediate to 32 bits
process(imm_d)
begin
    imm_ext <= std_logic_vector(resize(signed(unsigned(imm_d)), 32));
end process;

    -- === EXECUTE STAGE ===
    execute_inst: entity work.ex_stage
        port map (
            clk        => clk,
            rst        => rst,
            alu_op     => alu_op,
            operand_a  => rs1_data,
            operand_b  => rs2_data,
            pc_in      => pc,
            imm        => imm_ext,
            alu_src    => alu_src,
            alu_result => alu_result,
            zero_flag  => zero_flag
        );

    -- === MEMORY STAGE ===
    mem_inst: entity work.mem_stage
        port map (
            clk        => clk,
            rst        => rst,
            mem_read   => mem_read,
            mem_write  => mem_write,
            addr       => alu_result,
            write_data => rs2_data,
            read_data  => mem_data_out
        );

    -- === WRITEBACK STAGE ===
    wb_inst: entity work.wb_stage
        port map (
            clk          => clk,
            rst          => rst,
            reg_write    => reg_write,
            mem_to_reg   => mem_to_reg,
            mem_data     => mem_data_out,
            alu_result   => alu_result,
            write_reg    => rd_addr_d,
            reg_file_out => writeback_data
        );

end architecture;
