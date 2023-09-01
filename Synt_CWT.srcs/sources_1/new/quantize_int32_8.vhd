----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.08.2023 13:23:35
-- Design Name: 
-- Module Name: quantize_int32_8 - Behavioral
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

--use work.fixed_pkg.all;

entity quantize_int32_8 is
 generic (
        data_length : integer := 256
        );
    port (
        input : in std_logic_vector(31 downto 0); -- 32-bit input
        output : out std_logic_vector(7 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        enable : in std_logic;
        out_en : out std_logic
    );
end quantize_int32_8;

architecture Behavioral of quantize_int32_8 is
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

--function Divide(N : signed(31 downto 0); D : signed(31 downto 0)) return signed is                                                                                                                    
--    variable Q : signed(31 downto 0) := to_signed(0, 32);                                                      
--    variable R : signed(31 downto 0) := to_signed(0, 32);                                                        
--    constant N_Abs : signed(31 downto 0) := abs(N);                                                             
--    constant D_Abs : signed(31 downto 0) := abs(D);                                                             
--  begin                                                                                                          
--    -- behaviour                                                                                                 
--    for i in N_Abs'high downto 0 loop                                                                            
--      R := shift_left(R, 1);                                                                                     
--      R(0) := N_Abs(i);                                                                                          
--      if R >= D_Abs then                                                                                         
--        R := R - D;                                                                                              
--        Q(i) := '1';                                                                                             
--      end if;                                                                                                    
--    end loop;                                                                                                    

--    if ((N < 0 and D > 0) or (N > 0 and D < 0)) then                                                             
--      return -Q;                                                                                                 
--    else                                                                                                         
--      return Q;                                                                                                  
--    end if;                                                                                                      
--  end function;


    constant mem_addressWidth  : positive :=  positive(ceil(log2(real(data_length))));
    
attribute DONT_TOUCH : boolean;  -- Declare the attribute
    type state_type is (idle,min_max,scale_calc,zero_point_calc,zero_point_done,out_data);-- Define the states
   --sub_done,scale_div ,div_done ,mult_done ,zero_point_done ,out_mult_done ,out_data,add_done 
   
    signal state : state_type;
    signal count : integer range 0 to data_length+1;
-- Maximum and minimum values allowed
--    constant MAX_VALUE : integer := 127;
--    constant MIN_VALUE : signed := to_signed(-128,8);
    signal wr_addr, r_addr: std_logic_vector(mem_addressWidth-1 downto 0);
    signal q_ren,en,w_en,o_valid : std_logic ;
    signal q32_o,w_in,i_data : std_logic_vector(31 downto 0);
    signal final_out:  std_logic_vector(7 downto 0);
    
    signal scale : std_logic_vector(31 downto 0):= (others=>'0');
    signal zero_point : std_logic_vector(7 downto 0);
      
    signal max_input:signed(31 downto 0) := to_signed(-2**31, 32); -- initialize to lowest possible value
    signal min_input: signed(31 downto 0) := to_signed(2**31-1, 32);-- initialize to highest possible value
   signal temp_output : std_logic_vector(7 downto 0):=(others=> '0');
    signal reg_intermediate_sub: signed(31 downto 0):=(others=> '0');
    signal reg_intermediate_div : signed(31 downto 0):=(others=> '0');
    signal reg_mult_input, temp_mult : signed(31 downto 0):=(others=> '0');
     signal scale_cnt, zero_cnt, out_cnt: std_logic_vector(2 downto 0);
    signal temp_data : signed(31 downto 0):=(others=> '0');
    signal q_min ,reg_mult: signed(15 downto 0);
    signal temp_add, temp_zeroScale,reg_zero_sub: signed(31 downto 0):=(others=> '0');
--    signal i,j,k : integer:=0;
    signal sum : signed(16 downto 0);
--    signal max_c, min_c ,scale_c: std_logic_vector(31 downto 0);
    attribute DONT_TOUCH of  scale, max_input, min_input,zero_point,o_valid, state,scale_cnt,reg_intermediate_sub, reg_intermediate_div,q_ren,q32_o: signal is TRUE; 
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
    if rst = '1' or state = idle then
        wr_addr <= (others=> '0');
    elsif rising_edge(clk) and en = '1' and unsigned(wr_addr)< data_length-1 then
        wr_addr <= wr_addr + '1';
    end if;
    
end process;


process(clk,rst)
begin
    if rst = '1' then
        count <= 0;
    elsif rising_edge(clk) then
        if  w_en = '1' or state = out_data then
            count <= count +1;
        elsif count = data_length+3 or state = scale_calc then
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
    if rst = '1' or (count = data_length and  state= out_data) then
        q_ren <=  '0';
    elsif rising_edge(clk) and state = zero_point_calc and zero_cnt=1 then
        q_ren <=  '1';
    end if;
end process;


 q_mem: input_mem
    generic map(
        numWeight  =>data_length ,
        addressWidth => mem_addressWidth,
        dataWidth =>32)
    port map( 
        clk =>clk , wen=>en , ren =>q_ren,
        wadd=> wr_addr, radd => r_addr,
        xin => w_in,
        xout => q32_o );
------------------------------------ 

quan_calc:  process (clk, rst)
--   variable Q1 : signed(31 downto 0) := to_signed(0, 32);                                                      
--    variable R1 : signed(31 downto 0) := to_signed(0, 32);                                                        
    variable reg : signed(15 downto 0) ;  
    variable cnt,c: integer;                                                           
--    variable D1_Abs : signed(31 downto 0) := to_signed(255, 32); 
   begin
   if rising_edge(clk) then
     if rst = '1' then
            state <= idle;
     else
          CASE state is  
            when idle =>
--                count <= 0;
                state <= min_max;
                o_valid <= '0';
                 scale_cnt <= "000";
                 zero_cnt<= "000";
                  out_cnt<= "000";
                  cnt := 0;
                --  i<=0;
            when min_max =>
               if w_en = '1' then
                   if signed(i_data) > max_input then
                        max_input <= signed(i_data);
                   end if;
                   if signed(i_data) < min_input then
                        min_input <= signed(i_data);
                   end if;
                     
               elsif count = data_length then
                        state <= scale_calc;     
                        if max_input(31) = '1' then
                            max_input <= (others=> '0');
                        end if;
                        
                        if min_input(31) = '0' then
                            min_input <= (others=> '0');
                        end if;   
               end if;
            
             when scale_calc =>
--                data_min:=to_sfixed(std_logic_vector(min_input),31,0);
--                data_max:=to_sfixed(std_logic_vector(max_input),31,0);
                reg_intermediate_sub <= resize(max_input -min_input,32) ;--cc0
                reg_intermediate_div <= to_signed(to_integer(signed(reg_intermediate_sub) / to_signed(255,32)), 32);
                --Divide(reg_intermediate_sub,to_signed(255,32));--cc1
               -- scale <= std_logic_vector(reg_intermediate_div);--cc2
                if unsigned(scale_cnt) <2 then
                    scale_cnt <= scale_cnt+1;
                else 
                 scale <= std_logic_vector(reg_intermediate_div);
                 state <= zero_point_calc;
                 scale_cnt<= "000";
                end if;
                 
--            when scale_calc => 
--                scale <=  resize(to_sfixed(255,9,0)/resize(to_sfixed(max_input,31,0) - to_sfixed(min_input,31,0),32,0),3,-28);
--                state <= zero_point_calc;
                 
            when zero_point_calc =>
                reg_mult_input <= to_signed(to_integer(signed(min_input) / signed(scale)), 32);--cc0
                if unsigned(scale_cnt) <2 then
                    scale_cnt <= scale_cnt+1;
                    reg_mult <= not reg_mult_input(15 downto 0);
                else 
                 
                 state <=zero_point_done;
                 scale_cnt<= "000";
                 q_min <= to_signed(-128,16);
                end if;
                
            when zero_point_done=>
                --reg_mult<=to_signed(-27,32);--cc0
                reg := reg_mult;
                --cnt := TO_INTEGER(reg);
               -- reg_zero_sub <= resize(signed(q_min)- signed(reg_mult),32);----to_signed(-127,32)-to_signed(-27,32),32);--reg_mult_input,32);--cc1

--                zero_point <= to_slv(resize(to_sfixed(MIN_VALUE,7,0)- resize(to_sfixed(min_input,32,0)*scale,9,0),7,0));
                if unsigned(zero_cnt) =1 then
                    sum <= ('0' & q_min) + ('0' & to_signed(reg,16)) + "1";
                elsif unsigned(zero_cnt) =3 then 
                    state <= out_data;
                    zero_point <= std_logic_vector(sum(7 downto 0));
                end if;
                
            when out_data  =>
                --temp_data <=signed(q32_o);--cc0
                --temp_mult <= to_signed(to_integer(signed(q32_o) / signed(scale)), 32);--cc1
               -- temp_mult<=Divide( temp_data , signed(scale));--cc1
                temp_zeroScale<= resize(signed(zero_point),32);--cc2
                temp_add <= resize(to_signed(-27,32)+temp_zeroScale,32);--cc3
                temp_output <= std_logic_vector(resize(temp_add,8));--cc4
--                temp_output := to_slv(resize(resize((to_sfixed(q32_o,31, 0) * scale),9,0) + to_sfixed(zero_point,7,0),7,0));
                if unsigned(out_cnt) <4 then
                    out_cnt <= out_cnt+1;
                else 
                     o_valid <= '1';
                    final_out<= temp_output;
                     if count = data_length+3 then
                        state <= idle;
                     end if;
                end if;
                
           end case;
     end if;
    end if;
    end process;     

end Behavioral;
