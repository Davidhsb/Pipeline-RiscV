library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- PC MUX

entity MUX_PC_Module is
    port (
        in_PCMux_Src    : in std_logic_vector(1 downto 0);
        in_Adder_In     : in std_logic_vector(31 downto 0);
        in_PC_Imm_In    : in std_logic_vector(31 downto 0);
        in_Reg_Imm_In   : in std_logic_vector(31 downto 0);
        out_PCMux_Out   : out std_logic_vector(31 downto 0)
    );
end entity MUX_PC_Module;

architecture df of MUX_PC_Module is
begin
    process (in_PCMux_Src, in_Adder_In, in_PC_Imm_In, in_Reg_Imm_In)
    begin
        -- Decode the source select signal
        case in_PCMux_Src is
            when "00" =>
                out_PCMux_Out <= in_Adder_In; -- Select Adder input
            when "01" =>
                out_PCMux_Out <= in_PC_Imm_In; -- Select PC+Imm input
            when others =>
                out_PCMux_Out <= in_Reg_Imm_In; -- Select Register+Imm input (default case)
        end case;
    end process;
end df;

-- ULA MUX

entity MUX_ALU_Module is
    port (
        in_ALU_Src      : in std_logic;
        in_Ro2          : in std_logic_vector(31 downto 0);
        in_Imm          : in std_logic_vector(31 downto 0);
        out_ALU_Out     : out std_logic_vector(31 downto 0)
    );
end entity MUX_ALU_Module;

architecture df of MUX_ALU_Module is
begin
    process (in_ALU_Src, in_Ro2, in_Imm)
    begin
        if in_ALU_Src = '0' then
            out_ALU_Out <= in_Ro2; -- Select Register operand 2
        else
            out_ALU_Out <= in_Imm; -- Select Immediate operand
        end if;
    end process;
end df;

-- MUX WB
entity MUX_XREG_Module is
    port (
        in_Result_Src         : in std_logic_vector(2 downto 0);
        in_ALU_In             : in std_logic_vector(31 downto 0);
        in_Mem_Data_In        : in std_logic_vector(31 downto 0);
        in_Pc_Plus_4_In       : in std_logic_vector(31 downto 0);
        in_Pc_Plus_Imm_In     : in std_logic_vector(31 downto 0);
        in_Imm_In             : in std_logic_vector(31 downto 0);
        out_XREGSMUX_Out      : out std_logic_vector(31 downto 0)
    );
end entity MUX_XREG_Module;

architecture df of MUX_XREG_Module is
begin
    process (in_Result_Src, in_ALU_In, in_Mem_Data_In, in_Pc_Plus_4_In, in_Pc_Plus_Imm_In, in_Imm_In)
    begin
        -- Decode the source select signal
        case in_Result_Src is
            when "000" =>
                out_XREGSMUX_Out <= in_ALU_In; -- Select ALU output
            when "001" =>
                out_XREGSMUX_Out <= in_Mem_Data_In; -- Select Memory data
            when "010" =>
                out_XREGSMUX_Out <= in_Pc_Plus_4_In; -- Select PC+4
            when "011" =>
                out_XREGSMUX_Out <= in_Pc_Plus_Imm_In; -- Select PC+Immediate
            when others =>
                out_XREGSMUX_Out <= in_Imm_In; -- Select Immediate value (default case)
        end case;
    end process;
end df