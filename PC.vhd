library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc is
  port(
      pc_clock : in std_logic;
      pc_reset : in std_logic;
      pc_in    : in std_logic_vector(31 downto 0);
      pc_out   : out std_logic_vector(31 downto 0);
      pc_out_address: out std_logic_vector(7 downto 0)
  );
end entity pc;

architecture pc_arch of pc is


begin

  process(pc_clock, pc_reset) begin
    if(pc_reset = '1') then
      pc_out <= x"00000000";
    
    elsif (rising_edge(pc_clock)) then
      pc_out <= pc_in;
      pc_out_address <= pc_in(7 downto 0);
        
    end if;
end process;

end pc_arch;