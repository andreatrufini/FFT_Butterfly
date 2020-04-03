LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Rounder IS
	PORT(
		Rounder_Clock: IN STD_LOGIC;
		Rounder_DIN: IN SIGNED(32 DOWNTO 0);
		Rounder_DOUT: OUT SIGNED(15 DOWNTO 0)
	);
END Rounder;

ARCHITECTURE Structural OF Rounder IS

	COMPONENT Mux_2to1_Nbit_signed
		GENERIC (N : integer := 33);
		PORT( 
			Mux_2to1_Nbit_IN_1, Mux_2to1_Nbit_IN_2: IN SIGNED (N-1 DOWNTO 0);
			Mux_2to1_Nbit_SEL: IN STD_LOGIC;
			Mux_2to1_Nbit_OUT: OUT SIGNED (N-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT Half_range_even IS
	PORT(
		D_IN: IN SIGNED (32 DOWNTO 0);
		Half_range_even: OUT STD_LOGIC
	);
	END COMPONENT;
	
	SIGNAL Adder_OUT_s: SIGNED(33 DOWNTO 0);
	SIGNAL Half_range_OUT_s: STD_LOGIC;
	SIGNAL Rounder_DOUT_s: SIGNED(32 DOWNTO 0);

BEGIN

	Half_range_check: Half_range_even
	PORT MAP(
		D_IN => Rounder_DIN,
		Half_range_even => Half_range_OUT_s
	);

	Mux: Mux_2to1_Nbit_signed
		PORT MAP (
			Mux_2to1_Nbit_IN_1 => Adder_OUT_s (32 DOWNTO 0),
			Mux_2to1_Nbit_IN_2 => Rounder_DIN,
			Mux_2to1_Nbit_SEL => Half_range_OUT_s,
			Mux_2to1_Nbit_OUT => Rounder_DOUT_s
		);

	Adder_OUT_s <= "0000000000000000010000000000000000" + Rounder_DIN;
	
	Rounder_DOUT <= Rounder_DOUT_s(32 DOWNTO 17);
	
END Structural;