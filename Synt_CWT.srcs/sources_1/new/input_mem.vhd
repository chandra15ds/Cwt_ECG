----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2022 12:35:56
-- Design Name: 
-- Module Name: input_mem - Behavioral
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
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_mem is
 generic (
        numWeight  : integer :=3 ;
        addressWidth : integer:=10 ;
        dataWidth : integer:=16);
    Port ( 
        clk, wen, ren : in std_logic ;
        wadd, radd : in std_logic_vector(addressWidth-1 downto 0);
        xin : in std_logic_vector(dataWidth-1 downto 0);
        xout : out std_logic_vector(dataWidth-1 downto 0)
            );
end input_mem;

architecture Behavioral of input_mem is
type mem is array(0 to numWeight-1) of std_logic_vector(dataWidth-1 downto 0);
shared variable RAM  : mem :=(others => (others => '0'));
begin

process(clk)

begin

    if clk'event and clk = '1' then
       if wen = '1' then
         RAM(conv_integer(wadd)) := xin;
        end if;
     end if;

end process;
    
process(clk)

begin

    if clk'event and clk = '1' then
       if ren = '1' then
        xout <= RAM(conv_integer(radd));
       end if;
    end if;
end process;

end Behavioral;
