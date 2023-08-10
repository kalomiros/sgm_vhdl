--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: top level
--Adds current cost value C(p, d) with previous path cost value L(p-r, d)
--minus the minimum path cost of the previous pixel in the scanline

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;

entity recursive_path is
	port(cost_in: OneD_std(0 to dmax + 1);
		  clk, clken, resetn: in std_logic;
		  min_in : in OneD_std(0 to dmax - 1); -- 10 bits
		  pr_L_min: in std_logic_vector(N+1 downto 0);--total minimum of previous pixel cost
		  path_cost: out OneD_std(0 to dmax + 1));
end recursive_path;			

architecture pipelining of recursive_path is
signal path_cost_2, path_cost_3, zero_cost: OneD_std(0 to (dmax + 1));
signal cost_signed, min_pr: OneD_signed(0 to (dmax + 1));--signed(N + 2 downto 0):="0000000000"; -- 11 bits
signal pr_min: signed(N + 2 downto 0);
signal path_cost_1: OneD_signed(0 to (dmax + 1));
constant my_zero: std_logic_vector(10 downto 0):= "00000000000";
signal my_counter, my_counter1, my_counter2, my_counter3: natural range 0 to 1023;

begin

m1: for i in 1 to dmax generate
		min_pr(i) <= signed('0' & min_in(i - 1)); --11 bits, move array one step right and convert to signed		
end generate m1;	

m2: for i in 0 to dmax + 1 generate
		cost_signed(i) <= signed('0' & cost_in(i)); --convert cost to signed 11 bit
end generate m2;	 	

min_pr(0) <= signed('0' & max_cost);--and fill in borders with max cost value
min_pr(dmax + 1) <= signed('0' & max_cost);
pr_min <= signed('0' & pr_L_min);

m3: for i in 0 to dmax + 1 generate
		path_cost_1(i) <= cost_signed(i) + min_pr(i) - pr_min;
		path_cost_2(i) <= std_logic_vector(path_cost_1(i)(N + 1 downto 0));
end generate m3;

counter: process(clk, resetn) -- This is the j counter used to select cost at the beginning of scanline
			variable j_counter: natural range 0 to 1023;
			begin
				if resetn = '0' then
					
					j_counter := 0;
					
				elsif rising_edge(clk) then
				
					if clken = '1' then
					
						j_counter := j_counter + 1;
						
						if j_counter = line_width then
							j_counter := 0;
						end if;
						
					end if;
					
				end if;				
				my_counter1 <= j_counter;
			end process counter;	

			
delay_cost: process(clk) --delay counter value in order to catch up with other delays
				begin
				
					if(rising_edge(clk)) then
				  
						if clken = '1' then
						
							my_counter2 <= my_counter1;
							my_counter3 <= my_counter2;
							my_counter  <= my_counter3;
							
						end if;
						
					end if;	
				end process delay_cost;							

		  
with my_counter select
	path_cost <= cost_in when 0, --path_cost_3
					 path_cost_2 when OTHERS;
		  
		  
end pipelining;
		  