----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.11.2022 14:15:20
-- Design Name: 
-- Module Name: proc_element - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--use IEEE.std_logic_signed.all;
--use work.fixed_pkg.all;
--use work.predefined.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity proc_element is
  Port (
    clk, valid: in std_logic ;
    in_a, in_b: in std_logic_vector(7 downto 0);
    in_c : in std_logic_vector(31 downto 0);
    out_a, out_b : out std_logic_vector(7 downto 0);
    out_c : out std_logic_vector(31 downto 0) );
end proc_element;

architecture Behavioral of proc_element is
begin

process (clk)
variable p_mult,p_add: signed(31 downto 0);
begin
   if  (clk'event and clk='1') then
        if valid = '0'  then
            out_c<= (others => '0');
            out_b<= (others => '0');
            out_a<= (others => '0');
        else
           p_mult:= resize(signed(in_b)*signed(in_a),32);
           p_add := resize(signed(in_c)+p_mult,32);
           out_c <= std_logic_vector(p_add);
--           out_c <= std_logic_vector(resize(signed(in_c)+ resize(signed(in_b)*signed(in_a),32),32));
           out_a<= in_a;
           out_b<= in_b;
        end if;
    end if;
end process;

end Behavioral;
