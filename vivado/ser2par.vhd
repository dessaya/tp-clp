------------------------------------------------------------------
-- Name		   : ser2par.vhd
-- Description : Serial to parallel converter
-- Designed by : Claudio Avi Chami - FPGA Site
-- Date        : 26/03/2016
-- Version     : 01
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ser2par is
	generic (
		DATA_W		: natural := 8
	);
	port (
		clk: 		in std_logic;
		rst: 		in std_logic;

		-- inputs
		data_in: 	in std_logic;
		frame_in:	in std_logic;
		rd:			in std_logic;

		-- outputs
		data_out:	out std_logic_vector (DATA_W-1 downto 0);
		data_rdy: 	out std_logic

	);
end ser2par;


architecture rtl of ser2par is
	signal reg 		: std_logic_vector (DATA_W-1 downto 0);
	signal frame_s	: std_logic;

begin 

ser2par_pr: process (clk, rst) 
	begin 
    if (rst = '1') then 
        data_out	<= (others => '0');
        reg 		<= (others => '0');
		data_rdy	<= '0';
    elsif (rising_edge(clk)) then
		reg		<= reg(DATA_W-2 downto 0) & data_in;	-- shift data in
		
		if (frame_s = '1') then				-- load parallel register
			data_out	<= reg;
			data_rdy	<= '1';				-- signal host that data is ready
		elsif (rd = '1') then	
			data_rdy	<= '0';				-- data was read, clean ready flag
		end if;	
    end if;
end process;

-- Sample frame_in signal to store received data 
frame_pr: process (clk, rst) 
	begin 
    if (rst = '1') then 
		frame_s	<= '0';
    elsif (rising_edge(clk)) then
		frame_s	<= frame_in;				
    end if;
end process;

end rtl;

