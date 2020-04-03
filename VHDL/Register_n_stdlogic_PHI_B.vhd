LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Regustri a B but
ENTITY Register_n_stdlogic_PHI_B IS
	GENERIC (N : integer := 16);
	PORT (
		Register_D : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
		Register_Clock, Register_Reset, Register_LOAD: IN STD_LOGIC;
		Register_Q : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) -- Segnale di uscita
	);
END Register_n_stdlogic_PHI_B;
	
ARCHITECTURE Behavior OF Register_n_stdlogic_PHI_B IS
BEGIN
	PROCESS(Register_Clock)
	BEGIN
		IF (Register_Clock'EVENT AND Register_Clock = '0') THEN
			IF (Register_Reset = '1') THEN
				Register_Q <= (OTHERS => '0');
			ELSIF Register_LOAD = '1' THEN
				Register_Q <= Register_D;
			END IF;
		END IF;
	END PROCESS;
END Behavior;