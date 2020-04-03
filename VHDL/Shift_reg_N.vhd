LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY Shift_reg_N IS
	GENERIC (N : integer := 8);
	PORT(
		Shift_clk: IN STD_LOGIC;
		Shift_in: IN STD_LOGIC;
		Shift_en: IN STD_LOGIC;
		Shift_rst: IN STD_LOGIC;
		Shift_out: OUT STD_LOGIC
	);
END Shift_reg_N;

ARCHITECTURE Structure OF Shift_reg_N IS
	SIGNAL shift_reg: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	
BEGIN 

shift_out <= shift_reg(0);

	PROCESS(Shift_clk, Shift_rst) IS
	BEGIN
			IF (Shift_rst = '1') THEN
				shift_reg <= (others => '0');
			ELSIF (Shift_clk'EVENT AND Shift_clk = '1') THEN
				IF (Shift_en = '1') THEN
					FOR i IN 0 TO (N-2) LOOP
					shift_reg(i) <= shift_reg(i+1);
					END LOOP;
					shift_reg(N-1) <= shift_in;
				END IF;
			END IF;
	END PROCESS;



END Structure;