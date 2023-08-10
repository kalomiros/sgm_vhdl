--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: sgm_buf_h.vhd
--Buffers for the horizontal direction of the sgm computation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;

entity sgm_buf_h is
	port(cost_in: in OneD_std(0 to (dmax + 1));
		  clk, clken, resetn: in std_logic;
		  Lh: out OneD_std(0 to dmax + 1)); --array of costs is 0 to dmax + 1
end sgm_buf_h;

architecture all_buffers of sgm_buf_h is
begin


pipe1: process(clk) -- horizontal direction
		begin
			if (rising_edge(clk)) then
				if clken = '1' then 
					Lh <= cost_in;
				end if;
			end if;
		end process pipe1;	
		

end all_buffers;		