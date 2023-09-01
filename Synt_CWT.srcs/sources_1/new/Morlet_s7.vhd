----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 16:51:55
-- Design Name: 
-- Module Name: Morlet_s7 - Behavioral
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

entity Morlet_s7 is
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
end Morlet_s7;

architecture Behavioral of Morlet_s7 is
type ram_type is array (0 to 69) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F7",x"F7",x"F7",x"F7",x"F6",
    x"F6",x"F5",x"F6",x"F7",x"FA",x"FD",x"FD",x"F7",x"EC",x"E0",x"DC",x"E9",x"07",x"29",x"3B",x"28",x"F0",
    x"AB",x"80",x"8F",x"D9",x"3B",x"7F",x"7F",x"3B",x"D9",x"8F",x"80",x"AB",x"F0",x"28",x"3B",x"29",x"07",
    x"E9",x"DC",x"E0",x"EC",x"F7",x"FD",x"FD",x"FA",x"F7",x"F6",x"F5",x"F6",x"F6",x"F7",x"F7",x"F7",x"F7",
    x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6");

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
