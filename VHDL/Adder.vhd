LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Adder IS
	PORT(
			Adder_DIN_1: IN SIGNED(32 DOWNTO 0);
			Adder_DIN_2: IN SIGNED(32 DOWNTO 0);
			Adder_SUB: IN STD_LOGIC;
			Adder_Clock: IN STD_LOGIC;
			Adder_DOUT: OUT SIGNED(32 DOWNTO 0)
	);
END Adder;

ARCHITECTURE Behavior OF Adder IS
	
	COMPONENT Register_n_signed
		GENERIC (N : integer := 16);
		PORT (
			Register_D : IN SIGNED(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN std_logic;
			Register_Q : OUT SIGNED(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;

	SIGNAL Adder_OUT_inside_s: SIGNED(32 DOWNTO 0);

BEGIN
	
	Reg_delay: Register_n_signed GENERIC MAP ( N => 33 )
		PORT MAP(
			Register_D => Adder_OUT_inside_s,
			Register_Clock => Adder_Clock,
			Register_Reset => '0',
			Register_LOAD => '1',
			Register_Q => Adder_DOUT
		);
	
	Output: PROCESS(Adder_SUB, Adder_DIN_1, Adder_DIN_2)
	
	BEGIN
		IF (Adder_SUB = '0') THEN
			Adder_OUT_inside_s <= (Adder_DIN_1 + Adder_DIN_2);
		ELSE
			Adder_OUT_inside_s <= (Adder_DIN_2 + (NOT(Adder_DIN_1)) + 1);
		END IF;
	
	END PROCESS;
	
END Behavior;