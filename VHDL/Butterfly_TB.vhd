LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.Textio.all;
USE ieee.std_logic_textio.all;


ENTITY Butterfly_TB IS
END Butterfly_TB;

ARCHITECTURE behaviour OF Butterfly_TB is
	
	COMPONENT Butterfly
		PORT
	(
		Butterfly_A_IN: IN SIGNED(15 DOWNTO 0);
		Butterfly_B_IN: IN SIGNED(15 DOWNTO 0);
		Butterfly_WR: IN SIGNED(15 DOWNTO 0);
		Butterfly_WI : IN SIGNED(15 DOWNTO 0);
		Butterfly_CLK: IN STD_LOGIC;
		Butterfly_RST: IN STD_LOGIC;
		Butterfly_START: IN STD_LOGIC;
		Butterfly_DONE: OUT STD_LOGIC;
		Butterfly_A_OUT: OUT SIGNED(15 DOWNTO 0);
		Butterfly_B_OUT: OUT SIGNED(15 DOWNTO 0)
	);
	END COMPONENT;
	
	-- Definizione segnali
	SIGNAL A_IN_s, B_IN_s, WI_s, WR_s, A_OUT_s, B_OUT_s : SIGNED(15 DOWNTO 0);
	SIGNAL CLK_s, RST_s, START_s: STD_LOGIC;
	SIGNAL DONE_s: STD_LOGIC;
	
	-- Definzizione costanti
	CONSTANT CLK_PERIOD : TIME := 20 ns;
	CONSTANT BIT_TIME : TIME := CLK_PERIOD*217;
	CONSTANT TRANSMISSION_TIME : TIME := BIT_TIME*10;
	
	BEGIN
		DUT: Butterfly
			PORT MAP
			(
				Butterfly_A_IN => A_IN_s,
				Butterfly_B_IN => B_IN_s,
				Butterfly_WR => WR_s,
				Butterfly_WI => WI_s,
				Butterfly_CLK => CLK_s,
				Butterfly_RST => RST_s,
				Butterfly_START => START_s,
				Butterfly_A_OUT => A_OUT_s,
				Butterfly_B_OUT => B_OUT_s,
				Butterfly_DONE => DONE_s
			);
			
			-- Clock a 25 MHz (Funziona a quella velocità??)
			Clock: 
			PROCESS IS
				BEGIN
					CLK_s <= '1', '0' AFTER CLK_PERIOD/2;
					WAIT FOR CLK_PERIOD;
			END PROCESS;
			
			--PROCESSO PER IL RESET
			RST_process:
			PROCESS IS
				BEGIN 
					RST_s <= '1';
					WAIT FOR CLK_PERIOD*3;
					RST_s <='0';
					WAIT;
			END PROCESS;
			
			--PROCESSO PER LO START
			START_process:
			PROCESS IS
				BEGIN 
					START_s <= '0';
					WAIT FOR CLK_PERIOD*10;
					WAIT FOR CLK_PERIOD/10; -- Piccolo delta
					
					FOR i IN 0 TO 1023 LOOP --
						START_s <='1';
						WAIT FOR CLK_PERIOD;
						START_s <='0';
						WAIT FOR CLK_PERIOD*3;
					END LOOP;
					
					WAIT;
			END PROCESS;
			
			READ_PROCESS:
			PROCESS IS
			FILE INPUT_BIN: text;
			VARIABLE riga_read: LINE;
			VARIABLE WR: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WI: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE AR: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE AI: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE BR: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE BI: STD_LOGIC_VECTOR(15 DOWNTO 0);
			
				BEGIN
				file_open(INPUT_BIN, "INPUT_BIN.txt", read_mode);
				
				-- Valori di DEFAULT
					WI_s <= "0000000000000000";
					WR_s <= "0000000000000000";
					A_IN_s <= "0000000000000000";
					B_IN_s <= "0000000000000000";
					
					while not endfile(INPUT_BIN) LOOP -- 1024 elaborazioni
						WAIT UNTIL START_s = '1';
						WAIT FOR CLK_PERIOD/10; -- Altrimenti i load non funzionano bene
						WAIT FOR CLK_PERIOD;
						-- Lettura dati
						readline(INPUT_BIN, riga_read); 
						read(riga_read, WR);
						readline(INPUT_BIN, riga_read); 
						read(riga_read, WI);
						readline(INPUT_BIN, riga_read); 
						read(riga_read, AR);
						readline(INPUT_BIN, riga_read); 
						read(riga_read, AI);
						readline(INPUT_BIN, riga_read); 
						read(riga_read, BR);
						readline(INPUT_BIN, riga_read); 
						read(riga_read, BI);
						
						-- Dati
						WR_s <= signed(WR); -- DO IL COEFFICIENTE WR
						WI_s <= signed(WI); -- DO IL COEFFICIENTE WI
						A_IN_s <= signed(AR); -- DO IL COEFFICIENTE AR
						B_IN_s <= signed(BR); -- DO IL COEFFICIENTE BR
						WAIT FOR CLK_PERIOD;
						
						A_IN_s <= signed(AI); -- DO IL COEFFICIENTE AI
						B_IN_s <= signed(BI); -- DO IL COEFFICIENTE BI 
						WAIT FOR CLK_PERIOD;
						-- :)
					END LOOP;
					
				file_close(INPUT_BIN);
				WAIT;
			END PROCESS;
			
			WRITE_PROCESS:
			PROCESS IS
			FILE OUTPUT_BIN: text;
			VARIABLE riga_write: LINE;
			VARIABLE AR_OUT : SIGNED(15 DOWNTO 0);
			VARIABLE AI_OUT : SIGNED(15 DOWNTO 0);
			VARIABLE BR_OUT : SIGNED(15 DOWNTO 0);
			VARIABLE BI_OUT : SIGNED(15 DOWNTO 0);
			
				BEGIN
				file_open(OUTPUT_BIN, "OUTPUT_BIN_VHDL.txt", write_mode);
				-- Valori di DEFAULT
					
					
					FOR i IN 0 TO 1023 LOOP -- 1024 elaborazioni
						WAIT UNTIL DONE_s = '1';
						WAIT FOR CLK_PERIOD/10; -- Altrimenti i load non funzionano bene
						WAIT FOR CLK_PERIOD;
						BR_OUT := B_OUT_s;
						AR_OUT := A_OUT_s;
						WAIT FOR CLK_PERIOD;
						AI_OUT := A_OUT_s;
						BI_OUT := B_OUT_s;
						
						-- Scrittura dati
						write(riga_write, std_logic_vector(AR_OUT)); -- AR_OUT
						writeline(OUTPUT_BIN, riga_write); 
						write(riga_write, std_logic_vector(AI_OUT)); -- AI_OUT
						writeline(OUTPUT_BIN, riga_write); 
						write(riga_write, std_logic_vector(BR_OUT)); -- BR_OUT
						writeline(OUTPUT_BIN, riga_write); 
						write(riga_write, std_logic_vector(BI_OUT)); -- BI_OUT
						writeline(OUTPUT_BIN, riga_write); 
					END LOOP;	
					file_close(OUTPUT_BIN);
					WAIT;
			END PROCESS;
				
END behaviour;