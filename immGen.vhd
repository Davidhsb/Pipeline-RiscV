library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_arith.all;

entity immGen is 
  port (
    instr : in  std_logic_vector(31 downto 0);
    imm32 : out signed(31 downto 0)
    );
end entity;

architecture immGen_arch of immGen is

  type FORMAT_RV is ( R_type, I_type, S_type, SB_type, UJ_type, U_type, UNK_type);
  signal I, S, SB, U, UJ, R : signed(31 downto 0);
  signal instrType : FORMAT_RV;
  signal opcode : unsigned(7 downto 0);
  signal funct3 : std_logic_vector(2 downto 0);

  begin
    I       <= resize(signed(instr(31 downto 20)), 32);
    R       <= x"00000000";
    opcode  <= resize(unsigned(instr(6 downto 0)), 8);
    S       <= resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);
    SB      <= resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & "0"), 32);
    UJ      <= resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & "0"), 32);
    U       <= resize(signed(instr(31 downto 12) & x"000"), 32);
    funct3  <= instr(14 downto 12);
      
    with opcode select
      instrType <=  R_type  when x"33", -- R_type: opcode = 0x33.
                    I_type  when x"03",
                    I_type  when x"13", 
                    I_type  when x"67", -- I_type: opcode = 0x03 ou opcode = 0x13 ou opcode = 0x67.
                    S_type  when x"23", -- S_type: opcode = 0x23.
                    SB_type when x"63", -- SB_type: opcode = 0x63.
                    U_type  when x"17", -- U_type: opcode = 0x17.
                    U_type  when x"37", -- U_type: opcode = 0x37.
                    UJ_type when x"6F", -- UJ_type: opcode = 0x6F.
                    UNK_type when others;

    with instrType select
      imm32   <=  I when I_type,
                  S when S_type,
                  SB when SB_type,
                  U when U_type,
                  UJ when UJ_type,
                  R when others;
end immGen_arch;
