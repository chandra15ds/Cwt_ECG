----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2023 16:51:55
-- Design Name: 
-- Module Name: Morlet_s9 - Behavioral
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

entity Morlet_s9 is
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
end Morlet_s9;

architecture Behavioral of Morlet_s9 is
type ram_type is array (0 to 89) of std_logic_vector(7 downto 0);
shared variable RAM : ram_type := (x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",
    x"F6",x"F6",x"F6",x"F5",x"F5",x"F5",x"F5",x"F6",x"F8",x"FA",x"FC",x"FD",x"FA",x"F4",x"EB",x"E1",x"DC",
    x"E0",x"EE",x"06",x"21",x"35",x"37",x"22",x"F7",x"C2",x"94",x"80",x"91",x"C6",x"0F",x"55",x"7F",x"7F",
    x"55",x"0F",x"C6",x"91",x"80",x"94",x"C2",x"F7",x"22",x"37",x"35",x"21",x"06",x"EE",x"E0",x"DC",x"E1",
    x"EB",x"F4",x"FA",x"FD",x"FC",x"FA",x"F8",x"F6",x"F5",x"F5",x"F5",x"F5",x"F6",x"F6",x"F6",x"F6",x"F6",
    x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6",x"F6");
    
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
