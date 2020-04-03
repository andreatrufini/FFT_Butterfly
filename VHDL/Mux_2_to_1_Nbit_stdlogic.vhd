LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Mux_2to1_Nbit_stdlogic IS
	GENERIC (N : integer := 16);
	PORT( Mux_2to1_Nbit_IN_1, Mux_2to1_Nbit_IN_2: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
			Mux_2to1_Nbit_SEL : IN STD_LOGIC;
			Mux_2to1_Nbit_OUT : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)
		);
END Mux_2to1_Nbit_stdlogic;

ARCHITECTURE Behavior OF Mux_2to1_Nbit_stdlogic IS

BEGIN
	Mux_2to1_Nbit_OUT <= Mux_2to1_Nbit_IN_1 WHEN Mux_2to1_Nbit_SEL = '0' ELSE
									Mux_2to1_Nbit_IN_2;
END Behavior;