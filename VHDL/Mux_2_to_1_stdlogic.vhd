LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Mux_2to1_stdlogic IS
	PORT( Mux_2to1_IN_1, Mux_2to1_IN_2: IN STD_LOGIC;
			Mux_2to1_SEL : IN STD_LOGIC;
			Mux_2to1_OUT : OUT STD_LOGIC
		);
END Mux_2to1_stdlogic;

ARCHITECTURE Behavior OF Mux_2to1_stdlogic IS

BEGIN
	Mux_2to1_OUT <= Mux_2to1_IN_1 WHEN Mux_2to1_SEL = '0' ELSE
									Mux_2to1_IN_2;
END Behavior;