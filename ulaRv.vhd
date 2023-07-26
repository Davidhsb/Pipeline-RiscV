library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ulaRv is
  generic (WSIZE : natural := 32);
  port(
    A, B   : in std_logic_vector(WSIZE-1 downto 0);
    opcode : in std_logic_vector(3 downto 0);
    Z      : out std_logic_vector(WSIZE-1 downto 0);
    zero   : out std_logic
  );
end entity ulaRv;

architecture behavior of ulaRv is
  signal a32 : std_logic_vector(31 downto 0) := x"00000000";
begin

  Z <= a32;

  process_ula : process(A, B, opcode, a32) begin
    if (a32 = x"00000000") then zero <= '1'; else zero <= '0'; end if;

    case opcode is
      when "0000" => a32 <= std_logic_vector(signed(A) + signed(B)); -- ADD A, B
      when "0001" => a32 <= std_logic_vector(signed(A) - signed(B)); -- SUB A, B
      when "0010" => a32 <= A AND B; -- AND A, B
      when "0011" => a32 <= A OR B; -- OR A, B
      when "0100" => a32 <= A XOR B; -- XOR A, B
      when "0101" => a32 <= std_logic_vector(shift_left(unsigned(A),to_integer(unsigned(B)))); -- SLL A, B
      when "0110" => a32 <= std_logic_vector(shift_left(signed(A),to_integer(unsigned(B)))); -- SLA A, B
      when "0111" => a32 <= std_logic_vector(shift_right(unsigned(A),to_integer(unsigned(B)))); -- SRL A, B
      when "1000" => a32 <= std_logic_vector(shift_right(signed(A),to_integer(unsigned(B)))); -- SRA A, B
      when "1001" => if (signed(A) < signed(B)) then a32 <= x"00000001"; else a32 <= x"00000000"; end if; -- SLT A, B
      when "1010" => if (unsigned(A) < unsigned(B)) then a32 <= x"00000001"; else a32 <= x"00000000"; end if;-- SLTU A, B
      when "1011" => if (signed(A) >= signed(B)) then a32 <= x"00000001"; else a32 <= x"00000000"; end if;-- SGE A, B
      when "1100" => if (unsigned(A) >= unsigned(B)) then a32 <= x"00000001"; else a32 <= x"00000000"; end if;-- SGEU A, B
      when "1101" => if (A = B) then a32 <= x"00000001"; else a32 <= x"00000000"; end if;-- SEQ A, B
      when "1110" => if (A /= B) then a32 <= x"00000001"; else a32 <= x"00000000"; end if;-- SNE A, B
      when others => a32 <= x"00000000";
    end case;
  end process;
  
end behavior;