----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 16:51:55
-- Design Name: 
-- Module Name: Morlet_s8 - Behavioral
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

entity Morlet_s8 is
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
end Morlet_s8;

architecture Behavioral of Morlet_s8 is

type ram_type is array (0 to 79) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",
    x"F5",x"F5",x"F4",x"F4",x"F4",x"F5",x"F8",x"FA",x"FC",x"FB",x"F4",x"EA",x"E0",x"DB",x"E2",x"F7",x"15",
    x"30",x"39",x"24",x"F3",x"B6",x"88",x"80",x"A9",x"F6",x"4A",x"7F",x"7F",x"4A",x"F6",x"A9",x"80",x"88",
    x"B6",x"F3",x"24",x"39",x"30",x"15",x"F7",x"E2",x"DB",x"E0",x"EA",x"F4",x"FB",x"FC",x"FA",x"F8",x"F5",
    x"F4",x"F4",x"F4",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5",x"F5");

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
