----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.08.2023 19:11:55
-- Design Name: 
-- Module Name: signal_storage_10 - Behavioral
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

entity signal_storage_10 is
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
end signal_storage_10;

architecture Behavioral of signal_storage_10 is

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
-------------------------
component signal_control is
 generic (
            signal_length: integer:=28;
            morlet_size : integer:=9
            );
 Port ( 
        clk , rst : in std_logic ;
        i_signal_data : in std_logic_vector(7 downto 0);
        i_signal_data_valid : in std_logic ;
        o_signal_data : out std_logic_vector(8*morlet_size-1 downto 0);
        o_signal_data_valid : out std_logic; 
        o_intr : out std_logic ;
        c_intr : in std_logic
        );
end component ;
---------------------------
component  CWT_convolution_10 is
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
end component;
----------------------------------
 signal ss_in_valid, ss_out_valid: std_logic ;
 signal ss_in,s_in_data: std_logic_vector(7 downto 0);
 signal ss_out: std_logic_vector(7 downto 0);
 signal wr_addrx, r_addrx: std_logic_vector(address_width-1 downto 0);
 signal s_ren,en,w_en,o_valid,data_valid : std_logic ;
constant zero_padding : positive := (morlet_size/2);
constant total_input : positive := data_length + morlet_size-1;
constant addressWidth  : positive :=  positive(ceil(log2(real(total_input))));
signal count_intr : unsigned(addressWidth-1 downto 0) := (others => '0');
constant num_init_data,num_intr_data : natural := morlet_size+8-1;
signal signal_data : std_logic_vector(8*morlet_size-1 downto 0);
signal signal_data_valid, intr : std_logic ;
signal c_intr, cnv_o_valid : std_logic ;
signal cnt_r: integer;
signal cnv_o_data : std_logic_vector(31 downto 0);

type state_type is (INIT, READ_INIT, READ_INTR, IDLE);
signal state : state_type;

begin
--------------------------
ss_in_valid<= i_data_valid;
s_in_data <= i_data;
o_data  <= cnv_o_data ;---signal_data(31 downto 0);--cnv_o_data ;

o_data_valid <= cnv_o_valid ;--signal_data_valid;---cnv_o_valid ; --ss_out_valid;


 q_mem: input_mem
    generic map(
        numWeight  =>data_length + morlet_size-1,
        addressWidth => address_width,
        dataWidth =>8)
    port map( 
        clk =>i_clk , wen=>en , ren =>s_ren,
        wadd=> wr_addrx, radd => r_addrx,
        xin => ss_in,
        xout => ss_out );
        
process( i_clk,i_rst)
begin
    if rising_edge(i_clk)then
        ss_in<=s_in_data;
    end if;
    if i_rst = '1' then
        en<='0';
    elsif rising_edge(i_clk)  then
        en<=ss_in_valid;
    end if;
end process;

ram_write: process(i_clk,i_rst)
begin
    if i_rst = '1'  then
        wr_addrx <= std_logic_vector(to_unsigned(zero_padding-1, wr_addrx'length));
        data_valid <= '0';
    elsif rising_edge(i_clk) then
        
        if en = '1' and unsigned(wr_addrx)< data_length+zero_padding-1 then
            wr_addrx <= wr_addrx + '1';          
        end if;
        
        if unsigned(wr_addrx) = num_init_data then
           data_valid <= '1';
        elsif unsigned(r_addrx) = total_input-1 then
            data_valid <= '0';
        end if;
    end if;
end process;

--ram_read: process(i_rst,i_clk)
--begin
--    if i_rst = '1'  then
--        s_ren <=  '0';
--    elsif rising_edge(i_clk) and  unsigned(wr_addrx) = data_length+zero_padding-1 then
----       r_addrx <=  r_addrx + '1';
--        s_ren <=  '1';
--    end if;
--    if i_rst = '1'  then
--        r_addrx <= std_logic_vector(to_unsigned(4, r_addrx'length));--(others=> '0');
--    elsif rising_edge(i_clk) and s_ren =  '1' and unsigned(r_addrx)< total_input-2 then
----       r_addrx <=  r_addrx + '1';
--    end if;
--end process;

ram_read:process(i_clk, i_rst, intr)
begin
    if i_rst = '1' then
        r_addrx <=  (others => '0');
        --count <= 0;
        s_ren <= '0'; 
        state<=  INIT;   
    elsif rising_edge(i_clk) and data_valid= '1' then
        case state is
        
        when  INIT =>
            s_ren <='1';
            state <= READ_INIT;
            
        when READ_INIT=>
            -- Read more initial data
            
            if unsigned(r_addrx) <= num_init_data-1 then
                r_addrx <= r_addrx + '1';
              --  input_valid <= '1';
            else
                s_ren <='0';
                state <= IDLE;
            end if;
            if unsigned(r_addrx) = num_init_data-1 then
                s_ren <='0';
            end if;
        when READ_INTR =>
            -- Read data on interrupt
             if unsigned(r_addrx) <= total_input-2 then
                if count_intr = num_intr_data-1 then
                    s_ren <='0';
                end if;
                
                if count_intr <= num_intr_data-1 then
                  --  input_valid <= '1';
                    r_addrx <= r_addrx + '1';
                    count_intr <= count_intr + 1;
                else   
                    s_ren <='0';
                    state <= IDLE;
                end if;
             else 
                s_ren <='0';
                state <= IDLE;
             end if;
             
             if unsigned(r_addrx) = total_input-1 then
                s_ren <='0';
             end if;
             
        when IDLE =>
            
              if intr = '1' then
              if unsigned(r_addrx) <= total_input-2 then
                r_addrx  <= std_logic_vector(unsigned(r_addrx) - to_unsigned(morlet_size-1, r_addrx'length));
                --negative 8 bcz we have 8 buffers and we have to read previous 8 data again
                count_intr <= (others => '0');
                state <= READ_INTR;
                s_ren <='1';
              end if;
              end if;
            
        end case;
    end if;
    
end process;

SC: signal_control
    generic map (
            signal_length => total_input,
            morlet_size => morlet_size
            )
    Port map ( 
        clk => i_clk, rst => i_rst ,
        i_signal_data => ss_out,
        i_signal_data_valid => s_ren,
        o_signal_data => signal_data,
        o_signal_data_valid => signal_data_valid,
        o_intr => intr,
        c_intr => c_intr
        );
 
cwt_conv:CWT_convolution_10
generic map(
            data_length=> total_input,
            morlet_size=> morlet_size
            )
Port map( 
            i_clk =>i_clk, i_rst=>i_rst,
            i_signal_data => signal_data,
            i_signal_data_valid => signal_data_valid,
            o_conv_data=>cnv_o_data,
            o_conv_data_valid =>cnv_o_valid,
            c_intr =>c_intr
         );


end Behavioral;
