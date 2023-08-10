--Project: SGM stereo algorithm implementation
--By John Kalomiros, John Vourvoulakis and Stavtos Vologiannidis
--Version: 1.0
--Date: February 2023
--File: SGM stereo processor work package
--International Hellenic University
-----------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
------------------------------
package sgm_stereo_package is

--DECLARATIONS OF CONSTANTS

constant N: natural range 0 to 32 := 8; --Number of bits in samples
constant dmax: positive range 1 to 128 := 127; --Maximum disparity range = (15, 31, 47, 63, 79, 95, 111, 127) odd number only
constant P1: unsigned(3 downto 0):="0101" ; -- penalty constants
constant P2: unsigned(3 downto 0):= "1010";
constant max_cost: std_logic_vector(N+1 downto 0):="0111111111"; --maximum cost 10 bit
constant line_width: positive range 1 to 1600 := 1600;--nominally 640 
constant div: positive range 1 to 16 := 16;--div is at least = 2

--TYPE DECLARATIONS
subtype std_sample is std_logic_vector(N + 1 downto 0);--10 bits
type OneD_std is array(natural range <>) of std_sample;

subtype uns_sample is unsigned(N + 1 downto 0);--10 bits
type OneD_uns is array(natural range <>) of uns_sample;

subtype signed_sample is signed(N + 2 downto 0);--11 bits
type OneD_signed is array(natural range <>) of signed_sample;

type TwoD_std is array(natural range <>, natural range <>) of std_logic_vector(N + 1 downto 0);

type OneD_nat is array(natural range <>) of integer;

type OneD_array is array(natural range 0 to dmax - 1) of OneD_std(0 to dmax + 1);

type OneD_buffer is array(natural range <>) of OneD_std(0 to dmax + 1);

--COMPONENT DECLARATIONS

component min2 is
	port(in1, in2: in std_logic_vector(N + 1 downto 0);
		  min_value: out std_logic_vector(N + 1 downto 0));
end component;

component min3 is
	port(in1, in2, in3: in std_logic_vector(N + 1 downto 0);
		  min_value: out std_logic_vector(N + 1 downto 0));
end component;

component intro_block_BT is
	port(imleft_in, imright_in: in std_logic_vector(N - 1 downto 0);
		  clk, clken, resetn: in std_logic;
		  cost_out: out OneD_std(0 to dmax + 1));	
end component;

component compute_min_L is
	port(cost_in: in OneD_std(0 to dmax + 1);
		  clk, clken: in std_logic;
		  min_Lrd: out OneD_std(0 to dmax - 1)); --array of disparities is 0 to dmax - 1
end component;

component recursive_path is
	port(cost_in: OneD_std(0 to dmax + 1);
		  clk, clken, resetn: in std_logic;
		  min_in : in OneD_std(0 to dmax - 1); -- 10 bits
		  pr_L_min: in std_logic_vector(N + 1 downto 0);--total minimum of previous pixel cost
		  path_cost: out OneD_std(0 to dmax + 1));
end component;

component parallel_min is
generic(m: positive);
	port(values_in	 : in OneD_std(0 to m); --10 bits
		  min_value : out std_logic_vector(N+1 downto 0));
end component;

component parallel_min_tag is
generic(m: positive);
	port(values_in	 : in OneD_std(0 to m);--in OneD_std(0 to dmax - 1); --10 bits
		  min_value  : out std_logic_vector(N+1 downto 0);
		  min_index	 : out natural range 0 to 255);
end component;	

component min2_tag is
	port( in1, in2: in std_logic_vector(N + 1 downto 0);
			order1, order2	 : in natural range 0 to dmax + 1;			
			min_value: out std_logic_vector(N + 1 downto 0);
			tag	 : out natural range 0 to dmax + 3);
end component;

component new12_min_Lr2_64 is
	port(cost: in OneD_std(0 to dmax + 1);
		  mind_pr_out: out std_logic_vector(N+1 downto 0);--overall minimum
		  minLrd_out: out OneD_std(0 to dmax - 1));		  	  
end component;

component line_buffer is
generic(depth: positive:=line_width;
		  m: natural := dmax + 1);
port(shiftin: in OneD_std(0 to m);
	  clk, clken, resetn: in std_logic;
	  shiftout: out OneD_std(0 to m));
end component;    				  

component sgm_buf_h is
	port(cost_in: in OneD_std(0 to dmax + 1);
		  clk, clken, resetn: in std_logic;
		  Lh: out OneD_std(0 to dmax + 1)); --array of costs is 0 to dmax + 1
end component;

end package;
