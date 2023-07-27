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
        PC  : in std_logic_vector(31 downto 0);
        imm : in std_logic_vector(31 downto 0);
        adder_out : out std_logic_vector(31 downto 0)
    );
end entity ADDER_PC_IMM_Module;

architecture df of ADDER_PC_IMM_Module is
begin
    adder_out <= std_logic_vector(signed(PC) + signed(imm));
end df;