--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: top level
--This module is part of a sgm stereo processor. It computes:
--A. the overall minimum value among the d path costs of the previous pixel in the selected direction: minLr(p-r, k) among all k integer diparities
--B. the minimum value among path costs of the previous pixel in the selected direction, with disparities larger than d+1 or lesser then d-1, with d being the current disparity
--It computes  the min cost among d values, then excludes d-2, d-1, d, d+1, d+2 for each d and finds the new min. Min of path costs with far disparities

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;
------------------------------------
entity new12_min_Lr2_64 is
	port(cost: in OneD_std(0 to dmax + 1);
		  mind_pr_out: out std_logic_vector(N+1 downto 0);--overall minimum
		  minLrd_out: out OneD_std(0 to dmax - 1));
end new12_min_Lr2_64;
		  
architecture multiple of new12_min_Lr2_64 is

signal costLr: OneD_std(0 to dmax + 1); 
signal mind_pr1: OneD_std(0 to div - 1); 
signal mind_pr: std_logic_vector(N+1 downto 0); 
signal far_min: std_logic_vector(N+1 downto 0);
signal far_min1: OneD_std(0 to div - 1);
signal minLrd: OneD_std(0 to (dmax - 1));
signal tag_min: natural range 0 to (dmax + 1) + 2;
signal tag: natural range 0 to div;
signal tag_min1: OneD_nat(0 to div - 1);
signal diff1: OneD_nat(0 to (dmax - 1)); 

begin

costLr(0) <= max_cost;
costLr(dmax + 1) <= max_cost;	 
costLr(1 to dmax) <= cost(1 to dmax);
--------------------------------------

--Find minimum disp cost and its tag for the previous step 

g0: for i in 0 to div - 1 generate

inst0: parallel_min_tag generic map((dmax + 1)/div - 1) port map(costLr(i*(dmax + 1)/div + 1 to (i + 1)*(dmax + 1)/div), mind_pr1(i), tag_min1(i)); -- 1 to 16

	end generate g0;


inst1: parallel_min_tag generic map(div - 1) port map(mind_pr1, mind_pr, tag);
			   
tag_min <= tag_min1(tag) + tag*((dmax + 1)/div);


g2: for i in 0 to div - 1 generate

			far_min1(i) <= "0111111111" when i = tag else mind_pr1(i);
			
	 end generate g2;		
						
inst4: 		parallel_min_tag generic map (m => div - 1) port map(values_in => far_min1, min_value => far_min); 
	

g3: for di in 0 to dmax - 1 generate 

		 diff1(di) <= abs(di - tag_min);

		 minLrd(di) <= std_logic_vector(unsigned(far_min) + P2) when diff1(di) < 3 else std_logic_vector(unsigned(mind_pr) + P2);

	 end generate g3;
			 
minLrd_out  <= minLrd;
mind_pr_out <= mind_pr; 

	 
end multiple;
