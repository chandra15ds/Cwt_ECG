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

entity ECG_cwt is
    Port ( clk, rst: in std_logic ;
            input_data : in STD_LOGIC_VECTOR (7 downto 0);
           in_valid, i_data_ready : in STD_LOGIC;
           out_data : out STD_LOGIC_VECTOR (31 downto 0);
           out_valid , o_data_ready: out STD_LOGIC;
           o_intr : out std_logic);
end ECG_cwt;

architecture Behavioral of ECG_cwt is

component CWT is
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
end component ;

 constant data_lg: positive :=256;
 constant cwt_scale: positive :=8;
 constant data_bits: positive :=16;
 constant frac_bits: positive :=12;
--   constant addressWidth  : positive :=  positive(ceil(log2(real(256))));
 signal   w_en , r_en ,com_cwt_valid, i_ready, intr: std_logic ;
 signal  win: std_logic_vector(7 downto 0);
  signal com_cwt_out: std_logic_vector(31 downto 0);
  
begin

process(clk)
begin
if i_data_ready='1' then
    w_en<= in_valid;
    win <= input_data;
    out_data <=com_cwt_out ;
    out_valid <= com_cwt_valid;
    o_data_ready <= com_cwt_valid;
    o_intr <= intr;
end if;
end process;

co_effs: CWT 
generic map(
            data_length=>data_lg,
            cwt_width =>cwt_scale
)
     Port map (
        i_clk =>clk, i_rst =>rst,
        i_data_valid => w_en,
        i_data => win,
        o_data_valid => com_cwt_valid,
        o_data =>com_cwt_out,
        cwt_intr => intr
         );


end Behavioral;
