library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 4-bit Adder (ADDER_4)
entity adder_module is
    port (
        in_Adder_In  : in std_logic_vector(31 downto 0);
        out_Adder_Out : out std_logic_vector(31 downto 0)
    );
end entity adder_module;

architecture df of adder_module is
begin
    out_Adder_Out <= std_logic_vector(signed(in_Adder_In) + 4);
end df;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Adder for PC + Immediate (ADDER_PC_IMM)
entity ADDER_PC_IMM_Module is
    port (
        in_PC_IMM_Adder_PC  : in std_logic_vector(31 downto 0);
        in_PC_IMM_Adder_Imm : in std_logic_vector(31 downto 0);
        out_PC_IMM_Adder_Out : out std_logic_vector(31 downto 0)
    );
end entity ADDER_PC_IMM_Module;

architecture df of ADDER_PC_IMM_Module is
begin
    out_PC_IMM_Adder_Out <= std_logic_vector(signed(in_PC_IMM_Adder_PC) + signed(in_PC_IMM_Adder_Imm));
end df;