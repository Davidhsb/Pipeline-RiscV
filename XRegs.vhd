library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xregs is 
  generic (WSIZE : natural := 32);
  port (
      clock, wren, rst : in std_logic;
      rs1, rs2, rd : in std_logic_vector(4 downto 0);
      data : in std_logic_vector(WSIZE-1 downto 0);
      ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
    );
end entity xregs;

architecture behavior of XRegs is
  type xarray is array(natural range <>) of std_logic_vector(31 downto 0);
  signal bankReg : xarray(31 downto 0) := (others => (others => '0'));

begin
  writing : process (rst, clock) -- Processo de escrita, sincrono
  begin
    if (rst = '1') then           -- Reseta o banco de registradores
      for i in bankReg'range loop
        bankReg(i) <= x"00000000";
      end loop;
    elsif (rising_edge(clock)) then   -- Escreve o dado no rd
      if ((wren = '1') and (rd /= "00000")) then
        bankReg(to_integer(unsigned(rd))) <= data;
      end if;
    end if;
  end process writing;

  ro1 <= bankReg(to_integer(unsigned(rs1)));
  ro2 <= bankReg(to_integer(unsigned(rs2)));


end behavior;