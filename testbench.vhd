library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is
end entity;

architecture arch of testbench is

    component CPU is
        port (
            clock : in std_logic;
            reset : in std_logic
        );
    end component;

    signal clock_i : std_logic;
    signal reset_i : std_logic;

begin

  dut: CPU port map (
        clock => clock_i,
        reset => reset_i
    );

  drive: process begin

    reset_i <= '0';
    clock_i <= '0';
    wait for 10 ns;

    reset_i <= '1';
    clock_i <= '1';
    wait for 10 ns;
		
    reset_i <= '0';
    clock_i <= '0';
    wait for 10 ns;
        
    for i in 0 to 30 loop

      clock_i <= '1';
      wait for 10 ns;

      clock_i <= '0';
      wait for 10 ns;
            
    end loop;
    wait;
  end process;

end arch;