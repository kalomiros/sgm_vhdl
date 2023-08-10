--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: top level (instantiates all files)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;
------------------------------------
entity top_level is
	port(imleft_in, imright_in: in std_logic_vector(N - 1 downto 0);
		  clk, clken, resetn: in std_logic;
		  disparity_out: out std_logic_vector(7 downto 0)); --8 bits
end top_level;

architecture all_blocks of top_level is
signal min_cost: std_logic_vector(N + 1 downto 0);
signal disp_nat: natural range 0 to dmax + 3;
signal cost_array, S: OneD_std(0 to dmax + 1);
signal S1: OneD_signed(0 to dmax + 1); 

signal cost_Lh, cost_Lv, cost_Ld, cost_Ld2: OneD_std(0 to dmax + 1);
signal L_far_min_h, L_min_h, L_close_min_h: OneD_std(0 to dmax - 1):=(OTHERS=>(OTHERS=>'0')); -- array of 10-bit std_logic_vector
signal pr_min_overall_h: std_logic_vector(N+1 downto 0):="0000000000";

signal cost_L2, cost_L1: OneD_std(0 to dmax + 1);
signal L_far_min_v, L_min_v, L_close_min_v: OneD_std(0 to dmax - 1):=(OTHERS=>(OTHERS=>'0')); -- array of 10-bit std_logic_vector
signal pr_min_overall_v: std_logic_vector(N+1 downto 0):="0000000000";

signal cost_L3: OneD_std(0 to dmax + 1);
signal L_far_min_d, L_min_d, L_close_min_d: OneD_std(0 to dmax - 1):=(OTHERS=>(OTHERS=>'0')); -- array of 10-bit std_logic_vector
signal pr_min_overall_d: std_logic_vector(N+1 downto 0):="0000000000";

signal cost_L4: OneD_std(0 to dmax + 1);
signal L_far_min_d2, L_min_d2, L_close_min_d2: OneD_std(0 to dmax - 1):=(OTHERS=>(OTHERS=>'0')); -- array of 10-bit std_logic_vector
signal pr_min_overall_d2: std_logic_vector(N+1 downto 0):="0000000000";

signal min_val: OneD_std(0 to div - 1); 
signal my_tag: OneD_nat(0 to div - 1);
signal tag: natural range 0 to div;

begin

cost_SAD: intro_block_BT port map(imleft_in => imleft_in, imright_in => imright_in,
											 clk => clk, clken => clken, resetn => resetn, cost_out => cost_array);
										 
--horizontal direction

recurse_h:	recursive_path port map(cost_in => cost_array, clk => clk, clken => clken, resetn => resetn, min_in => L_min_h, 
												pr_L_min => pr_min_overall_h, path_cost => cost_L1);										 
buf_h: sgm_buf_h port map(cost_in => cost_L1, clk => clk, clken => clken, resetn => resetn, Lh => cost_Lh);
											
min_L_close_h: compute_min_L port map(cost_in => cost_Lh, clk => clk, clken => clken, min_Lrd => L_close_min_h);

min_L_far_h:  new12_min_Lr2_64 port map(cost => cost_Lh, mind_pr_out => pr_min_overall_h, 
												 minLrd_out => L_far_min_h);

k1: for i in 0 to dmax - 1 generate 

Lm1:			min2 port map(in1 => L_far_min_h(i), in2 => L_close_min_h(i), min_value => L_min_h(i));

	 end generate k1;

--vertical direction 

recurse_v:	recursive_path port map(cost_in => cost_array, clk => clk, clken => clken, resetn => resetn, 
												min_in => L_min_v, pr_L_min => pr_min_overall_v, path_cost => cost_L2);										 
											
line_buf_v: line_buffer port map(shiftin => cost_L2, clk => clk, clken => clken, resetn => resetn, shiftout => cost_Lv);
											
min_L_close_v: compute_min_L port map(cost_in => cost_Lv, clk => clk, clken => clken, min_Lrd => L_close_min_v);

min_L_far_v:  new12_min_Lr2_64 port map(cost => cost_Lv, mind_pr_out => pr_min_overall_v, 
											 minLrd_out => L_far_min_v);


k2: for i in 0 to dmax - 1 generate 

Lm2:			min2 port map(in1 => L_far_min_v(i), in2 => L_close_min_v(i), min_value => L_min_v(i));

	 end generate k2;

--diagonal direction

recurse_d:	recursive_path port map(cost_in => cost_array, clk => clk, clken => clken, resetn => resetn, 
												min_in => L_min_d, pr_L_min => pr_min_overall_d, path_cost => cost_L3);										 
											
line_buf_d: line_buffer generic map(depth => line_width + 1, m => dmax + 1) port map(shiftin => cost_L3, clk => clk, clken => clken, resetn => resetn, shiftout => cost_Ld);											
											
min_L_close_d: compute_min_L port map(cost_in => cost_Ld, clk => clk, clken => clken, min_Lrd => L_close_min_d);

min_L_far_d:  new12_min_Lr2_64 port map(cost => cost_Ld, mind_pr_out => pr_min_overall_d, 
											 minLrd_out => L_far_min_d);
								
k3: for i in 0 to dmax - 1 generate 

Lm3:			min2 port map(in1 => L_far_min_d(i), in2 => L_close_min_d(i), min_value => L_min_d(i));

	 end generate k3;

--diagonal-2 direction

recurse_d2:	recursive_path port map(cost_in => cost_array, clk => clk, clken => clken, resetn => resetn, 
												min_in => L_min_d2, pr_L_min => pr_min_overall_d2, path_cost => cost_L4);										 
											
line_buf_d2: line_buffer generic map(depth => line_width - 1, m => dmax + 1) port map(shiftin => cost_L4, clk => clk, clken => clken, resetn => resetn, shiftout => cost_Ld2);											
											
min_L_close_d2: compute_min_L port map(cost_in => cost_Ld2, clk => clk, clken => clken, min_Lrd => L_close_min_d2);

min_L_far_d2:  new12_min_Lr2_64 port map(cost => cost_Ld2, mind_pr_out => pr_min_overall_d2, 
											     minLrd_out => L_far_min_d2);
								
k4: for i in 0 to dmax - 1 generate 

Lm4:			min2 port map(in1 => L_far_min_d2(i), in2 => L_close_min_d2(i), min_value => L_min_d2(i));

	 end generate k4;	 
	 
--extract optimum disparity	 
	 
gen1: 		for di in 0 to dmax + 1 generate
	 
					S1(di) <= '0' & signed(cost_Lh(di)) + signed(cost_Lv(di)) + signed(cost_Ld(di)) + signed(cost_Ld2(di)); 
					
					S(di)  <= max_cost when di = 0 else 
								 max_cost when di = dmax + 1 else
								 std_logic_vector(S1(di)(N + 1 downto 0));
					
				end generate;

dx0: for i in 0 to div - 1 generate

disp_comp1: parallel_min_tag generic map((dmax + 1)/div - 1) port map(values_in => S(i*(dmax + 1)/div + 1 to (i + 1)*(dmax + 1)/div), min_value=>min_val(i), min_index=>my_tag(i));
			 
end generate dx0;

disp_comp2: parallel_min_tag generic map(div - 1) port map(values_in => min_val, min_index => tag);
			   
disp_nat <= my_tag(tag) + tag*((dmax + 1)/div);	
								
disparity_out	<= std_logic_vector(to_unsigned(disp_nat, 8)); 							
	 
end all_blocks;										 

		  