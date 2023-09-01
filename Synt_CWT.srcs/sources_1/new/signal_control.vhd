----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2023 18:23:46
-- Design Name: 
-- Module Name: signal_control - Behavioral
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

entity signal_control is
 generic (
            signal_length: integer:=256;
            morlet_size : integer:=10
            );
 Port ( 
        clk , rst : in std_logic ;
        i_signal_data : in std_logic_vector(7 downto 0);
        i_signal_data_valid : in std_logic ;
        o_signal_data : out std_logic_vector(8*morlet_size-1 downto 0);
        o_signal_data_valid : out std_logic ;
        o_intr : out std_logic ;
        c_intr : in std_logic
        );
end signal_control;

architecture Behavioral of signal_control is
component lineBuffer is
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
end component lineBuffer;

constant num_buff: positive := 8;-- 256 is divisible by 8 and its easy to read all the data at end
constant data_depth  : positive :=  positive(ceil(log2(real(morlet_size+num_buff))));
signal pixelCounter : std_logic_vector(data_depth-1 downto 0);

constant morlet_depth  : positive :=  positive(ceil(log2(real(morlet_size))));
signal rdCounter : std_logic_vector(morlet_depth-1 downto 0);
constant LineBuffer_depth  : positive :=  positive(ceil(log2(real(num_buff))));
signal currentRdLineBuffer : std_logic_vector(LineBuffer_depth-1 downto 0);
signal lineBuffDataValid  : std_logic_vector(num_buff-1 downto 0);
signal lineBuffRdData  : std_logic_vector(num_buff-1 downto 0);
signal rd_line_buffer,delay_rd_line_buffer : std_logic;
--signal totalPixelCounter : std_logic_vector(data_depth-1 downto 0);
type state_type is (IDLE ,RD_BUFFER);-- Define the states
signal rdState : state_type;
--constant full_data_depth  : positive :=  positive(ceil(log2(real(morlet_size+10))));
signal totalPixelCounter : std_logic_vector(data_depth-1 downto 0);

signal sc_i_data : std_logic_vector(7 downto 0);
signal sc_i_data_valid, sc_o_intr ,sc_c_intr :  std_logic ;
signal sc_o_data : std_logic_vector(8*morlet_size-1 downto 0);

type lineBuffer_array is array (natural range <> ) of std_logic_vector(8*morlet_size-1 downto 0);
signal lb_Data:lineBuffer_array(0 to num_buff-1);


begin

        sc_i_data <= i_signal_data;
        sc_i_data_valid <= i_signal_data_valid;
        o_intr <=sc_o_intr ;
        sc_c_intr <= c_intr;
        o_signal_data <= sc_o_data ;
        o_signal_data_valid <= rd_line_buffer;

process(clk)
    begin
        if rising_edge(clk) then
          if rst = '1' then
            totalPixelCounter <= (others => '0');
          elsif sc_i_data_valid = '1' and rd_line_buffer = '0' then
            totalPixelCounter <= totalPixelCounter + '1';
          end if;
           
          if unsigned(totalPixelCounter) = morlet_size+num_buff-1 then
            totalPixelCounter <= (others => '0');
          end if;
        end if;
    end process;


process(clk)
    begin
        if rising_edge(clk) then
          if rst = '1' then
            pixelCounter <= (others => '0');
          elsif  sc_i_data_valid = '1' then
            pixelCounter <= pixelCounter + '1';
          else 
            pixelCounter <= (others => '0');
          end if;
        end if;
  end process; 
    
 process(clk)
 variable  counter : integer ;
 variable check :std_logic:= '0';
    begin
       if rising_edge(clk) then
        if rst = '1' then
            rdState <= IDLE;
            rd_line_buffer <= '0';
            delay_rd_line_buffer <= '0';
            sc_o_intr <= '0';
            check :='0';
            counter := 0;
        else 
            CASE rdState is
                when IDLE =>
                   if unsigned(totalPixelCounter) = morlet_size+num_buff-1 then
                        check := '1';
                   end if;
                    sc_o_intr <= '0';
                   if check = '1' then
                         rd_line_buffer <= '1';
                         delay_rd_line_buffer <= '0';
                         rdState <= RD_BUFFER;
                   end if;
                when RD_BUFFER =>
                        rd_line_buffer <= '0';
                        
                    if sc_c_intr = '1' then
                        counter := counter+1;
                        rdState <= IDLE;
                        if counter = num_buff then
                            sc_o_intr <= '1';
                            check := '0';
                            counter := 0;
                       --     totalPixelCounter <= (others => '0');
                        end if;
                        
                    end if;
            end CASE;
        end if;
       end if;
    end process;
    

process(clk)
    begin
        if rising_edge(clk) then
          if rst = '1' then
            rdCounter <= (others => '0');
          elsif unsigned(rdCounter) < morlet_size and sc_i_data_valid = '1' then
            rdCounter <= rdCounter + '1';
          elsif sc_i_data_valid = '0' then
            rdCounter <=(others => '0');
          end if;
          
        end if;
    end process; 
    
     
 process(clk)
     begin
       if rising_edge(clk) then
           if unsigned(rdCounter) < morlet_size and sc_i_data_valid = '1' then
            lineBuffDataValid(0) <= '1';
           else
            lineBuffDataValid(0) <= '0';
           end if;
        for i in 1 to num_buff-1 loop
            lineBuffDataValid(i) <= lineBuffDataValid(i-1);
        end loop;
       end if;  
    end process;
    
--------------------------------------------
 process(clk)
    begin
        if rising_edge(clk) then
          if rst = '1' then
            currentRdLineBuffer <=(others => '0');
          elsif unsigned(currentRdLineBuffer) = num_buff-1 and rd_line_buffer = '1' then
            currentRdLineBuffer <=(others => '0'); 
          elsif rd_line_buffer = '1' then
            currentRdLineBuffer <= currentRdLineBuffer + '1';
          end if;
        end if;
    end process;
--------------------------------------    
process(lb_Data,currentRdLineBuffer)
    variable index : integer;
    begin
        index := to_integer(unsigned(currentRdLineBuffer));
        sc_o_data <= lb_Data(index);
    end process;   
    
 
  
  process(rd_line_buffer,currentRdLineBuffer)
    variable index : integer;
    begin
        if rd_line_buffer = '1' then
            lineBuffRdData <= (others=>'0');
            index := to_integer(unsigned(currentRdLineBuffer));
            lineBuffRdData(index) <= rd_line_buffer;
        else
            lineBuffRdData <= (others=>'0'); -- or any other default value
        end if;
        
    end process;

 lb: for j in 0 to num_buff-1 generate
   linebuff:  lineBuffer 
     generic map(
        pixel_width => morlet_size ,
        kernel_size => morlet_size 
        )
  Port map( 
        clk=> clk, rst => rst,
        i_data => sc_i_data,
        i_data_valid => lineBuffDataValid(j),
        o_data => lb_Data(j),
        i_rd_data => lineBuffRdData(j));
end generate lb;        
  
end Behavioral;
