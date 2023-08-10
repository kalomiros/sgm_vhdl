--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: top level
--This module implements a pixel buffer q in the form of a shift register
--and computes ΒΤ cost for all disparity values -1, 0, up to dmax+1
--This is the introductory module of a system that applies the semi global matching algorithm
--with Birchfield and Tomasi cost

---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sgm_stereo_package.all;

entity intro_block_BT is
	port(imleft_in, imright_in: in std_logic_vector(N-1 downto 0);		  
		  clk, clken, resetn: in std_logic;
		  cost_out: out OneD_std(0 to dmax + 1));
end intro_block_BT;

architecture cost_compute of intro_block_BT is
signal cost_current: OneD_std(0 to dmax + 1):=(OTHERS => (OTHERS => '0'));--init with 1023
begin	

cost:	process(clk, resetn)
		variable q: OneD_signed(0 to dmax + 2); --A buffer of length dmax+2 for all left pixels in disp range
		variable right_I_minus, right_I_plus, right_I_min_0, right_I_min: OneD_signed(0 to dmax + 1);
		variable right_I_max_0, right_I_max, diss_right_0, diss_right: OneD_signed(0 to dmax + 1);
		variable left_I_minus, left_I_plus, left_I_min_0, left_I_min: OneD_signed(0 to dmax + 1);
		variable left_I_max_0, left_I_max, diss_left_0, diss_left: OneD_signed(0 to dmax + 1);
		variable imleft_reg1, imleft_reg2, imleft_reg3: signed(N+2 downto 0) := "00000000000";
		variable diss: OneD_signed(0 to dmax + 1);
		constant my_zero: signed(N + 2 downto 0) := "00000000000";
		begin
			if resetn = '0' then
--			gen0:	for i in 0 to dmax + 2	loop
						q := (OTHERS => (OTHERS => '0')); --start with 0 values in the queue
						cost_current <= (OTHERS => (OTHERS => '0'));
--					end loop;
			elsif rising_edge(clk) then
			
					if clken = '1' then
					
						imleft_reg3 := imleft_reg2; --IL(p+1)
						imleft_reg2 := imleft_reg1; --IL(p)
						imleft_reg1 := "00" & signed('0' & imleft_in); --IL(p-1)--register one pixel of left image (serial image streams leftwise)
						
			gen1:		for i in dmax + 2 downto 1 loop --implement shift register
							q(i) := q(i-1);
						end loop;
						
						q(0) := "00" & signed('0' & imright_in); --serial image streams leftwise, so right image fills the shift register

			gen2:  	for i in 0 to dmax + 1 loop
							right_I_minus(i) := (q(i) + q(abs(i - 1))) / 2;
							right_I_plus(i) := (q(i) + q(i + 1)) / 2;
							
							if right_I_minus(i) < right_I_plus(i) then
								right_I_min_0(i) := right_I_minus(i);--min
							else
								right_I_min_0(i) := right_I_plus(i);
							end if;
							if right_I_min_0(i) < q(i) then
								right_I_min(i) := right_I_min_0(i);--min
							else
								right_I_min(i) := q(i);
							end if;	
							if right_I_minus(i) > right_I_plus(i) then
								right_I_max_0(i) := right_I_minus(i);--max
							else
								right_I_max_0(i) := right_I_plus(i);
							end if;	
							if right_I_max_0(i) > q(i) then
								right_I_max(i) := right_I_max_0(i);--max
							else
								right_I_max(i) := q(i);
							end if;	
							if my_zero > imleft_reg2 - right_I_max(i) then
								diss_right_0(i) := my_zero;
							else
								diss_right_0(i) := imleft_reg2 - right_I_max(i);
							end if;	
							if diss_right_0(i) > right_I_min(i) - imleft_reg2 then
								diss_right(i) := diss_right_0(i);
							else
								diss_right(i) := right_I_min(i) - imleft_reg2;
							end if;

			
							left_I_minus(i) := (imleft_reg2 + imleft_reg1) / 2;
							left_I_plus(i) := (imleft_reg2 + imleft_reg3) / 2;
							
							if left_I_minus(i) < left_I_plus(i) then
								left_I_min_0(i) := left_I_minus(i);--min
							else
								left_I_min_0(i) := left_I_plus(i);
							end if;
							if left_I_min_0(i) < imleft_reg2 then
								left_I_min(i) := left_I_min_0(i);--min
							else
								left_I_min(i) := imleft_reg2 ;
							end if;	
							if left_I_minus(i) > left_I_plus(i) then
								left_I_max_0(i) := left_I_minus(i);--max
							else
								left_I_max_0(i) := left_I_plus(i);
							end if;	
							if left_I_max_0(i) > imleft_reg2 then
								left_I_max(i) := left_I_max_0(i);--max
							else
								left_I_max(i) := imleft_reg2;
							end if;	
							if my_zero > q(i) - left_I_max(i) then
								diss_left_0(i) := my_zero;
							else
								diss_left_0(i) := q(i) - left_I_max(i);
							end if;	
							if diss_left_0(i) > left_I_min(i) - q(i) then
								diss_left(i) := diss_left_0(i);
							else
								diss_left(i) := left_I_min(i) - q(i);
							end if;
							
							if diss_left(i) < diss_right(i) then
								diss(i) := diss_left(i);
							else
								diss(i) := diss_right(i);
							end if;

							cost_current(i) <= std_logic_vector(diss(i)(N + 1 downto 0));
							
						end loop;
					
					end if;
			end if;
		
		end process cost;

intro: process(clk) 
			begin
			
			if (rising_edge(clk)) then
			
				if clken = '1' then
					cost_out <= cost_current; -- pipeline the result
				end if;
				
			end if;	
			end process intro;
		
end cost_compute;	

	