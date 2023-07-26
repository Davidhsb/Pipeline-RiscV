library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_ula is
  port (
      control_instr : in std_logic_vector(31 downto 0);
      ula_op       : in std_logic_vector(1 downto 0);
      control_out  : out std_logic_vector(3 downto 0)
  ) ;
end control_ula;

architecture control_ula_arch of control_ula is
    
  signal funct3 : std_logic_vector(3 downto 0);
  signal funct7 : std_logic_vector(7 downto 0);

begin

  funct3 <= ('0' & (control_instr(14 downto 12)));
  funct7 <= ('0' & (control_instr(31 downto 25)));

  control : process(ula_op, control_instr, funct3, funct7) begin

    
    case ula_op is

      -- Para executar instruções LW, SW
      when "00" => 
          control_out <= "0000"; -- ADD 

      -- Para executar instruções de Branches
      when "01" =>
          if (funct3 = x"0") then -- BEQ
            control_out <= "1100"; -- Executa SEQ na Ula

          elsif (funct3 = x"1") then -- BNE
            control_out <= "1101"; -- Executa SNE na Ula
          
          elsif (funct3 = x"4") then -- BLT
            control_out <= "1000"; -- Executa SLT na Ula

          elsif (funct3 = x"5") then -- BGE
            control_out <= "1010"; -- Executa SGE na Ula

          elsif (funct3 = x"6") then -- BLTU
            control_out <= "1001"; -- Executa SLTU na Ula

          elsif (funct3 = x"7") then -- BGEU
            control_out <= "1011"; -- Executa SGEU na Ula

          end if;

      -- Para executar instruções R type and I type
      when "10" => 
          if (funct3 = x"0" and funct7 = x"00") then
            control_out <= "0000"; -- ADD

          elsif (funct3 = x"0" and funct7 = x"20") then
              control_out <= "0001"; -- SUB

          elsif (funct3 = x"7" and funct7 = x"00") then
              control_out <= "0010"; -- AND
          
          elsif (funct3 = x"6" and funct7 = x"00") then
              control_out <= "0011"; -- OR

          elsif (funct3 = x"4" and funct7 = x"00") then
              control_out <= "0100"; -- XOR

          elsif (funct3 = x"1" and funct7 = x"00") then
              control_out <= "0101"; -- SLL

          elsif (funct3 = x"5" and funct7 = x"00") then
              control_out <= "0110"; -- SRL

          elsif (funct3 = x"5" and funct7 = x"20") then
              control_out <= "0111"; -- SRA

          elsif (funct3 = x"2") then
              control_out <= "1000"; -- SLT

          elsif (funct3 = x"3") then
              control_out <= "1001"; -- SLTU

          elsif (funct3 = x"0") then -- Faz JALR
              control_out <= "0000"; -- ADD

          end if;
          
      when others => control_out <= "1111";

    end case;
  end process;

end control_ula_arch;