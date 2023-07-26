-------------------------------------- Junção dos componentes do Pipeline----------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port (
  		clock : in std_logic;
		  reset : in std_logic       
 	);
end entity;

architecture structure_pipeline of CPU is -- Início da architeture
    
-------------------------------------------- IF ---------------------------------------------------

component MUX_PC_Module is -- Componente mux do IF
  port (
    in_PCMux_Src    : in std_logic_vector(1 downto 0);
    in_Adder_In     : in std_logic_vector(31 downto 0);
    in_PC_Imm_In    : in std_logic_vector(31 downto 0);
    in_Reg_Imm_In   : in std_logic_vector(31 downto 0);
    out_PCMux_Out   : out std_logic_vector(31 downto 0)
);
end component;
signal PCMux_out_bus : std_logic_vector(31 downto 0);

component pc is -- Componente PC
  port(
      pc_clock : in std_logic;
      pc_reset : in std_logic;
      pc_in    : in std_logic_vector(31 downto 0);
      pc_out   : out std_logic_vector(31 downto 0);
      pc_out_address: out std_logic_vector(7 downto 0)
  );
end component;
signal PCReg_out_bus : std_logic_vector(31 downto 0);
signal PCReg_address_out_bus : std_logic_vector(7 downto 0);

component adder_module is -- Componente somadores do IF
  port (
    in_Adder_In  : in std_logic_vector(31 downto 0);
    out_Adder_Out : out std_logic_vector(31 downto 0)
);
end component;
signal PCAdder_out_bus : std_logic_vector(31 downto 0);

component memory_inst is -- Memória de instruções
  port (
    address    : in std_logic_vector(7 downto 0);
    instr_out : out std_logic_vector(31 downto 0)
  );
end component;
signal MI_Instr_out_bus : std_logic_vector(31 downto 0);

component InstructionFetchDecodePipeline is
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
end component;
signal IF_ID_PC_out_bus : std_logic_vector(31 downto 0);
signal IF_ID_Instr_out_bus : std_logic_vector(31 downto 0);
signal IF_ID_rs1_out_bus : std_logic_vector(4 downto 0);
signal IF_ID_rs2_out_bus : std_logic_vector(4 downto 0);
signal IF_ID_rd_out_bus : std_logic_vector(4 downto 0);
signal IF_ID_PC_PLUS_4_out_bus : std_logic_vector(31 downto 0);

-------------------------------------------- ID ---------------------------------------------------

component ControlModule is
  port (
    inputInstruction : in std_logic_vector(31 downto 0);

    -- EX (Estágio de Execução)
    aluSrc : out std_logic;
    aluOp  : out std_logic_vector(1 downto 0);

    -- MEM (Estágio de Acesso à Memória)
    branch : out std_logic;
    jal    : out std_logic_vector(1 downto 0); -- Indica se a instrução é jal (== 01) ou jalr (== 10)
    memWrite : out std_logic; -- memWrite = 1; memRead = 0

    -- WB (Estágio de Write Back)
    regWrite  : out std_logic;
    resultSrc : out std_logic_vector(2 downto 0) -- Mem2Reg estendido
);
end component;
signal CONTROL_ALUSrc_bus : std_logic;
signal CONTROL_ALUOp_bus : std_logic_vector(1 downto 0);
signal CONTROL_Branch_bus : std_logic;
signal CONTROL_Jal_bus : std_logic_vector(1 downto 0);
signal CONTROL_MemWrite_bus : std_logic;
signal CONTROL_RegWrite_bus : std_logic;
signal CONTROL_ResultSrc_bus : std_logic_vector(2 downto 0);

component xregs is
  generic (WSIZE : natural := 32);
  port (
      clock, wren, rst : in std_logic;
      rs1, rs2, rd : in std_logic_vector(4 downto 0);
      data : in std_logic_vector(WSIZE-1 downto 0);
      ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
    );
end component;
signal XRegs_ro1_bus, XRegs_ro2_bus : std_logic_vector(31 downto 0);

component immGen is
  port (
    instr : in  std_logic_vector(31 downto 0);
    imm32 : out signed(31 downto 0)
    );
end component;
signal GEN_IMM_imm32_bus : std_logic_vector(31 downto 0);

component InstructionDecodeExecutePipeline is
	port (
  		ID_EX_clk : in std_logic;

  		ID_EX_PC_in : in std_logic_vector(31 downto 0);
        ID_EX_PC_out : out std_logic_vector(31 downto 0);
        
        ID_EX_ro1_in : in std_logic_vector(31 downto 0);
        ID_EX_ro1_out : out std_logic_vector(31 downto 0);
        
        ID_EX_ro2_in : in std_logic_vector(31 downto 0);
        ID_EX_ro2_out : out std_logic_vector(31 downto 0);
        
        ID_EX_rd_in : in std_logic_vector(4 downto 0);
        ID_EX_rd_out : out std_logic_vector(4 downto 0);
        
        ID_EX_imm_in : in std_logic_vector(31 downto 0);
        ID_EX_imm_out : out std_logic_vector(31 downto 0);
        
        ID_EX_instr_in : in std_logic_vector(31 downto 0);
        ID_EX_instr_out : out std_logic_vector(31 downto 0);
        
        ID_EX_PC_PLUS_4_in : in std_logic_vector(31 downto 0);
        ID_EX_PC_PLUS_4_out : out std_logic_vector(31 downto 0);

        -- control
        ID_EX_CONTROL_ALUSrc_in : in std_logic;
        ID_EX_CONTROL_ALUOp_in : in std_logic_vector(1 downto 0);
        ID_EX_CONTROL_Branch_in : in std_logic;
        ID_EX_CONTROL_Jal_in : in std_logic_vector(1 downto 0);
        ID_EX_CONTROL_MemWrite_in : in std_logic;
        ID_EX_CONTROL_RegWrite_in : in std_logic;
        ID_EX_CONTROL_ResultSrc_in : in std_logic_vector(2 downto 0);

        ID_EX_CONTROL_ALUSrc_out : out std_logic;
        ID_EX_CONTROL_ALUOp_out : out std_logic_vector(1 downto 0);
        ID_EX_CONTROL_Branch_out : out std_logic;
        ID_EX_CONTROL_Jal_out : out std_logic_vector(1 downto 0);
        ID_EX_CONTROL_MemWrite_out : out std_logic;
        ID_EX_CONTROL_RegWrite_out : out std_logic;
        ID_EX_CONTROL_ResultSrc_out : out std_logic_vector(2 downto 0)
 	);
end component;
signal ID_EX_PC_out_bus : std_logic_vector(31 downto 0);
signal ID_EX_ro1_out_bus : std_logic_vector(31 downto 0);
signal ID_EX_ro2_out_bus : std_logic_vector(31 downto 0);
signal ID_EX_rd_out_bus : std_logic_vector(4 downto 0);
signal ID_EX_imm_out_bus : std_logic_vector(31 downto 0);
signal ID_EX_instr_out_bus : std_logic_vector(31 downto 0);
signal ID_EX_PC_PLUS_4_out_bus : std_logic_vector(31 downto 0);
signal ID_EX_CONTROL_ALUSrc_out_bus : std_logic;
signal ID_EX_CONTROL_ALUOp_out_bus : std_logic_vector(1 downto 0);
signal ID_EX_CONTROL_Branch_out_bus : std_logic;
signal ID_EX_CONTROL_Jal_out_bus : std_logic_vector(1 downto 0);
signal ID_EX_CONTROL_MemWrite_out_bus : std_logic;
signal ID_EX_CONTROL_RegWrite_out_bus : std_logic;
signal ID_EX_CONTROL_ResultSrc_out_bus : std_logic_vector(2 downto 0);

-------------------------------------------- EX ---------------------------------------------------

component ADDER_PC_IMM_Module is
  port (
    in_PC_IMM_Adder_PC   : in std_logic_vector(31 downto 0);
    in_PC_IMM_Adder_Imm  : in std_logic_vector(31 downto 0);
    out_PC_IMM_Adder_Out : out std_logic_vector(31 downto 0)
);
end component;
signal PC_IMM_Adder_out_bus : std_logic_vector(31 downto 0);

component MUX_ALU_Module is
  port (
    in_ALU_Src      : in std_logic;
    in_Ro2          : in std_logic_vector(31 downto 0);
    in_Imm          : in std_logic_vector(31 downto 0);
    out_ALU_Out     : out std_logic_vector(31 downto 0)
);
end component;
signal ALUMUX_out_bus : std_logic_vector(31 downto 0);

component ulaRv is
  generic (WSIZE : natural := 32);
  port(
    A, B   : in std_logic_vector(WSIZE-1 downto 0);
    opcode : in std_logic_vector(3 downto 0);
    Z      : out std_logic_vector(WSIZE-1 downto 0);
    zero   : out std_logic
  );
end component;
signal ALU_Z_bus : std_logic_vector(31 downto 0);
signal ALU_zero_bus : std_logic;

component control_ula is
  port (
      control_instr : in std_logic_vector(31 downto 0);
      ula_op        : in std_logic_vector(1 downto 0);
      control_out   : out std_logic_vector(3 downto 0)
  ) ;
end component;
signal ALU_Control_out_bus : std_logic_vector(3 downto 0);

component EX_MEM_PIPE is
	port (
  		EX_MEM_clk : in std_logic;

  		EX_MEM_PC_plus_Imm_in : in std_logic_vector(31 downto 0);
        EX_MEM_Pc_plus_Imm_out : out std_logic_vector(31 downto 0);

        EX_MEM_zero_in : in std_logic;
        EX_MEM_zero_out : out std_logic;

        EX_MEM_ro2_in : in std_logic_vector(31 downto 0);
        EX_MEM_ro2_out : out std_logic_vector(31 downto 0);

        EX_MEM_rd_in : in std_logic_vector(4 downto 0);
        EX_MEM_rd_out : out std_logic_vector(4 downto 0);

        EX_MEM_Alu_in : in std_logic_vector(31 downto 0);
        EX_MEM_Alu_out : out std_logic_vector(31 downto 0);

        EX_MEM_imm_in : in std_logic_vector(31 downto 0);
        EX_MEM_imm_out : out std_logic_vector(31 downto 0);

        EX_MEM_PC_PLUS_4_in : in std_logic_vector(31 downto 0);
        EX_MEM_PC_PLUS_4_out : out std_logic_vector(31 downto 0);

        EX_MEM_address_out : out std_logic_vector(7 downto 0);

        -- control
        EX_MEM_CONTROL_Branch_in : in std_logic;
        EX_MEM_CONTROL_Jal_in : in std_logic_vector(1 downto 0);
        EX_MEM_CONTROL_MemWrite_in : in std_logic;
        EX_MEM_CONTROL_RegWrite_in : in std_logic;
        EX_MEM_CONTROL_ResultSrc_in : in std_logic_vector(2 downto 0);

        EX_MEM_CONTROL_Branch_out : out std_logic;
        EX_MEM_CONTROL_Jal_out : out std_logic_vector(1 downto 0);
        EX_MEM_CONTROL_MemWrite_out : out std_logic;
        EX_MEM_CONTROL_RegWrite_out : out std_logic;
        EX_MEM_CONTROL_ResultSrc_out : out std_logic_vector(2 downto 0)
 	);
end component;
signal EX_MEM_Pc_plus_Imm_out_bus : std_logic_vector(31 downto 0);
signal EX_MEM_zero_out_bus : std_logic;
signal EX_MEM_ro2_out_bus : std_logic_vector(31 downto 0);
signal EX_MEM_rd_out_bus : std_logic_vector(4 downto 0);
signal EX_MEM_Alu_out_bus : std_logic_vector(31 downto 0);
signal EX_MEM_imm_out_bus : std_logic_vector(31 downto 0);
signal EX_MEM_PC_PLUS_4_out_bus : std_logic_vector(31 downto 0);
signal EX_MEM_address_out_bus : std_logic_vector(7 downto 0);
signal EX_MEM_CONTROL_Branch_out_bus : std_logic;
signal EX_MEM_CONTROL_Jal_out_bus : std_logic_vector(1 downto 0);
signal EX_MEM_CONTROL_MemWrite_out_bus : std_logic;
signal EX_MEM_CONTROL_RegWrite_out_bus : std_logic;
signal EX_MEM_CONTROL_ResultSrc_out_bus : std_logic_vector(2 downto 0);

-------------------------------------------- MEM ---------------------------------------------------

component pc_control is
  port (
    pc_branch : in std_logic;
    pc_jals   : in std_logic_vector(1 downto 0);
    pc_zero   : in std_logic;
    pc_en     : out std_logic
  );
end component;
signal PC_Control_en_bus : std_logic_vector(1 downto 0) := "00";

component memory_data is
  port (
    address       : in std_logic_vector(7 downto 0);
    write_enable : in std_logic;
    clock        : in std_logic;
    data_in      : in std_logic_vector(31 downto 0);
    data_out     : out std_logic_vector(32 downto 0)
  );
end component;
signal MD_dataout_bus : std_logic_vector(31 downto 0);

component MEM_WB_PIPE is
	port (
  		MEM_WB_clk : in std_logic;

  		MEM_WB_mem_data_in : in std_logic_vector(31 downto 0);
        MEM_WB_mem_data_out : out std_logic_vector(31 downto 0);

        MEM_WB_Alu_in : in std_logic_vector(31 downto 0);
        MEM_WB_Alu_out : out std_logic_vector(31 downto 0);

        MEM_WB_rd_in : in std_logic_vector(4 downto 0);
        MEM_WB_rd_out : out std_logic_vector(4 downto 0);

        MEM_WB_PC_plus_Imm_in : in std_logic_vector(31 downto 0);
        MEM_WB_Pc_plus_Imm_out : out std_logic_vector(31 downto 0);

        MEM_WB_imm_in : in std_logic_vector(31 downto 0);
        MEM_WB_imm_out : out std_logic_vector(31 downto 0);

        MEM_WB_PC_PLUS_4_in : in std_logic_vector(31 downto 0);
        MEM_WB_PC_PLUS_4_out : out std_logic_vector(31 downto 0);

        -- control
        MEM_WB_CONTROL_RegWrite_in : in std_logic;
        MEM_WB_CONTROL_ResultSrc_in : in std_logic_vector(2 downto 0);

        MEM_WB_CONTROL_RegWrite_out : out std_logic;
        MEM_WB_CONTROL_ResultSrc_out : out std_logic_vector(2 downto 0)
 	);
end component;
signal MEM_WB_mem_data_out_bus : std_logic_vector(31 downto 0);
signal MEM_WB_Alu_out_bus : std_logic_vector(31 downto 0);
signal MEM_WB_rd_out_bus : std_logic_vector(4 downto 0);
signal MEM_WB_Pc_plus_Imm_out_bus : std_logic_vector(31 downto 0);
signal MEM_WB_imm_out_bus : std_logic_vector(31 downto 0);
signal MEM_WB_PC_PLUS_4_out_bus : std_logic_vector(31 downto 0);
signal MEM_WB_CONTROL_RegWrite_out_bus : std_logic;
signal MEM_WB_CONTROL_ResultSrc_out_bus : std_logic_vector(2 downto 0);

-------------------------------------------- WB ---------------------------------------------------

component MUX_XREG_Module is
  port (
    in_Result_Src         : in std_logic_vector(2 downto 0);
    in_ALU_In             : in std_logic_vector(31 downto 0);
    in_Mem_Data_In        : in std_logic_vector(31 downto 0);
    in_Pc_Plus_4_In       : in std_logic_vector(31 downto 0);
    in_Pc_Plus_Imm_In     : in std_logic_vector(31 downto 0);
    in_Imm_In             : in std_logic_vector(31 downto 0);
    out_XREGSMUX_Out      : out std_logic_vector(31 downto 0)
);
end component;
signal XREGSMUX_out_bus : std_logic_vector(31 downto 0);


begin 
----------------------- Início de mapeamento dos sinais ----------------------

-------------------------------------------- IF ---------------------------------------------------

	PCMUX: MUX_PC_Module port map (
		in_PCMux_Src => PC_Control_en_bus,
		in_Adder_In => PCAdder_out_bus,
		in_PC_Imm_In => EX_MEM_Pc_plus_Imm_out_bus,
		in_Reg_Imm_in => EX_MEM_Alu_out_bus,
		out_PCMux_Out => PCMux_out_bus
	);

	PCREG: pc port map (
		pc_clock => clock,
		pc_reset => reset,
    pc_in => PCMux_out_bus,
		pc_out => PCReg_out_bus,
		pc_out_address => PCReg_address_out_bus
	);

	PCADDER: adder_module port map (
		in_Adder_In => PCReg_out_bus,
		out_Adder_Out => PCAdder_out_bus
	);

	MI: memory_inst port map (
		address => PCReg_address_out_bus,
		instr_out => MI_Instr_out_bus
	);

	IF_ID: IF_ID_PIPE port map (
		IF_ID_clk => clock,
		IF_ID_PC_in => PCReg_out_bus,
		IF_ID_PC_out => IF_ID_PC_out_bus,
		IF_ID_Instr_in => MI_Instr_out_bus,
		IF_ID_Instr_out => IF_ID_Instr_out_bus,
		IF_ID_rs1_out => IF_ID_rs1_out_bus,
		IF_ID_rs2_out => IF_ID_rs2_out_bus,
		IF_ID_rd_out => IF_ID_rd_out_bus,
		IF_ID_PC_PLUS_4_in => PCAdder_out_bus,
		IF_ID_PC_PLUS_4_out => IF_ID_PC_PLUS_4_out_bus
	);

-------------------------------------------- ID ---------------------------------------------------

	CONTROL: ControlModule port map (
		inputInstruction => IF_ID_Instr_out_bus,
		aluSrc => CONTROL_ALUSrc_bus,
		aluOp => CONTROL_ALUOp_bus,
		branch => CONTROL_Branch_bus,
		jal => CONTROL_Jal_bus,
		memWrite => CONTROL_MemWrite_bus,
		regWrite => CONTROL_RegWrite_bus,
		resultSrc => CONTROL_ResultSrc_bus
	);

	BancoRegs: xregs port map (
		clock => clock,
		wren => MEM_WB_CONTROL_RegWrite_out_bus,
	  rst => reset,
		rs1 => IF_ID_rs1_out_bus,
		rs2 => IF_ID_rs2_out_bus,
		rd => MEM_WB_rd_out_bus,
		data => XREGSMUX_out_bus,
		ro1 => XRegs_ro1_bus,
		ro2 => XRegs_ro2_bus
	);

	GeradorIMM: immGen port map (
		instr => IF_ID_Instr_out_bus,
		imm32 => GEN_IMM_imm32_bus
	);
	
	ID_EX: ID_EX_PIPE port map (
		ID_EX_clk => clock,
		ID_EX_PC_in => IF_ID_PC_out_bus,
		ID_EX_PC_out => ID_EX_PC_out_bus,
		ID_EX_ro1_in => XRegs_ro1_bus,
		ID_EX_ro1_out => ID_EX_ro1_out_bus,
		ID_EX_ro2_in => XRegs_ro2_bus,
		ID_EX_ro2_out => ID_EX_ro2_out_bus,
		ID_EX_rd_in => IF_ID_rd_out_bus,
		ID_EX_rd_out => ID_EX_rd_out_bus,
		ID_EX_imm_in => GEN_IMM_imm32_bus,
		ID_EX_imm_out => ID_EX_imm_out_bus,
		ID_EX_instr_in => IF_ID_Instr_out_bus,
		ID_EX_instr_out => ID_EX_instr_out_bus,
		ID_EX_PC_PLUS_4_in => IF_ID_PC_PLUS_4_out_bus,
		ID_EX_PC_PLUS_4_out => ID_EX_PC_PLUS_4_out_bus,
		ID_EX_CONTROL_ALUSrc_in => CONTROL_ALUSrc_bus,
		ID_EX_CONTROL_ALUSrc_out => ID_EX_CONTROL_ALUSrc_out_bus,
		ID_EX_CONTROL_ALUOp_in => CONTROL_ALUOp_bus,
		ID_EX_CONTROL_ALUOp_out => ID_EX_CONTROL_ALUOp_out_bus,
		ID_EX_CONTROL_Branch_in => CONTROL_Branch_bus,
		ID_EX_CONTROL_Branch_out => ID_EX_CONTROL_Branch_out_bus,
		ID_EX_CONTROL_Jal_in => CONTROL_Jal_bus,
		ID_EX_CONTROL_Jal_out => ID_EX_CONTROL_Jal_out_bus,
		ID_EX_CONTROL_MemWrite_in => CONTROL_MemWrite_bus,
		ID_EX_CONTROL_MemWrite_out => ID_EX_CONTROL_MemWrite_out_bus,
		ID_EX_CONTROL_RegWrite_in => CONTROL_RegWrite_bus,
		ID_EX_CONTROL_RegWrite_out => ID_EX_CONTROL_RegWrite_out_bus,
		ID_EX_CONTROL_ResultSrc_in => CONTROL_ResultSrc_bus,
		ID_EX_CONTROL_ResultSrc_out => ID_EX_CONTROL_ResultSrc_out_bus
	);

-------------------------------------------- EX ---------------------------------------------------

	PC_IMM_Adder: ADDER_PC_IMM_Module port map (
		in_PC_IMM_Adder_PC => ID_EX_PC_out_bus,
		in_PC_IMM_Adder_Imm => ID_EX_imm_out_bus,
		out_PC_IMM_Adder_Out => PC_IMM_Adder_out_bus
	);

	ALUMUX: MUX_ALU_Module port map (
		in_ALU_Src => ID_EX_CONTROL_ALUSrc_out_bus,
		in_ro2 => ID_EX_ro2_out_bus,
		in_Imm => ID_EX_imm_out_bus,
		out_ALU_Out => ALUMUX_out_bus
	);

	ULA: ulaRv port map (
		opcode => ALU_Control_out_bus,
		A => ID_EX_ro1_out_bus,
		B => ALUMUX_out_bus,
		Z => ALU_Z_bus,
		zero => ALU_zero_bus
	);

	controleULA: control_ula port map (
		control_instr => ID_EX_instr_out_bus,
		ula_op => ID_EX_CONTROL_ALUOp_out_bus,
		control_out => ALU_Control_out_bus
	);

	EX_MEM: EX_MEM_PIPE port map (
		EX_MEM_clk => clock,
		EX_MEM_PC_plus_Imm_in => PC_IMM_Adder_out_bus,
		EX_MEM_Pc_plus_Imm_out => EX_MEM_Pc_plus_Imm_out_bus,
		EX_MEM_zero_in => ALU_zero_bus,
		EX_MEM_zero_out => EX_MEM_zero_out_bus,
		EX_MEM_ro2_in => ID_EX_ro2_out_bus,
		EX_MEM_ro2_out => EX_MEM_ro2_out_bus,
		EX_MEM_rd_in => ID_EX_rd_out_bus,
		EX_MEM_rd_out => EX_MEM_rd_out_bus,
		EX_MEM_Alu_in => ALU_Z_bus,
		EX_MEM_Alu_out => EX_MEM_Alu_out_bus,
		EX_MEM_imm_in => ID_EX_imm_out_bus,
		EX_MEM_imm_out => EX_MEM_imm_out_bus,
		EX_MEM_PC_PLUS_4_in => ID_EX_PC_PLUS_4_out_bus,
		EX_MEM_PC_PLUS_4_out => EX_MEM_PC_PLUS_4_out_bus,
		EX_MEM_address_out => EX_MEM_address_out_bus,
		EX_MEM_CONTROL_Branch_in => ID_EX_CONTROL_Branch_out_bus,
		EX_MEM_CONTROL_Branch_out => EX_MEM_CONTROL_Branch_out_bus,
		EX_MEM_CONTROL_Jal_in => ID_EX_CONTROL_Jal_out_bus,
		EX_MEM_CONTROL_Jal_out => EX_MEM_CONTROL_Jal_out_bus,
		EX_MEM_CONTROL_MemWrite_in => ID_EX_CONTROL_MemWrite_out_bus,
		EX_MEM_CONTROL_MemWrite_out => EX_MEM_CONTROL_MemWrite_out_bus,
		EX_MEM_CONTROL_RegWrite_in => ID_EX_CONTROL_RegWrite_out_bus,
		EX_MEM_CONTROL_RegWrite_out => EX_MEM_CONTROL_RegWrite_out_bus,
		EX_MEM_CONTROL_ResultSrc_in => ID_EX_CONTROL_ResultSrc_out_bus,
		EX_MEM_CONTROL_ResultSrc_out => EX_MEM_CONTROL_ResultSrc_out_bus
	);

-------------------------------------------- MEM ---------------------------------------------------

	Controle_PC: pc_control port map (
		pc_branch => EX_MEM_CONTROL_Branch_out_bus,
		pc_zero => EX_MEM_zero_out_bus,
		pc_jals => EX_MEM_CONTROL_Jal_out_bus,
		pc_en => PC_Control_en_bus
	);

	MD: memory_data port map (
		clock => clock,
		write_enable => EX_MEM_CONTROL_MemWrite_out_bus,
		address => EX_MEM_address_out_bus,
		data_in => EX_MEM_ro2_out_bus,
		data_out => MD_dataout_bus
	);

	MEM_WB: MEM_WB_PIPE port map (
		MEM_WB_clk => clock,
		MEM_WB_mem_data_in => MD_dataout_bus,
		MEM_WB_mem_data_out => MEM_WB_mem_data_out_bus,
		MEM_WB_Alu_in => EX_MEM_Alu_out_bus,
		MEM_WB_Alu_out => MEM_WB_Alu_out_bus,
		MEM_WB_rd_in => EX_MEM_rd_out_bus,
		MEM_WB_rd_out => MEM_WB_rd_out_bus,
		MEM_WB_PC_plus_Imm_in => EX_MEM_Pc_plus_Imm_out_bus,
		MEM_WB_Pc_plus_Imm_out => MEM_WB_Pc_plus_Imm_out_bus,
		MEM_WB_imm_in => EX_MEM_imm_out_bus,
		MEM_WB_imm_out => MEM_WB_imm_out_bus,
		MEM_WB_PC_PLUS_4_in => EX_MEM_PC_PLUS_4_out_bus,
		MEM_WB_PC_PLUS_4_out => MEM_WB_PC_PLUS_4_out_bus,
		MEM_WB_CONTROL_RegWrite_in => EX_MEM_CONTROL_RegWrite_out_bus,
		MEM_WB_CONTROL_RegWrite_out => MEM_WB_CONTROL_RegWrite_out_bus,
		MEM_WB_CONTROL_ResultSrc_in => EX_MEM_CONTROL_ResultSrc_out_bus,
		MEM_WB_CONTROL_ResultSrc_out => MEM_WB_CONTROL_ResultSrc_out_bus
	);

-------------------------------------------- WB ---------------------------------------------------

	XREGSMUX: MUX_XREG_Module port map (
		in_Result_Src => MEM_WB_CONTROL_ResultSrc_out_bus,
		in_ALU_In => MEM_WB_Alu_out_bus,
		in_Mem_Data_In => MEM_WB_mem_data_out_bus,
		in_Pc_Plus_4_In => MEM_WB_PC_PLUS_4_out_bus,
		in_Pc_Plus_Imm_In => MEM_WB_Pc_plus_Imm_out_bus,
		in_Imm_In => MEM_WB_imm_out_bus,
		out_XREGSMUX_Out => XREGSMUX_out_bus
	);

  end structure_pipeline;