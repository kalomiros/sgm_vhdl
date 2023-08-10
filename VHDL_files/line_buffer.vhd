--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: line_buffer.vhd
--Pixel Buffer of a certain depth

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;

entity line_buffer is

generic(depth: positive:=line_width;
			m: natural := dmax + 1);

port(shiftin: in OneD_std(0 to m);
	  clk, clken, resetn: in std_logic;
	  shiftout: out OneD_std(0 to m));
end line_buffer;	  

architecture shift_line of line_buffer is
begin
	process(clk, resetn)
	variable q: OneD_buffer(0 to depth - 1);
	begin
	if resetn = '0' then
		q:= (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	elsif clk'event AND clk = '1' then
	gen0: if clken ='1' then
				for i in depth - 1 downto 1 loop
					q(i) := q(i-1);
				end loop;
				q(0) := shiftin;
			end if;	
	end if;
	
	shiftout <= q(depth - 1);

	end process;
	
end shift_line;