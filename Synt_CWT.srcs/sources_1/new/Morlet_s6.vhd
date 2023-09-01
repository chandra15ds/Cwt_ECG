----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 16:51:55
-- Design Name: 
-- Module Name: Morlet_s6 - Behavioral
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

entity Morlet_s6 is
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
end Morlet_s6;

architecture Behavioral of Morlet_s6 is
type ram_type is array (0 to 59) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F8",x"F8",
    x"F8",x"FA",x"FE",x"00",x"FC",x"F0",x"E2",x"E0",x"F6",x"1F",x"3C",x"2E",x"ED",x"9E",x"80",x"B7",x"26",
    x"7F",x"7F",x"26",x"B7",x"80",x"9E",x"ED",x"2E",x"3C",x"1F",x"F6",x"E0",x"E2",x"F0",x"FC",x"00",x"FE",
    x"FA",x"F8",x"F8",x"F8",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9",x"F9");

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
