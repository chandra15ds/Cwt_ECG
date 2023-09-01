----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.02.2023 13:17:19
-- Design Name: 
-- Module Name: lineBuffer - Behavioral
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
use ieee.math_real.all;
use IEEE.std_logic_signed.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lineBuffer is
   generic(
        pixel_width : integer := 28 ;
        kernel_size : integer := 3
        );
  Port ( 
        clk, rst : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        i_data_valid: in std_logic ;
        o_data : out std_logic_vector(kernel_size*8-1 downto 0);
        i_rd_data : in std_logic );
end lineBuffer;

architecture Behavioral of lineBuffer is

type line_array is array (natural range <> ) of std_logic_vector(7 downto 0);
signal line_buffer : line_array(0 to pixel_width-1) ;--:= (others => (others => '0'));
constant buff_depth  : positive :=  positive(ceil(log2(real(pixel_width))));
--constant rd_depth  : positive :=  positive(ceil(log2(real(pixel_width-2))));
signal wrPntr : std_logic_vector(buff_depth-1 downto 0);
signal rdPntr : std_logic_vector(buff_depth-1 downto 0);
signal i_ln_data: std_logic_vector(7 downto 0);
signal i_ln_data_valid, i_ln_rd_data: std_logic;
signal o_ln_data : std_logic_vector(kernel_size*8-1 downto 0);

begin

        i_ln_data<=i_data;
        i_ln_data_valid<=i_data_valid;
        i_ln_rd_data<=i_rd_data;
        o_data<= o_ln_data;

process(clk)
begin
    if rising_edge(clk) then
        if i_ln_data_valid = '1' then
            line_buffer(to_integer(unsigned(wrPntr))) <= i_ln_data;
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            wrPntr <= (others => '0');
        elsif unsigned(wrPntr) = pixel_width-1 then
            wrPntr <= (others => '0');
        elsif i_ln_data_valid = '1' then
            wrPntr <= wrPntr + '1';
        end if;
    end if;
end process;

process(clk,rdPntr)
begin
    for i in 0 to kernel_size-1 loop
        o_ln_data(i*8+7 downto i*8) <= line_buffer(to_integer(unsigned(rdPntr+i)));
    end loop;
end process;

--o_data <= line_buffer(to_integer(unsigned(rdPntr+2))) & line_buffer(to_integer(unsigned(rdPntr+1))) & line_buffer(to_integer(unsigned(rdPntr)));
        
process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            rdPntr <= (others => '0');
        elsif unsigned(rdPntr) = pixel_width-kernel_size then
            rdPntr <= (others => '0');
        elsif i_ln_rd_data = '1' then
            rdPntr <= rdPntr + '1';
        end if;
    end if;
end process;


end Behavioral;
