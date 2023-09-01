----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.08.2023 17:42:07
-- Design Name: 
-- Module Name: quantize_int8 - Behavioral
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
library work;
use work.fixed_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity quantize_int8 is
    generic (
        data_length : integer := 256;
        data_in_bits : integer := 16;
        fractionlength : integer := 11
        );
    port (
        input : in std_logic_vector(data_in_bits-1 downto 0); -- 32-bit input
        output : out std_logic_vector(7 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        out_en : out std_logic
    );
end quantize_int8;

architecture Behavioral of quantize_int8 is
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
    constant mem_addressWidth  : positive :=  positive(ceil(log2(real(data_length))));
    
attribute DONT_TOUCH : boolean;  -- Declare the attribute
    type state_type is (idle,min_max,scale_calc,zero_point_calc,out_data);-- Define the states
    --sub_done,scale_div ,div_done ,mult_done ,zero_point_done ,out_mult_done ,out_data,add_done 
    signal state : state_type;
    signal count : integer range 0 to data_length+1;
-- Maximum and minimum values allowed
    constant MAX_VALUE : integer := 127;
    constant MIN_VALUE : signed := to_signed(-128,8);
    signal wr_addr, r_addr: std_logic_vector(mem_addressWidth-1 downto 0);
    signal q_ren,en,w_en,o_valid : std_logic ;
    signal q_out,w_in,i_data : std_logic_vector(data_in_bits-1 downto 0);
    signal final_out:  std_logic_vector(7 downto 0);
    
--    signal scale : sfixed(11 downto -20);
    signal zero_point : std_logic_vector(7 downto 0);
    signal  max_input:signed(15 downto 0) := to_signed(-2**15, 16); -- initialize to lowest possible value
    signal  min_input: signed(15 downto 0) := to_signed(2**15-1, 16);
    
--    signal max_input:sfixed(data_in_bits-fractionlength-1 downto -fractionlength) :=  ('1' & (data_in_bits-fractionlength-2 downto -fractionlength => '0')); -- initialize to lowest possible value
--    signal min_input: sfixed(data_in_bits-fractionlength-1 downto -fractionlength) :=  ('0' & (data_in_bits-fractionlength-2 downto -fractionlength => '1'));-- initialize to highest possible value
    signal temp_output : std_logic_vector(7 downto 0):=(others=> '0');
    signal reg_sub1,reg_sub2: sfixed(3 downto -12):=(others=> '0');
    signal reg_resize_sub1,reg_resize_sub2: sfixed(8 downto -12):=(others=> '0');
    signal reg_intermediate_div,scale,reg_sub3 : sfixed(12 downto -19):=(others=> '0');
    signal reg_mult_input, temp_mult : sfixed(9 downto 0):=(others=> '0');
    signal q_fixed : sfixed(8 downto -12):=to_sfixed(255,8,-12);
    signal q_min : sfixed(9 downto 0):=to_sfixed(-128,9,0);
    signal temp_data : sfixed(data_in_bits-fractionlength-1 downto -fractionlength):=(others=> '0');
    signal max,min : std_logic_vector(data_in_bits-1 downto 0);
    signal temp_add, temp_zeroScale,reg_zero_sub: sfixed(7 downto 0):=(others=> '0');
    signal scale_cnt, zero_cnt, out_cnt: std_logic_vector(2 downto 0);
    signal  diff: std_logic_vector(15 downto 0);
    attribute DONT_TOUCH of zero_point,scale,state,o_valid, diff, reg_sub1,reg_mult_input: signal is TRUE; 
begin


        w_en <= enable;
        i_data <= input;
        output<= final_out;
        out_en<= o_valid;


process( clk,rst)
begin
    if rising_edge(clk)then
        w_in<=i_data;
    end if;
    
    if rst = '1' then
        en<='0';
    elsif rising_edge(clk)   then
        en<=w_en;
    end if;
end process;

ram_write: process(clk,rst)
begin
    if rst = '1' or en ='0' then
        wr_addr <= (others=> '0');
    elsif rising_edge(clk) and en = '1' and unsigned(wr_addr)< data_length-1 then
        wr_addr <= wr_addr + '1';
    end if;
    
end process;

process(clk,rst)
begin
    if rst = '1' or state = idle then
        o_valid <= '0';
    elsif rising_edge(clk) and state = out_data then
        o_valid <= '1';
    end if;
    
end process;

process(clk,rst)
begin
    if rst = '1' then
        count <= 0;
    elsif rising_edge(clk) then
        if  w_en = '1' or state = out_data then
            count <= count +1;
        else 
            count <= 0;
        end if;
    end if;
    
end process;

--q_ren<=en;
ram_read: process(rst,clk)
begin
    if rst = '1' or state = idle then
        r_addr <= (others=> '0');
    elsif rising_edge(clk) and q_ren =  '1' and unsigned(r_addr)< data_length-1 then
       r_addr <=  r_addr + '1';
    end if;
end process;
 
process(rst,clk)
begin
    if rst = '1' or state = idle then
        q_ren <=  '0';
    elsif rising_edge(clk) and state = zero_point_calc and unsigned(zero_cnt)=4  then
        q_ren <=  '1';
    end if;
end process;


 q_mem: input_mem
    generic map(
        numWeight  =>data_length ,
        addressWidth => mem_addressWidth,
        dataWidth =>data_in_bits)
    port map( 
        clk =>clk , wen=>en , ren =>q_ren,
        wadd=> wr_addr, radd => r_addr,
        xin => w_in,
        xout => q_out );

quan_calc:  process (clk, rst)
--    variable temp_output : std_logic_vector(7 downto 0):=(others=> '0');
--    variable reg_intermediate_sub: sfixed(data_in_bits+1 downto 0):=(others=> '0');
--    variable reg_intermediate_div : sfixed(12 downto -19):=(others=> '0');
--    variable reg_mult_input, temp_mult : sfixed(9 downto 0):=(others=> '0');
--    variable q_fixed : sfixed(8 downto 0):=to_sfixed(255,8,0);
--    variable q_min : sfixed(7 downto 0):=to_sfixed(-128,7,0);
--    VARIABLE temp_data : sfixed(data_in_bits-fractionlength-1 downto -fractionlength):=(others=> '0');
    
--    variable temp_add, temp_zeroScale,reg_zero_sub: sfixed(7 downto 0):=(others=> '0');
   begin
   if rising_edge(clk) then
     if rst = '1' then
            state <= idle;
     else
          CASE state is  
            when idle =>
--                count <= 0;
                state <= min_max;
                scale_cnt <= "000";
                 zero_cnt<= "000";
                  out_cnt<= "000";
                  
            when min_max =>
               if w_en = '1' then
                   if signed(w_in) > max_input then
                        max_input <= signed(w_in);
                    end if;
                   if  signed(w_in) < min_input then
                        min_input <= signed(w_in);
                   end if;
--                     count<= count +1;
                     
               elsif count = data_length then
                    if signed(w_in) > max_input then
                        max_input <= signed(w_in);
                    end if;
                   if  signed(w_in) < min_input then
                        min_input <= signed(w_in);
                   end if;
                   state <= scale_calc;
               else
                    state <= idle;             
               end if;
            when scale_calc =>
                max <= std_logic_vector(max_input);--cc 0
                min <= std_logic_vector(min_input);--cc 0
                diff <= max-min; -- cc1
                reg_sub1 <= to_sfixed(diff,3,-12);--cc2
                reg_resize_sub1 <=resize(reg_sub1,8,-12);--cc3
                reg_intermediate_div <= resize(q_fixed/reg_resize_sub1,12,-19);--cc4
                scale <= reg_intermediate_div;--cc5
                if unsigned(scale_cnt) <5 then
                    scale_cnt <= scale_cnt+1;
                else 
                 state <= zero_point_calc;
                end if;
--                 scale <= resize(to_sfixed(255,9,0)/resize((max_input - min_input),17,0),12,-19);

            when zero_point_calc =>
                reg_sub2 <= to_sfixed(min,3,-12);--cc0
                reg_sub3 <= RESIZE(reg_sub2,12,-19);--cc1
                reg_mult_input <= resize(reg_sub2*scale,9,0);--cc2
                reg_zero_sub <= resize(q_min-reg_mult_input,7,0);--cc3
                zero_point <= to_slv(reg_zero_sub);--cc4
                if unsigned(zero_cnt) <4 then
                    zero_cnt <= zero_cnt+1;
                else 
                    state <= out_data;
                end if;
                 
            when out_data  =>
                temp_data <=to_sfixed(q_out, data_in_bits-fractionlength-1, -fractionlength);
                temp_mult<=resize(( temp_data * scale),9,0);
                temp_zeroScale<= to_sfixed(zero_point,7,0);
                temp_add <= resize(temp_mult+temp_zeroScale,7,0);
                temp_output <= to_slv(temp_add);
                if unsigned(out_cnt) <4 then
                    out_cnt <= out_cnt+1;
                else 
                        if signed(temp_output)> MAX_VALUE then
                        final_out <= std_logic_vector(to_unsigned(MAX_VALUE,8));
                    elsif signed(temp_output)< MIN_VALUE then
                        final_out <= std_logic_vector(MIN_VALUE);
                    else
                        final_out<= temp_output;
                    end if;
                     if count = data_length then
                        state <= idle;
                     end if;
                end if;
                
           end case;
     end if;
    end if;
    end process;
    
end Behavioral;
