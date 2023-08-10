--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: top level
--Unrolls 2-input min blocks for the computation of minimum(L(p-r, d), L(p-r, d-1), L(p-r, d+1))
--minimum of path costs corresponding to close disparities

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;

entity compute_min_L is
	port(cost_in: in OneD_std(0 to dmax + 1);
		  clk, clken: in std_logic;
		  min_Lrd: out OneD_std(0 to dmax - 1)); --array of disparities is 0 to dmax - 1
end compute_min_L;

architecture unroll of compute_min_L is
signal s0, s2: OneD_uns(0 to dmax - 1);
signal s3, min_out: OneD_std(0 to dmax - 1);

begin

gen:	for i in 0 to dmax - 1 generate --0 to dmax - 1 generate
			s0(i) <= unsigned(cost_in(i)) + P1;
			s2(i) <= unsigned(cost_in(i + 2)) + P1;
			
L1:		min2 port map(in1 => std_logic_vector(s0(i)), in2 => cost_in(i + 1), min_value => s3(i));
L2:		min2 port map(in1 => s3(i), in2 => std_logic_vector(s2(i)), min_value => min_out(i));	

		end generate gen;
		
min_Lrd <= min_out;
		
		
end unroll;		