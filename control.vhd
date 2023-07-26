library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlModule is
    port (
        inputInstruction : in std_logic_vector(31 downto 0);

        -- EX (Estágio de Execução)
        aluSrc : out std_logic;
        aluOp : out std_logic_vector(1 downto 0);

        -- MEM (Estágio de Acesso à Memória)
        branch : out std_logic;
        jal : out std_logic_vector(1 downto 0); -- Indica se a instrução é jal (== 01) ou jalr (== 10)
        memWrite : out std_logic; -- memWrite = 1; memRead = 0

        -- WB (Estágio de Write Back)
        regWrite : out std_logic;
        resultSrc : out std_logic_vector(2 downto 0) -- Mem2Reg estendido
    );
end entity;

architecture cont of ControlModule is

    signal opcode : std_logic_vector(7 downto 0);
    signal funct3 : std_logic_vector(3 downto 0);
    signal funct7 : std_logic_vector(7 downto 0);

begin

    opcode <= '0' & inputInstruction(6 downto 0);
    funct3 <= '0' & inputInstruction(14 downto 12);
    funct7 <= '0' & inputInstruction(31 downto 25);

    process (inputInstruction, opcode, funct3, funct7) begin

        -- Type R: ADD, SUB, AND, SLT, OR, XOR, SLTU
        if (opcode = x"33") then
            aluSrc <= '0'; -- Use valor do Registrador para ALU
            aluOp <= "10"; -- Tipo R ou Tipo I
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "000"; -- Registrador recebe saída da ALU

        -- Type I: ADDi, ANDi, ORi, XORi, SLLi, SRLi, SRAi, SLTi, SLTUi
        elsif (opcode = x"13") and (funct3 = x"0") then
            aluSrc <= '1'; -- Use valor imediato para ALU
            aluOp <= "10"; -- Tipo R ou Tipo I
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "000"; -- Registrador recebe saída da ALU

        -- Type U
        elsif (opcode = x"17") then -- AUIPC
            aluSrc <= '1'; -- Use valor imediato para ALU
            aluOp <= "10"; -- Tipo R ou Tipo I
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "011"; -- Registrador recebe IMM + PC

        elsif (opcode = x"37") then -- LUI
            aluSrc <= '-'; -- (Não Importa)
            aluOp <= "--"; -- (Não Importa)
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "100"; -- Registrador recebe IMM

        ---- Subrotinas

        -- JAL
        elsif (opcode = x"6F") then
            aluSrc <= '-'; -- (Não Importa)
            aluOp <= "--"; -- (Não Importa)
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "01"; -- Atualiza o PC devido a Jal
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "010"; -- Registrador RD recebe PC+4

        -- JALR
        elsif (opcode = x"67") and (funct3 = x"0") then
            aluSrc <= '1'; -- Use valor imediato para ALU
            aluOp <= "10"; -- Tipo R ou Tipo I
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "10"; -- Atualiza o PC devido a Jalr
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "010"; -- Registrador RD recebe PC+4

        ---- Saltos

        -- Type SB (BRANCH): BEQ, BNE, BLT, BGE, BLTU, BGEU
        elsif (opcode = x"63") then
            aluSrc <= '0'; -- Use valor do Registrador para ALU
            aluOp <= "01"; -- Tipo Branch
            branch <= '1'; -- Atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '0'; -- Não escreve de volta no Registrador
            resultSrc <= "---"; -- (Não Importa)

        ---- Memória

        -- LW (I)
        elsif (opcode = x"03") and (funct3 = x"2") then
            aluSrc <= '1'; -- Use valor imediato para ALU
            aluOp <= "00"; -- Tipo de Memória
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Lê da Memória
            regWrite <= '1'; -- Escreve de volta no Registrador
            resultSrc <= "001"; -- Registrador recebe saída da Memória

        -- SW (S)
        elsif (opcode = x"23") and (funct3 = x"2") then
            aluSrc <= '1'; -- Use valor imediato para ALU
            aluOp <= "00"; -- Tipo de Memória
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '1'; -- Escreve na Memória
            regWrite <= '0'; -- Não escreve de volta no Registrador
            resultSrc <= "---"; -- (Não Importa)

        ---- NOP (ADDI x0, x0, 0 := x"0000 0013")

        elsif (inputInstruction = x"00000013") then
            aluSrc <= '-'; -- (Não Importa)
            aluOp <= "--"; -- (Não Importa)
            branch <= '0'; -- Não atualiza o PC devido a Branch
            jal <= "00"; -- Não atualiza o PC devido a Jal(r)
            memWrite <= '0'; -- Não escreve na memória
            regWrite <= '0'; -- Não escreve de volta no Registrador
            resultSrc <= "---"; -- (Não Importa)

        end if;

    end process;

end cont;