LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Half_range_even IS
	PORT(
		D_IN: IN SIGNED (32 DOWNTO 0);
		Half_range_even: OUT STD_LOGIC
	);
END Half_range_even;

ARCHITECTURE structure OF Half_range_even IS

BEGIN

Half_range_even <= D_IN(16) AND
						 NOT(D_IN(15)) AND 
						 NOT(D_IN(17)) AND
						 NOT(D_IN(18)) AND
						 NOT(D_IN(19)) AND
						 NOT(D_IN(20)) AND
						 NOT(D_IN(21)) AND
						 NOT(D_IN(22)) AND
						 NOT(D_IN(23)) AND
						 NOT(D_IN(24)) AND
						 NOT(D_IN(25)) AND
						 NOT(D_IN(26)) AND
						 NOT(D_IN(27)) AND
						 NOT(D_IN(28)) AND
						 NOT(D_IN(29)) AND
						 NOT(D_IN(30)) AND
						 NOT(D_IN(31)) AND
						 NOT(D_IN(32));
																	
END ARCHITECTURE;