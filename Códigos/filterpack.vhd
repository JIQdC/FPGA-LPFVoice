library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package filterpack is
	constant Bits_cte_t: integer := 21;
	constant Bits_x_t: integer:= 8;
		
	constant N: integer := 26;
	constant N_idx: integer := 5;

	type x_t is array(integer range <>) of std_logic_vector(Bits_x_t-1 downto 0);
	type cte_t is array(integer range <>) of std_logic_vector(Bits_cte_t-1 downto 0);
	
end filterpack;