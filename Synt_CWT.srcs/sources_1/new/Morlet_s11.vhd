----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 16:51:55
-- Design Name: 
-- Module Name: Morlet_s11 - Behavioral
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

entity Morlet_s11 is
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
end Morlet_s11;

architecture Behavioral of Morlet_s11 is
type ram_type is array (0 to 109) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",
    x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F4",x"F4",x"F4",x"F4",x"F5",x"F6",x"F8",x"FA",x"FB",x"FC",
    x"FA",x"F7",x"F1",x"E9",x"E1",x"DC",x"DC",x"E3",x"F1",x"05",x"1B",x"2E",x"37",x"32",x"1D",x"FA",x"CF",
    x"A6",x"89",x"80",x"91",x"B9",x"F2",x"2F",x"62",x"7F",x"7F",x"62",x"2F",x"F2",x"B9",x"91",x"80",x"89",
    x"A6",x"CF",x"FA",x"1D",x"32",x"37",x"2E",x"1B",x"05",x"F1",x"E3",x"DC",x"DC",x"E1",x"E9",x"F1",x"F7",
    x"FA",x"FC",x"FB",x"FA",x"F8",x"F6",x"F5",x"F4",x"F4",x"F4",x"F4",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",
    x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5");

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
