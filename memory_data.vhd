library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory_data is
  port (
    address       : in std_logic_vector(7 downto 0);
    write_enable : in std_logic;
    clock        : in std_logic;
    data_in      : in std_logic_vector(31 downto 0);
    data_out     : out std_logic_vector(31 downto 0)
  );
end entity memory_data;

architecture mem_arch of memory_data is
  type ram is array (0 to 255) of std_logic_vector(31 downto 0);
  signal mem : ram;
  signal read_address : std_logic_vector(7 downto 0);

begin

  acess : process(clock) begin
    if (rising_edge(clock) and write_enable = '1') then
      mem(to_integer(unsigned(address))/4) <= data_in;
    end if;
    read_address <= address; -- adiciona um ciclo
  end process;
  data_out <= mem(to_integer(unsigned(read_address))/4);

end mem_arch ;