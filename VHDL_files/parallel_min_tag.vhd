--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: parallel_min_tag.vhd

--Basic block for the computation of the minimum value among dmax values
--It also produces the index of the minimum value

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;
------------------------------------
entity parallel_min_tag is
generic(m: positive := dmax); 
	port(values_in	 : in OneD_std(0 to m);--in OneD_std(0 to dmax + 1); --10 bits
		  min_value  : out std_logic_vector(N + 1 downto 0);
		  min_index	 : out natural range 0 to 255);
end parallel_min_tag;		  

architecture fast of parallel_min_tag is
type bit_array is array(natural range 0 to m) of std_logic;
type OneD_array_bit is array(natural range <>) of bit_array;
signal a: OneD_uns(0 to m);
begin

l0: for i in 0 to m generate 
			a(i) <= unsigned(values_in(i));
	 end generate l0;		

p1: process(a)
	 variable res: OneD_array_bit(0 to m):= (OTHERS => (OTHERS => '1'));
	 variable alpha: bit_array;
	 variable tag, k: natural range 0 to 255;
	 begin		
	 k := 1;
l1: for i in 0 to m - 1 loop 
l2:		for j in k to m loop 
				if(a(i) < a(j)) then
					res(i)(j) := '1';
					res(j)(i) := '0';
				else
					res(i)(j) := '0';
					res(j)(i) := '1';
				end if;
			end loop l2;
	 k := k + 1;
	 end loop l1;
	 
l3:for i in 0 to m loop
		alpha(i) := res(i)(0);
l4:	for j in 1 to m loop
			alpha(i) := res(i)(j) AND alpha(i);
		end loop l4;
	 end loop l3;	
	 
	 for i in 0 to m loop --0 to m
		 if alpha(i) = '1' then
			 tag := i;
			 exit;
		 else
			 tag := 0;
		 end if;
	 end loop;
		min_index <= tag;
		min_value <= std_logic_vector(a(tag));	
	 end process p1; 

end fast;				










