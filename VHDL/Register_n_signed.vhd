LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Regustri a B but
ENTITY Register_n_signed IS
	GENERIC (N : integer := 16);
	PORT (
		Register_D : IN SIGNED(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
		Register_Clock, Register_Reset, Register_LOAD: IN STD_LOGIC;
		Register_Q : OUT SIGNED(N-1 DOWNTO 0) -- Segnale di uscita
	);
END Register_n_signed;
	
ARCHITECTURE Behavior OF Register_n_signed IS
BEGIN
	PROCESS(Register_Clock)
	BEGIN
		IF (Register_Clock'EVENT AND Register_Clock = '1') THEN
			IF (Register_Reset = '1') THEN
				Register_Q <= (OTHERS => '0');
			ELSIF Register_LOAD = '1' THEN
				Register_Q <= Register_D;
			END IF;
		END IF;
	END PROCESS;
END Behavior;