----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.07.2023 15:13:27
-- Design Name: 
-- Module Name: CWT_convolution - Behavioral
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

entity CWT_convolution_10 is
generic (
            data_length: positive :=256;---length or width of the data
            morlet_size: positive:=10
            );
Port ( 
            i_clk , i_rst: in std_logic;
            i_signal_data : in std_logic_vector(8*morlet_size-1 downto 0);
            i_signal_data_valid : in std_logic ;
            o_conv_data: out std_logic_vector (31 downto 0);
            o_conv_data_valid : out std_logic ;
            c_intr : out std_logic
         );
end CWT_convolution_10;

architecture Behavioral of CWT_convolution_10 is
component  proc_element is
  Port (
    clk, valid: in std_logic ;
    in_a, in_b: in std_logic_vector(7 downto 0);
    in_c : in std_logic_vector(31 downto 0);
    out_a, out_b : out std_logic_vector(7 downto 0);
    out_c : out std_logic_vector(31 downto 0) );
end component proc_element;
--component wavelet_s10_wrapper is
--  port (
--    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
--    BRAM_PORTA_0_clk : in STD_LOGIC;
--    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    BRAM_PORTA_0_en : in STD_LOGIC;
--    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
--    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
--    BRAM_PORTB_0_clk : in STD_LOGIC;
--    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
--    BRAM_PORTB_0_en : in STD_LOGIC
--  );
--end component;
component Morlet_s10 is
  port (
 clk : in std_logic;
    ena : in std_logic;
    enb : in std_logic;
    wea : in std_logic;
    addra : in std_logic_vector(6 downto 0);
    addrb : in std_logic_vector(6 downto 0);
    dia : in std_logic_vector(7 downto 0);
    dob : out std_logic_vector(7 downto 0)
  );
end component;

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
end component input_mem;

  constant addressWidth  : positive :=  positive(ceil(log2(real(morlet_size))));
   --constant output_width : positive := data_length-morlet_size+1;
--   type data_array_type is array (0 to morlet_size-1) of std_logic_vector(7 downto 0);
--   signal total_data_array : data_array_type;--total_data_array_type
   signal input_p: std_logic_vector(7 downto 0);
   
   
   signal result: std_logic_vector(31 downto 0):=(others=>'0');
   signal valid_input : std_logic :=  '0';
   signal   wen , ren : std_logic ;
   type state_type is (Idle,RD_INPUT,OPERATION);-- Define the states
   signal State : state_type;
   signal wr_addr,r_addr ,wr_addrx,addrx: std_logic_vector(addressWidth-1 downto 0);
   signal morlet_out,morlet_out1, win,i_xin: std_logic_vector(7 downto 0);
   signal count1: integer;
   signal i_cc_valid, i_wen: std_logic;
   signal i_cc_data : std_logic_vector(8*morlet_size-1 downto 0);
   signal o_cc_data:  std_logic_vector (31 downto 0);
   signal o_cc_valid, intr :  std_logic ;
    
begin

--i_cc_data <= i_signal_data;
i_cc_valid <= i_signal_data_valid;
o_conv_data <= o_cc_data;
o_conv_data_valid <= o_cc_valid;
c_intr <= intr;

process (i_clk,i_rst)

variable data_in: std_logic_vector(7 downto 0);
    begin
        if i_rst= '1' then
            State <= Idle;
        elsif rising_edge(i_clk) then             
        
        case State is
            When Idle =>
              count1 <= 0;
              intr <= '0';
              o_cc_valid <= '0';
              valid_input <= '0';
              ren <= '0';  
              r_addr <= (others => '0');
              wr_addrx <= (others => '0');
                 addrx <= (others => '0');
             if  i_cc_valid = '1' then
                i_wen <= '1';
                 i_cc_data <= i_signal_data;
                 State <= RD_INPUT;
             end if;
            When RD_INPUT=>
                 if i_wen = '1' then
                    -- Write logic
                    if unsigned(wr_addrx) < morlet_size - 1 then
                    data_in := i_cc_data(to_integer(unsigned(addrx))* 8 + 7 downto to_integer(unsigned(addrx))* 8);
                    end if;
                    i_xin <= data_in;
                   -- i_xin <= i_data_chunk(7 downto 0); -- 8-bit chunk to write
                    if unsigned(addrx) > 0 then
                        wr_addrx <= wr_addrx + '1';
                    end if;
                    addrx <= addrx + '1';
                    if unsigned(wr_addrx) = morlet_size - 1 then
                        i_wen <= '0';
                        State <= OPERATION;
                        ren <= '1';
                    end if;
                end if;
                     
            When OPERATION=>
                     if ren <='1' and unsigned(r_addr)< morlet_size-1 then
                        r_addr <= r_addr + '1';
                     else
                        ren <= '0';  
                     end if;  
--                -----------------------------
                    if count1<= morlet_size then
                        count1<= count1 + 1;
                    else
                        o_cc_valid <= '1';
                        o_cc_data <= result;
                        intr <= '1';
                        State <= Idle;
                    end if;
--               ---------------------------------------------------

                  if count1 = 0 then
                     valid_input<= '1';
                  elsif count1 = morlet_size then
                     valid_input <= '0';
                  end if;
                  
--                    if count1< morlet_size then
--                      input_p<= total_data_array(count1);--(n)(rdCount(n));
--                    end if;
--               -----------------------
--                 if count1 = morlet_size+1 then
--                        o_cc_valid <= '1';
--                        o_cc_data <= result;
--                        intr <= '1';
--                        State <= Idle;
--                  end if;
        end case;
      end if;
end process;

wen <= '0';
wr_addr <= (others=> '0');
win <= (others=> '0');


in_mem: input_mem
    generic map(
        numWeight  =>morlet_size,
        addressWidth => addressWidth,
        dataWidth =>8)
    port map( 
        clk =>i_clk , wen=>i_wen , ren =>ren,
        wadd=> wr_addrx, radd => r_addr,
        xin => i_xin,
        xout => input_p );

--morlet_mem: wavelet_s10_wrapper 
--  port map (
--    BRAM_PORTA_0_addr => wr_addr,
--    BRAM_PORTA_0_clk =>i_clk ,
--    BRAM_PORTA_0_din => win,
--    BRAM_PORTA_0_en  => wen,
--    BRAM_PORTA_0_we  => "0",
--    BRAM_PORTB_0_addr=> r_addr,
--    BRAM_PORTB_0_clk =>i_clk ,
--    BRAM_PORTB_0_dout => morlet_out,
--    BRAM_PORTB_0_en =>ren
--  );
  
morlet_mem: Morlet_s10
  port map (
  clk =>i_clk ,
    ena => wen,
    enb =>ren,
    wea => wen,
    addra => wr_addr,
    addrb => r_addr,
    dia  => win,
    dob => morlet_out
  );
 morlet_out1<=  morlet_out;
  process_element0: proc_element 
  Port map (
    clk =>i_clk, valid  =>valid_input ,
    in_b=> morlet_out1, in_a=>input_p, in_c=>result,
    out_b=> open, out_a=> open, out_c =>result );
   
end Behavioral;
