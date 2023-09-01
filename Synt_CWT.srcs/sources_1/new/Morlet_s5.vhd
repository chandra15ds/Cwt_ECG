----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 16:51:55
-- Design Name: 
-- Module Name: Morlet_s5 - Behavioral
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

entity Morlet_s5 is
port(
    clk : in std_logic;
    ena : in std_logic;
    enb : in std_logic;
    wea : in std_logic;
    addra : in std_logic_vector(5 downto 0);
    addrb : in std_logic_vector(5 downto 0);
    dia : in std_logic_vector(7 downto 0);
    dob : out std_logic_vector(7 downto 0)
);
end Morlet_s5;

architecture Behavioral of Morlet_s5 is
type ram_type is array (0 to 49) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F4",x"F4",x"F4",x"F4",x"F4",x"F4",x"F5",x"F4",x"F4",x"F3",x"F4",x"F7",
    x"FB",x"FA",x"EC",x"DA",x"DE",x"06",x"37",x"32",x"DE",x"80",x"84",x"FF",x"7F",x"7F",x"FF",x"84",x"80",
    x"DE",x"32",x"37",x"06",x"DE",x"DA",x"EC",x"FA",x"FB",x"F7",x"F4",x"F3",x"F4",x"F4",x"F5",x"F4",x"F4",x"F4",x"F4",x"F4",x"F4");

attribute rom_style : string;
attribute rom_style of RAM : variable is "block";
begin

process(clk)
begin
    if clk'event and clk = '1' then
        if ena = '1' then
            if wea = '1' then
                RAM(conv_integer(addra)) := dia;
            end if;
        end if;
    end if;
end process;

process(clk)
begin
    if clk'event and clk = '1' then
        if enb = '1' then
             dob <= RAM(conv_integer(addrb));
        end if;
    end if;
end process;



end Behavioral;
