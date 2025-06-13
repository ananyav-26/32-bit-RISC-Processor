library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity risc_pipeline_top is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic
    );
end entity;

architecture rtl of risc_pipeline_top is

    -- === Pipeline Registers ===
    signal if_id_instr    : std_logic_vector(31 downto 0);
    signal if_id_pc       : std_logic_vector(31 downto 0);

    signal id_ex_rs1_data, id_ex_rs2_data : std_logic_vector(31 downto 0);
    signal id_ex_imm                      : std_logic_vector(31 downto 0);
    signal id_ex_rd                       : std_logic_vector(4 downto 0);
    signal id_ex_ctrl_signals             : std_logic_vector(7 downto 0); -- packed control signals

    signal ex_mem_alu_result              : std_logic_vector(31 downto 0);
    signal ex_mem_rs2_data                : std_logic_vector(31 downto 0);
    signal ex_mem_rd                      : std_logic_vector(4 downto 0);
    signal ex_mem_ctrl_signals            : std_logic_vector(7 downto 0);

    signal mem_wb_result                  : std_logic_vector(31 downto 0);
    signal mem_wb_rd                      : std_logic_vector(4 downto 0);
    signal mem_wb_ctrl_signals            : std_logic_vector(7 downto 0);

    -- === Other Internal Signals ===
    signal pc            : std_logic_vector(31 downto 0) := (others => '0');
    signal instr_mem_out : std_logic_vector(31 downto 0);
    signal next_pc       : std_logic_vector(31 downto 0);
    signal stall         : std_logic;

    -- From decode
    signal rs1_addr, rs2_addr : std_logic_vector(4 downto 0);
    signal reg_rs1_data, reg_rs2_data : std_logic_vector(31 downto 0);

    -- ALU
    signal alu_result : std_logic_vector(31 downto 0);

    -- Control
    signal reg_write, mem_to_reg, mem_read, mem_write, alu_src, branch : std_logic;
    signal alu_op : std_logic_vector(1 downto 0);

begin

    -- === Instruction Fetch Stage ===
    fetch_stage_inst: entity work.fetch_stage
        port map (
            clk     => clk,
            rst     => rst,
            stall   => stall,
            pc_in   => pc,
            instr   => instr_mem_out,
            pc_out  => next_pc
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc <= (others => '0');
            elsif stall = '0' then
                pc <= next_pc;
            end if;
        end if;
    end process;

    -- IF/ID Pipeline Register
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                if_id_instr <= (others => '0');
                if_id_pc    <= (others => '0');
            elsif stall = '0' then
                if_id_instr <= instr_mem_out;
                if_id_pc    <= pc;
            end if;
        end if;
    end process;

    -- === Decode Stage ===
    decode_stage_inst: entity work.decode_stage
        port map (
            instr      => if_id_instr,
            rs1        => rs1_addr,
            rs2        => rs2_addr,
            imm_out    => id_ex_imm,
            rd         => id_ex_rd
        );

    -- Register File
    reg_file_inst: entity work.reg_file
        port map (
            clk        => clk,
            rst        => rst,
            rs1_addr   => rs1_addr,
            rs2_addr   => rs2_addr,
            rd_addr    => mem_wb_rd,
            rd_data    => mem_wb_result,
            reg_write  => mem_wb_ctrl_signals(7),
            rs1_data   => reg_rs1_data,
            rs2_data   => reg_rs2_data
        );

    -- Control Unit
    control_unit_inst: entity work.control_unit
        port map (
            opcode      => if_id_instr(6 downto 0),
            reg_write   => reg_write,
            mem_to_reg  => mem_to_reg,
            mem_read    => mem_read,
            mem_write   => mem_write,
            alu_src     => alu_src,
            branch      => branch,
            alu_op      => alu_op
        );

    -- Hazard Detection
    hazard_unit_inst: entity work.hazard_unit
        port map (
            id_rs1       => rs1_addr,
            id_rs2       => rs2_addr,
            ex_rd        => id_ex_rd,
            ex_mem_read  => id_ex_ctrl_signals(4),
            stall        => stall
        );

    -- ID/EX Pipeline Register
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                id_ex_rs1_data <= (others => '0');
                id_ex_rs2_data <= (others => '0');
                id_ex_ctrl_signals <= (others => '0');
            elsif stall = '0' then
                id_ex_rs1_data <= reg_rs1_data;
                id_ex_rs2_data <= reg_rs2_data;
                id_ex_ctrl_signals <= reg_write & mem_to_reg & mem_read & mem_write & alu_src & branch & alu_op;
            end if;
        end if;
    end process;

    -- === Execute Stage ===
    execute_stage_inst: entity work.execute_stage
        port map (
            rs1_data   => id_ex_rs1_data,
            rs2_data   => id_ex_rs2_data,
            imm        => id_ex_imm,
            alu_src    => id_ex_ctrl_signals(3),
            alu_op     => id_ex_ctrl_signals(1 downto 0),
            alu_result => alu_result
        );

    -- EX/MEM Pipeline Register
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ex_mem_alu_result <= (others => '0');
                ex_mem_rs2_data   <= (others => '0');
                ex_mem_ctrl_signals <= (others => '0');
            else
                ex_mem_alu_result <= alu_result;
                ex_mem_rs2_data   <= id_ex_rs2_data;
                ex_mem_ctrl_signals <= id_ex_ctrl_signals;
                ex_mem_rd <= id_ex_rd;
            end if;
        end if;
    end process;

    -- === Memory Stage ===
    memory_stage_inst: entity work.memory_stage
        port map (
            clk        => clk,
            addr       => ex_mem_alu_result,
            write_data => ex_mem_rs2_data,
            mem_read   => ex_mem_ctrl_signals(5),
            mem_write  => ex_mem_ctrl_signals(4),
            read_data  => mem_wb_result
        );

    -- MEM/WB Pipeline Register
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                mem_wb_result <= (others => '0');
                mem_wb_ctrl_signals <= (others => '0');
                mem_wb_rd <= (others => '0');
            else
                mem_wb_result <= mem_wb_result; -- From memory
                mem_wb_ctrl_signals <= ex_mem_ctrl_signals;
                mem_wb_rd <= ex_mem_rd;
            end if;
        end if;
    end process;

    -- === Writeback Stage ===
    -- No logic: mem_wb_result written into reg_file via reg_write signal

end architecture;
