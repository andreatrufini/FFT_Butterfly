LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Multiplier IS
	PORT(
		Multiplier_Clock: IN STD_LOGIC;
		Multiplier_DIN_1: IN SIGNED(15 DOWNTO 0);
		Multiplier_DIN_2: IN SIGNED(15 DOWNTO 0);
		Multiplier_DOUT: OUT SIGNED(30 DOWNTO 0)
	);
END Multiplier;

ARCHITECTURE Behavior OF Multiplier IS
	
	COMPONENT Register_n_signed
		GENERIC (N : integer := 16);
		PORT (
			Register_D : IN SIGNED(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN std_logic;
			Register_Q : OUT SIGNED(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;

	SIGNAL Multiplier_OUT_inside_s: SIGNED(30 DOWNTO 0);
	SIGNAL Multiplier_OUT_inside_32_s: SIGNED(31 DOWNTO 0);

BEGIN
	
	Reg_delay: Register_n_signed GENERIC MAP ( N => 31 )
		PORT MAP(
			Register_D => Multiplier_OUT_inside_s,
			Register_Clock => Multiplier_Clock,
			Register_Reset => '0',
			Register_LOAD => '1',
			Register_Q => Multiplier_DOUT
		);
	
	Multiplier_OUT_inside_32_s <= (Multiplier_DIN_1 * Multiplier_DIN_2);
	Multiplier_OUT_inside_s <= Multiplier_OUT_inside_32_s(30 DOWNTO 0);
	
END Behavior;