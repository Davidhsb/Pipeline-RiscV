library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- IF_ID Pipeline:
entity InstructionFetchDecodePipeline is
    port (
        clk            : in std_logic;
        PC_in          : in std_logic_vector(31 downto 0);
        Instruction_in : in std_logic_vector(31 downto 0);
        PC_PLUS_4_in   : in std_logic_vector(31 downto 0);

        PC_out         : out std_logic_vector(31 downto 0);
        Instruction_out: out std_logic_vector(31 downto 0);
        PC_PLUS_4_out  : out std_logic_vector(31 downto 0);
        rs1_out        : out std_logic_vector(4 downto 0);
        rs2_out        : out std_logic_vector(4 downto 0);
        rd_out         : out std_logic_vector(4 downto 0)
    );
end entity;

architecture df of InstructionFetchDecodePipeline is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            PC_out        <= PC_in;
            Instruction_out     <= Instruction_in;
            PC_PLUS_4_out <= PC_PLUS_4_in;
            rs1_out       <= Instruction_in(19 downto 15);
            rs2_out       <= Instruction_in(24 downto 20);
            rd_out        <= Instruction_in(11 downto 7);
        end if;
    end process;
end df;

-- ID_EX Pipeline:
entity InstructionDecodeExecutePipeline is
    port (
        clk             : in std_logic;
        PC_in           : in std_logic_vector(31 downto 0);
        rs1_in          : in std_logic_vector(31 downto 0);
        rs2_in          : in std_logic_vector(31 downto 0);
        rd_in           : in std_logic_vector(4 downto 0);
        imm_in          : in std_logic_vector(31 downto 0);
        instr_in        : in std_logic_vector(31 downto 0);
        PC_PLUS_4_in    : in std_logic_vector(31 downto 0);

        PC_out          : out std_logic_vector(31 downto 0);
        rs1_out         : out std_logic_vector(31 downto 0);
        rs2_out         : out std_logic_vector(31 downto 0);
        rd_out          : out std_logic_vector(4 downto 0);
        imm_out         : out std_logic_vector(31 downto 0);
        instr_out       : out std_logic_vector(31 downto 0);
        PC_PLUS_4_out   : out std_logic_vector(31 downto 0);

        -- control
        ALUSrc          : out std_logic;
        ALUOp           : out std_logic_vector(1 downto 0);
        Branch          : out std_logic;
        Jal             : out std_logic_vector(1 downto 0);
        MemWrite        : out std_logic;
        RegWrite        : out std_logic;
        ResultSrc       : out std_logic_vector(2 downto 0)
    );
end entity;

architecture df of InstructionDecodeExecutePipeline is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            PC_out           <= PC_in;
            rs1_out          <= rs1_in;
            rs2_out          <= rs2_in;
            rd_out           <= rd_in;
            imm_out          <= imm_in;
            instr_out        <= instr_in;
            PC_PLUS_4_out    <= PC_PLUS_4_in;

            -- Control
            ALUSrc           <= '0';
            ALUOp            <= "00";
            Branch           <= '0'; 
            Jal              <= "00";
            MemWrite         <= '0';
            RegWrite         <= '0';
            ResultSrc        <= "000";
        end if;
    end process;
end df;

-- EX_MEM Pipeline:
entity ExecuteMemoryPipeline is
    port (
        clk             : in std_logic;
        PC_plus_Imm_in  : in std_logic_vector(31 downto 0);
        zero_in         : in std_logic;
        ro2_in          : in std_logic_vector(31 downto 0);
        rd_in           : in std_logic_vector(4 downto 0);
        Alu_in          : in std_logic_vector(31 downto 0);
        imm_in          : in std_logic_vector(31 downto 0);
        PC_PLUS_4_in    : in std_logic_vector(31 downto 0);

        PC_PLUS_Imm_out : out std_logic_vector(31 downto 0);
        zero_out        : out std_logic;
        ro2_out         : out std_logic_vector(31 downto 0);
        rd_out          : out std_logic_vector(4 downto 0);
        Alu_out         : out std_logic_vector(31 downto 0);
        imm_out         : out std_logic_vector(31 downto 0);
        PC_PLUS_4_out   : out std_logic_vector(31 downto 0);
        address_out     : out std_logic_vector(7 downto 0);

        -- control
        Branch          : out std_logic;
        Jal             : out std_logic_vector(1 downto 0);
        MemWrite        : out std_logic;
        RegWrite        : out std_logic;
        ResultSrc       : out std_logic_vector(2 downto 0)
    );
end entity;

architecture df of ExecuteMemoryPipeline is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            PC_PLUS_Imm_out <= PC_plus_Imm_in;
            zero_out        <= zero_in;
            ro2_out         <= ro2_in;
            rd_out          <= rd_in;
            Alu_out         <= Alu_in;
            imm_out         <= imm_in;
            PC_PLUS_4_out   <= PC_PLUS_4_in;
            address_out     <= Alu_in(7 downto 0);

            -- Control
            Branch          <= '0';
            Jal             <= "00"; 
            MemWrite        <= '0';
            RegWrite        <= '0';
            ResultSrc       <= "000"; 
        end if;
    end process;
end df;

-- MEM_WB Pipeline:
entity MemoryWriteBackPipeline is
    port (
        clk                : in std_logic;
        mem_data_in        : in std_logic_vector(31 downto 0);
        Alu_in             : in std_logic_vector(31 downto 0);
        rd_in              : in std_logic_vector(4 downto 0);
        PC_plus_Imm_in     : in std_logic_vector(31 downto 0);
        imm_in             : in std_logic_vector(31 downto 0);
        PC_PLUS_4_in       : in std_logic_vector(31 downto 0);

        mem_data_out       : out std_logic_vector(31 downto 0);
        Alu_out            : out std_logic_vector(31 downto 0);
        rd_out             : out std_logic_vector(4 downto 0);
        PC_plus_Imm_out    : out std_logic_vector(31 downto 0);
        imm_out            : out std_logic_vector(31 downto 0);
        PC_PLUS_4_out      : out std_logic_vector(31 downto 0);

        -- Control
        
        RegWrite           : out std_logic;
        ResultSrc          : out std_logic_vector(2 downto 0)
    );
end entity;

architecture df of MemoryWriteBackPipeline is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            mem_data_out       <= mem_data_in;
            Alu_out            <= Alu_in;
            rd_out             <= rd_in;
            PC_plus_Imm_out    <= PC_plus_Imm_in;
            imm_out            <= imm_in; 
            PC_PLUS_4_out      <= PC_PLUS_4_in;
            RegWrite           <= '0';
            ResultSrc          <= "000";
        end if;
    end process;
end df;
