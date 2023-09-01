----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 17:24:50
-- Design Name: 
-- Module Name: Morlet_s12 - Behavioral
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

entity Morlet_s12 is
port(
    clk : in std_logic;
    ena : in std_logic;
    enb : in std_logic;
    wea : in std_logic;
    addra : in std_logic_vector(6 downto 0);
    addrb : in std_logic_vector(6 downto 0);
    dia : in std_logic_vector(7 downto 0);
    dob : out std_logic_vector(7 downto 0)
);
end Morlet_s12;

architecture Behavioral of Morlet_s12 is

type ram_type is array (0 to 119) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",
    x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F4",x"F4",x"F4",x"F3",x"F3",x"F3",x"F4",x"F5",x"F7",x"F8",
    x"FA",x"FB",x"FB",x"F9",x"F5",x"EF",x"E8",x"E1",x"DC",x"DB",x"E0",x"EA",x"FB",x"0F",x"22",x"31",x"37",
    x"30",x"1C",x"FC",x"D5",x"AE",x"8F",x"80",x"85",x"A0",x"CD",x"04",x"3A",x"67",x"7F",x"7F",x"67",x"3A",
    x"04",x"CD",x"A0",x"85",x"80",x"8F",x"AE",x"D5",x"FC",x"1C",x"30",x"37",x"31",x"22",x"0F",x"FB",x"EA",
    x"E0",x"DB",x"DC",x"E1",x"E8",x"EF",x"F5",x"F9",x"FB",x"FB",x"FA",x"F8",x"F7",x"F5",x"F4",x"F3",x"F3",
    x"F3",x"F4",x"F4",x"F4",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",
    x"F5",x"F5",x"F5",x"F5",x"F5",x"F5");
 
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
