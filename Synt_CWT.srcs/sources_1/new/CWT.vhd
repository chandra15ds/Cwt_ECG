----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.08.2023 18:34:14
-- Design Name: 
-- Module Name: CWT - Behavioral
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

entity CWT is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24 -- total number of scale
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0);
        cwt_intr: out std_logic 
         );
end CWT;

architecture Behavioral of CWT is
--component quantize_int8 is
--    generic (
--        data_length : integer := 256;
--        data_in_bits : integer := 16;
--        fractionlength : integer := 11
--        );
--    port (
--        input : in std_logic_vector(data_in_bits-1 downto 0); -- 32-bit input
--        output : out std_logic_vector(7 downto 0);
--        clk : in std_logic;
--        rst : in std_logic;
--        enable : in std_logic;
--        out_en : out std_logic
--    );
-- end component ;
----------------------------------------------------------- 
 component signal_storage_01 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=10
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_02 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=20
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_03 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=30
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_04 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=40
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_05 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=50
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_06 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=10
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_07 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=10
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

 component signal_storage_08 is
generic (
            data_length: positive :=256;---length or width of the data
            cwt_width :natural :=24;
            address_width: positive :=16;
            morlet_size: positive:=10
            );
     Port (
        i_clk , i_rst : in std_logic ;
        --slave interface
        i_data_valid : in std_logic ;
        i_data : in std_logic_vector(7 downto 0);
        --master interface
        o_data_valid : out std_logic ;
        o_data : out std_logic_vector(31 downto 0)
         );
end component ;

-- component signal_storage_09 is
--generic (
--            data_length: positive :=256;---length or width of the data
--            cwt_width :natural :=24;
--            address_width: positive :=16;
--            morlet_size: positive:=10
--            );
--     Port (
--        i_clk , i_rst : in std_logic ;
--        --slave interface
--        i_data_valid : in std_logic ;
--        i_data : in std_logic_vector(7 downto 0);
--        --master interface
--        o_data_valid : out std_logic ;
--        o_data : out std_logic_vector(31 downto 0)
--         );
--end component ;

-- component signal_storage_10 is
--generic (
--            data_length: positive :=256;---length or width of the data
--            cwt_width :natural :=24;
--            address_width: positive :=16;
--            morlet_size: positive:=10
--            );
--     Port (
--        i_clk , i_rst : in std_logic ;
--        --slave interface
--        i_data_valid : in std_logic ;
--        i_data : in std_logic_vector(7 downto 0);
--        --master interface
--        o_data_valid : out std_logic ;
--        o_data : out std_logic_vector(31 downto 0)
--         );
--end component ;

-- component signal_storage_11 is
--generic (
--            data_length: positive :=256;---length or width of the data
--            cwt_width :natural :=24;
--            address_width: positive :=16;
--            morlet_size: positive:=10
--            );
--     Port (
--        i_clk , i_rst : in std_logic ;
--        --slave interface
--        i_data_valid : in std_logic ;
--        i_data : in std_logic_vector(7 downto 0);
--        --master interface
--        o_data_valid : out std_logic ;
--        o_data : out std_logic_vector(31 downto 0)
--         );
--end component ;

-- component signal_storage_12 is
--generic (
--            data_length: positive :=256;---length or width of the data
--            cwt_width :natural :=24;
--            address_width: positive :=16;
--            morlet_size: positive:=10
--            );
--     Port (
--        i_clk , i_rst : in std_logic ;
--        --slave interface
--        i_data_valid : in std_logic ;
--        i_data : in std_logic_vector(7 downto 0);
--        --master interface
--        o_data_valid : out std_logic ;
--        o_data : out std_logic_vector(31 downto 0)
--         );
--end component ;

 --------------------------------------------------------
--component quantize_int32_8 is
-- generic (
--        data_length : integer := 256
--        );
--    port (
--        input : in std_logic_vector(31 downto 0); -- 32-bit input
--        output : out std_logic_vector(7 downto 0);
--        clk : in std_logic;
--        rst : in std_logic;
--        enable : in std_logic;
--        out_en : out std_logic
--    );
--end component;
-------------------
component input_mem is
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
end component ;
-- Declare the array type for addressWidth
type AddressWidthArray is array(1 to CWT_WIDTH) of positive;

  -- Generate the constants using a loop
  function generate_constants(n: natural; width: positive; offset: natural)
    return AddressWidthArray is
    variable constants: AddressWidthArray;
  begin
    for i in 1 to n loop
      constants(i) := positive(ceil(log2(real(width + i * offset))));
    end loop;
    return constants;
  end generate_constants;
  
attribute DONT_TOUCH : boolean;  -- Declare the attribute
constant addressWidth: AddressWidthArray := generate_constants(CWT_WIDTH, DATA_LENGTH, 10);
constant mem_addressWidth  : positive :=  positive(ceil(log2(real(data_length))));
 signal  q_in_valid, cwt_in_valid: std_logic ;
 signal  q_in : std_logic_vector(7 downto 0);
 signal cwt_in: std_logic_vector(7 downto 0);
 
-- signal quan_out_valid: std_logic ;
--signal quan_out : std_logic_vector(7 downto 0);

-- attribute DONT_TOUCH of  cwt_out_valid: signal is TRUE; 
signal final_out : std_logic_vector(31 downto 0);
type state_type is (IDLE, READ_ARRAY, READ_ELEMENT);
signal state : state_type := IDLE;

type address_array is array(1 to CWT_WIDTH) of std_logic_vector(mem_addressWidth-1 downto 0);
signal coeff_wadd, coeff_radd: address_array;

type cwt_conv_data_array is array(1 to CWT_WIDTH) of std_logic_vector(31 downto 0);
type quan_data_array is array(1 to CWT_WIDTH) of std_logic_vector(7 downto 0);
type cwt_conv_valid_array is array(1 to CWT_WIDTH) of std_logic;
signal cwt_conv_data,coeff_out : cwt_conv_data_array;
signal q32_out : quan_data_array;
signal cwt_conv_data_valid, q32_o_valid, coeff_ren : cwt_conv_valid_array ;

signal data_ready, final_o_valid: std_logic;
--constant total_end_output: positive:=CWT_WIDTH*data_length;

signal current_mem : integer := 0;
signal current_element : integer := 0;
   
begin
q_in_valid<= i_data_valid;
q_in <= i_data;
o_data  <= final_out ;
o_data_valid <= final_o_valid;
cwt_intr <= data_ready;

-- quan:quantize_int8 
--    generic map(
--        data_length => data_length,
--        data_in_bits => data_in_bits ,
--        fractionlength =>fractionlength
--        )
--    port map(
--        input  =>  q_in,
--        output  => quan_out,
--        clk  => i_clk,
--        rst  => i_rst,
--        enable  => q_in_valid,
--        out_en  => quan_out_valid
--    );
------------------------------------------------------
s1: signal_storage_01 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(1),
            morlet_size =>10
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(1),
        o_data => cwt_conv_data(1)
         );
 
 s2: signal_storage_02 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(2),
            morlet_size =>20
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(2),
        o_data => cwt_conv_data(2)
         );         
 
 s3: signal_storage_03 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(3),
            morlet_size =>30
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(3),
        o_data => cwt_conv_data(3)
         );        
         
s4: signal_storage_04 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(4),
            morlet_size =>40
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(4),
        o_data => cwt_conv_data(4)
         );

s5: signal_storage_05 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(5),
            morlet_size =>50
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(5),
        o_data => cwt_conv_data(5)
         );
         
s6: signal_storage_06 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(6),
            morlet_size =>60
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(6),
        o_data => cwt_conv_data(6)
         );
         
s7: signal_storage_07 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(7),
            morlet_size =>70
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(7),
        o_data => cwt_conv_data(7)
         );

s8: signal_storage_08 
generic map(
            data_length => data_length,
            cwt_width => cwt_width,
            address_width => addressWidth(8),
            morlet_size =>80
            
            )
     Port map(
        i_clk => i_clk, i_rst => i_rst,
        i_data_valid =>q_in_valid,
        i_data => q_in,
        o_data_valid => cwt_conv_data_valid(8),
        o_data => cwt_conv_data(8)
         );         
 
-- s9: signal_storage_09 
--generic map(
--            data_length => data_length,
--            cwt_width => cwt_width,
--            address_width => addressWidth(9),
--            morlet_size =>90
            
--            )
--     Port map(
--        i_clk => i_clk, i_rst => i_rst,
--        i_data_valid =>quan_out_valid,
--        i_data => quan_out,
--        o_data_valid => cwt_conv_data_valid(9),
--        o_data => cwt_conv_data(9)
--         );        
         
--s10: signal_storage_10
--generic map(
--            data_length => data_length,
--            cwt_width => cwt_width,
--            address_width => addressWidth(10),
--            morlet_size =>100
            
--            )
--     Port map(
--        i_clk => i_clk, i_rst => i_rst,
--        i_data_valid =>quan_out_valid,
--        i_data => quan_out,
--        o_data_valid => cwt_conv_data_valid(10),
--        o_data => cwt_conv_data(10)
--         );

--s11: signal_storage_11 
--generic map(
--            data_length => data_length,
--            cwt_width => cwt_width,
--            address_width => addressWidth(11),
--            morlet_size =>110
            
--            )
--     Port map(
--        i_clk => i_clk, i_rst => i_rst,
--        i_data_valid =>quan_out_valid,
--        i_data => quan_out,
--        o_data_valid => cwt_conv_data_valid(11),
--        o_data => cwt_conv_data(11)
--         );
         
--s12: signal_storage_12 
--generic map(
--            data_length => data_length,
--            cwt_width => cwt_width,
--            address_width => addressWidth(12),
--            morlet_size =>120
            
--            )
--     Port map(
--        i_clk => i_clk, i_rst => i_rst,
--        i_data_valid =>quan_out_valid,
--        i_data => quan_out,
--        o_data_valid => cwt_conv_data_valid(12),
--        o_data => cwt_conv_data(12)
--         );
         
 ------------------------------------------------------
 ----converting product of input int8 and morlet int8 that is int32 to int8
--quant:for n in 1 to cwt_width generate 
--q: quantize_int32_8 
--    generic map(
--        data_length => data_length
--        )
--    port map(
--        input  =>  cwt_conv_data(1),
--        output  => q32_out(1),
--        clk  => i_clk,
--        rst  => i_rst,
--        enable  => cwt_conv_data_valid(1),
--        out_en  => q32_o_valid(1)
--    );
-- end generate quant;
------------------------------------
--------------------------- 
coeff_mem: for j in 1 to cwt_width generate
m: input_mem
    generic map(
        numWeight  =>data_length ,
        addressWidth => mem_addressWidth,
        dataWidth =>32)
    port map( 
        clk =>i_clk , wen=>cwt_conv_data_valid(j),--q32_o_valid(j) ,
         ren =>coeff_ren(j),
        wadd=> coeff_wadd(j), 
        radd => coeff_radd(j),
        xin => cwt_conv_data(j),--q32_out(j),
        xout => coeff_out(j) );
end generate coeff_mem;   
-------------------------------------------------
coef_wr:process(i_clk,i_rst)
begin
    if i_rst = '1' then
        coeff_wadd <= (others=> (others=> '0'));
        data_ready <= '0';
    elsif rising_edge(i_clk) then
      for i in 1 to cwt_width loop
       -- if  q32_o_valid(i) = '1' and unsigned(coeff_wadd(i))<data_length-1 then
        if  cwt_conv_data_valid(i) = '1' and unsigned(coeff_wadd(i))<data_length-1 then
            coeff_wadd(i) <= coeff_wadd(i) + '1';
        end if;
      end loop;
        if unsigned(coeff_wadd(cwt_width)) = data_length-2 then
            data_ready <= '1';
        else 
            data_ready <= '0';
        end if;
    end if; 
end process;
--------
coef_rd: process(i_clk,i_rst)
begin
    if i_rst = '1' then
        state <= IDLE;
    elsif rising_edge(i_clk) then
        case state is
            when IDLE =>
                
                coeff_ren <= (others => '0');
                coeff_radd <= (others => (others => '0'));
                current_element <= 0;
                current_mem <= 1;
                final_o_valid <= '0';
                if data_ready = '1' and current_mem <= cwt_width then
                        state <= READ_ARRAY;
                end if;
                
            when READ_ARRAY =>
                if current_mem <= cwt_width then
                    coeff_ren(current_mem) <= '1';
                    coeff_radd(current_mem) <= std_logic_vector(to_unsigned(0, mem_addressWidth));
                    state <= READ_ELEMENT;
                else
                    state <= IDLE;
                end if;
                
            when READ_ELEMENT =>
                final_out <= coeff_out(current_mem);
                if current_element = 1 then
                    final_o_valid <= '1';
                end if;
                
                if coeff_radd(current_mem) = std_logic_vector(to_unsigned(data_length-1, mem_addressWidth)) then
                    coeff_ren(current_mem) <= '0';
                   -- current_mem <= current_mem + 1;
                    if current_element = data_length + 1 then
                        current_mem <= current_mem + 1;
                          if current_mem <= cwt_width then
                            state <= READ_ARRAY;
                            final_o_valid <= '0';
                            current_element<=0;
                          end if;
                     else 
                        current_element <= current_element + 1;
                     end if;
                else
                    coeff_radd(current_mem) <= coeff_radd(current_mem) + 1;
                    current_element <= current_element + 1;
                end if;
        end case;
    end if;
end process;
end Behavioral;
