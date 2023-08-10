--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: min2.vhd
--Produces the minimum among two values

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;

entity min2 is
	port(in1, in2: in std_logic_vector(N + 1 downto 0);
			min_value: out std_logic_vector(N + 1 downto 0));
end min2;

architecture min_of_two of min2 is
signal in1_uns, in2_uns: unsigned(N + 1 downto 0);
begin

in1_uns <= unsigned(in1);
in2_uns <= unsigned(in2);

min:	process(in1_uns, in2_uns) 
		begin
			if in1_uns < in2_uns then
				min_value <= std_logic_vector(in1_uns);
			else
				min_value <= std_logic_vector(in2_uns);
			end if;
		end process min;

end min_of_two;		
			