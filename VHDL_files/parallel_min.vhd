--Basic block for the computation of the minimum value among m+1 values
--It is based on 2D structure of (m+1)x(m+1) comparators
--By John Kalomiros, International hellenic University
--Date: February 2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;
------------------------------------
entity parallel_min is
generic(m: positive);
	port(cost	 	 : in OneD_std(0 to m); --10 bits
		  min_out	 : out std_logic_vector(N+1 downto 0));
end parallel_min;		  

architecture fast of parallel_min is

signal res: OneD_array_bit(0 to m);
signal a: OneD_uns(0 to m);

begin

g0: for i in 0 to m generate
		a(i) <= unsigned(cost(i));
end generate g0;		
		

g1: for i in 0 to m generate
g2:		for j in 0 to m generate
				res(i)(j) <= '1' when a(i) <= a(j) else '0';
			end generate g2;
	 end generate g1;

p1: process(res)
	 variable  alpha: bit_array;
	 begin
	 
l1:for i in 0 to m loop
		alpha(i) := res(i)(0);
l2:	for j in 1 to m loop
			alpha(i) := res(i)(j) AND alpha(i);
		end loop l2;	
	 end loop l1;	

	 min_out <= (OTHERS => 'X');
	 
	 for i in 0 to m loop
		 if alpha(i) = '1' then
			 min_out <= std_logic_vector(a(i));
		 exit;
		 end if;
	 end loop;

	 end process p1; 

end fast;				










