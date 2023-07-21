library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc_control is
  port (
    pc_branch : in std_logic;
    pc_jals   : in std_logic_vector(1 downto 0);
    pc_zero   : in std_logic;
    pc_en     : out std_logic;

  );
end entity pc_control;

architecture arch_ctr of pc_control is

begin

  process(pc_branch, pc_jals, pc_zero) begin

    if(pc_branch and not(pc_zero)) then -- Branch
      pc_en <= "01";

    elsif(pc_jals == "01") then -- Jal
      pc_en <= "01";

    elsif(pc_jals == "10") then --Jalr
      pc_en <= "10";
    
    else            -- PC + 4
      pc_en <= "00";

    end  if;

  end process;

end arch_ctr ; -- arch_ctr