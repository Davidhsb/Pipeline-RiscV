library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity memory_inst is
  port (
    address   : in std_logic_vector(7 downto 0);
    instr_out : out std_logic_vector(31 downto 0)
  );
end entity memory_inst;

architecture memI_arch of memory_inst is
  type rom is array (0 to 255) of std_logic_vector(31 downto 0);

  impure function init_rom_hex return rom is

    file text_file : text open read_mode is "ROM_inst.txt";
    variable text_line : line;
    variable rom_content : rom;

    begin
      for i in 0 to 255 loop
        readline(text_file, text_line);
        hread(text_line, rom_content(i));
      end loop;

    return rom_content;

  end function;

  signal mem : rom := init_rom_hex;

begin

  instr_out <= mem(to_integer(unsigned(address))/4);

end memI_arch ;