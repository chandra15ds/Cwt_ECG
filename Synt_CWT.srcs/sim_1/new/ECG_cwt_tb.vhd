library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use std.textio.all;
use ieee.std_logic_textio.all; 

entity ECG_cwt_tb is
end;

architecture bench of ECG_cwt_tb is

  component ECG_cwt
      Port ( clk, rst: in std_logic ;
            input_data : in STD_LOGIC_VECTOR (7 downto 0);
           in_valid, i_data_ready : in STD_LOGIC;
           out_data : out STD_LOGIC_VECTOR (31 downto 0);
           out_valid , o_data_ready: out STD_LOGIC;
           o_intr : out std_logic);
  end component;

  signal clk, rst,i_data_ready,o_data_ready: std_logic;
  signal input_data: STD_LOGIC_VECTOR (7 downto 0);
  signal in_valid: STD_LOGIC;
  signal out_data: STD_LOGIC_VECTOR (31 downto 0);
  signal out_valid,o_intr: STD_LOGIC;
signal cnt: integer;
  constant clock_period: time := 4 ns;
  signal stop_the_clock: boolean;
  
    file read_file : text;
    file write_file : text;

begin

  uut: ECG_cwt port map ( clk        => clk,
                               rst        => rst,
                               i_data_ready => i_data_ready,
                               o_data_ready=> o_data_ready,
                               o_intr => o_intr,
                               input_data => input_data,
                               in_valid   => in_valid,
                               out_data   => out_data,
                               out_valid  => out_valid );

  stimulus: process
     variable line_v : line;
    
    variable slv_v : std_logic_vector(7 downto 0);
    begin
        -- EDIT Adapt initialization as needed
        file_open(read_file, "E:\Master_CMM\Thesis\data\ECG_bin3_3.txt", read_mode);

        in_valid <= '0';
        input_data <= (others => '0');
         
    -- Put initialisation code here

    rst <= '1';
    wait for 15 ns;
    rst <= '0';
     wait for 10 ns;

        in_valid <= '1';
        
        --wait for 10 ns;
        while not endfile(read_file) loop
            readline(read_file, line_v);
            hread(line_v, slv_v);
            input_data <= slv_v;
            wait for 4ns;
        end loop;
    file_close(read_file);
--    wait for 10ns;
    in_valid <= '0';
    wait for 200ns;
--    stop_the_clock <= true;
    wait;
  end process;
  
  write_out_data: process(clk)
    variable line_v: line;
begin
    
--    file_open(write_file, "E:\VHDL\ECG_CWT\OutputData.txt", write_mode);
--    if rising_edge(clk) then
--        if out_valid = '1' then
--            hwrite(line_v,out_data, right, 15);
--            writeline(write_file, line_v);
----            cnt <= cnt +1;
--        end if;
--        if  icnt >3071 then
--            file_close(write_file);
--        endf;
--    end if;
end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  