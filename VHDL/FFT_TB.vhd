LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.Textio.all;
USE ieee.std_logic_textio.all;


ENTITY FFT_TB IS
END FFT_TB;

ARCHITECTURE behaviour OF FFT_TB is
	
	COMPONENT FFT_8
		PORT
	(
		CLK :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		START :  IN  STD_LOGIC;
		WI_0 :  IN  SIGNED(15 DOWNTO 0);
		WI_1 :  IN  SIGNED(15 DOWNTO 0);
		WI_2 :  IN  SIGNED(15 DOWNTO 0);
		WI_3 :  IN  SIGNED(15 DOWNTO 0);
		WR_0 :  IN  SIGNED(15 DOWNTO 0);
		WR_1 :  IN  SIGNED(15 DOWNTO 0);
		WR_2 :  IN  SIGNED(15 DOWNTO 0);
		WR_3 :  IN  SIGNED(15 DOWNTO 0);
		X0 :  IN  SIGNED(15 DOWNTO 0);
		X1 :  IN  SIGNED(15 DOWNTO 0);
		X2 :  IN  SIGNED(15 DOWNTO 0);
		X3 :  IN  SIGNED(15 DOWNTO 0);
		X4 :  IN  SIGNED(15 DOWNTO 0);
		X5 :  IN  SIGNED(15 DOWNTO 0);
		X6 :  IN  SIGNED(15 DOWNTO 0);
		X7 :  IN  SIGNED(15 DOWNTO 0);
		DONE :  OUT  STD_LOGIC;
		Y0 :  OUT  SIGNED(15 DOWNTO 0);
		Y1 :  OUT  SIGNED(15 DOWNTO 0);
		Y2 :  OUT  SIGNED(15 DOWNTO 0);
		Y3 :  OUT  SIGNED(15 DOWNTO 0);
		Y4 :  OUT  SIGNED(15 DOWNTO 0);
		Y5 :  OUT  SIGNED(15 DOWNTO 0);
		Y6 :  OUT  SIGNED(15 DOWNTO 0);
		Y7 :  OUT  SIGNED(15 DOWNTO 0)
	);
	END COMPONENT;
	
	-- Definizione segnali
	SIGNAL WI_0_s, WI_1_s, WI_2_s, WI_3_s, WR_0_s, WR_1_s, WR_2_s, WR_3_s, X0_s, X1_s, X2_s, X3_s, X4_s, X5_s, X6_s, X7_s : SIGNED(15 DOWNTO 0);
	SIGNAL Y0_s, Y1_s, Y2_s, Y3_s, Y4_s, Y5_s, Y6_s, Y7_s: SIGNED(15 DOWNTO 0);
	SIGNAL CLK_s, RST_s, START_s: STD_LOGIC;
	SIGNAL DONE_s: STD_LOGIC;
	
	-- Definzizione costanti
	CONSTANT CLK_PERIOD : TIME := 20 ns;
	CONSTANT BIT_TIME : TIME := CLK_PERIOD*217;
	CONSTANT TRANSMISSION_TIME : TIME := BIT_TIME*10;
	
	BEGIN
		DUT: FFT_8
		PORT MAP
		(
		CLK => CLK_s,
		RST => RST_s,
		START => START_s,
		WI_0 => WI_0_s,
		WI_1 => WI_1_s,
		WI_2 => WI_2_s,
		WI_3 => WI_3_s,
		WR_0 => WR_0_s,
		WR_1 => WR_1_s,
		WR_2 => WR_2_s,
		WR_3 => WR_3_s,
		X0 => X0_s,
		X1 => X1_s,
		X2 => X2_s, 
		X3 => X3_s,
		X4 => X4_s,
		X5 => X5_s,
		X6 => X6_s,
		X7 => X7_s,
		DONE => DONE_s,
		Y0 => Y0_s,
		Y1 => Y1_s,
		Y2 => Y2_s,
		Y3 => Y3_s,
		Y4 => Y4_s,
		Y5 => Y5_s,
		Y6 => Y6_s,
		Y7 => Y7_s
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
					
					--FOR i IN 0 TO 1024 LOOP
						START_s <='1';
						WAIT FOR CLK_PERIOD;
						START_s <='0';
					--	WAIT FOR CLK_PERIOD*3;
					-- END LOOP;
					WAIT;
			END PROCESS;
			
			
			
		SAMPLES_READ_PROCESS:
		PROCESS IS
			FILE X_BIN: text;
			VARIABLE x_read: LINE;
			VARIABLE X0_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X1_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X2_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X3_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X4_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X5_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X6_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X7_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X0_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X1_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X2_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X3_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X4_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X5_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X6_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE X7_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			
				BEGIN
				file_open(X_BIN, "X_BIN.txt", read_mode);
				
				-- Valori di DEFAULT
				X0_s <= "0000000000000000";
				X1_s <= "0000000000000000";
				X2_s <= "0000000000000000";
				X3_s <= "0000000000000000";
				X4_s <= "0000000000000000";
				X5_s <= "0000000000000000";
				X6_s <= "0000000000000000";
				X7_s <= "0000000000000000";

					while not endfile(X_BIN) LOOP -- 1024 elaborazioni
						WAIT UNTIL START_s = '1';
						WAIT FOR CLK_PERIOD/10; -- Altrimenti i load non funzionano bene
						WAIT FOR CLK_PERIOD;
						
						-- Lettura dati
						readline(X_BIN, x_read); -- X0_R
						read(x_read, X0_V_R);
						readline(X_BIN, x_read); -- X0_I
						read(x_read, X0_V_I);
						
						readline(X_BIN, x_read); -- X1_R
						read(x_read, X1_V_R);
						readline(X_BIN, x_read); -- X1_I
						read(x_read, X1_V_I);
						
						readline(X_BIN, x_read); -- X2_R
						read(x_read, X2_V_R);
						readline(X_BIN, x_read); -- X2_I
						read(x_read, X2_V_I);
						
						readline(X_BIN, x_read); -- X3_R
						read(x_read, X3_V_R);
						readline(X_BIN, x_read); -- X3_I
						read(x_read, X3_V_I);
						
						readline(X_BIN, x_read); -- X4_R
						read(x_read, X4_V_R);
						readline(X_BIN, x_read); -- X4_I
						read(x_read, X4_V_I);
						
						readline(X_BIN, x_read); -- X5_R
						read(x_read, X5_V_R);
						readline(X_BIN, x_read); -- X5_I
						read(x_read, X5_V_I);
						
						readline(X_BIN, x_read); -- X6_R
						read(x_read, X6_V_R);
						readline(X_BIN, x_read); -- X6_I
						read(x_read, X6_V_I);
						
						readline(X_BIN, x_read); -- X7_R
						read(x_read, X7_V_R);
						readline(X_BIN, x_read); -- X7_I
						read(x_read, X7_V_I);
						
						-- Dati REALI
						X0_s <= signed(X0_V_R);
						X1_s <= signed(X1_V_R);
						X2_s <= signed(X2_V_R);
						X3_s <= signed(X3_V_R);
						X4_s <= signed(X4_V_R);
						X5_s <= signed(X5_V_R);
						X6_s <= signed(X6_V_R);
						X7_s <= signed(X7_V_R);
						WAIT FOR CLK_PERIOD;
						
						-- Dati IMMAGINARI
						X0_s <= signed(X0_V_I);
						X1_s <= signed(X1_V_I);
						X2_s <= signed(X2_V_I);
						X3_s <= signed(X3_V_I);
						X4_s <= signed(X4_V_I);
						X5_s <= signed(X5_V_I);
						X6_s <= signed(X6_V_I);
						X7_s <= signed(X7_V_I);
						WAIT FOR CLK_PERIOD;
						-- :)
					END LOOP;
					
				file_close(X_BIN);
				WAIT;
			END PROCESS;
			
			
		W_READ_PROCESS:
		PROCESS IS
			FILE W_BIN: text;
			VARIABLE w_read: LINE;
			VARIABLE WI_0_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WI_1_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WI_2_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WI_3_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WR_0_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WR_1_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WR_2_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE WR_3_V: STD_LOGIC_VECTOR(15 DOWNTO 0);
			
				BEGIN
				file_open(W_BIN, "W_BIN.txt", read_mode);
				
				-- Valori di DEFAULT
					WI_0_s <= "0000000000000000";
					WI_1_s <= "0000000000000000";
					WI_2_s <= "0000000000000000";
					WI_3_s <= "0000000000000000";
					WR_0_s <= "0000000000000000";
					WR_1_s <= "0000000000000000";
					WR_2_s <= "0000000000000000";
					WR_3_s <= "0000000000000000";
					
					while not endfile(W_BIN) LOOP -- TOT elaborazioni
						WAIT UNTIL START_s = '1';
						WAIT FOR CLK_PERIOD/10; -- Altrimenti i load non funzionano bene
						WAIT FOR CLK_PERIOD;
						-- Lettura dati
						readline(W_BIN, w_read); -- WR_0
						read(w_read, WR_0_V);
						readline(W_BIN, w_read); -- WI_0
						read(w_read, WI_0_V);
						readline(W_BIN, w_read); -- WR_1
						read(w_read, WR_1_V);
						readline(W_BIN, w_read); -- WI_1
						read(w_read, WI_1_V);
						readline(W_BIN, w_read); -- WR_2
						read(w_read, WR_2_V);
						readline(W_BIN, w_read); -- WI_2
						read(w_read, WI_2_V);
						readline(W_BIN, w_read); -- WR_3
						read(w_read, WR_3_V);
						readline(W_BIN, w_read); -- WI_3
						read(w_read, WI_3_V);
						
						-- Dati
						WR_0_s <= signed(WR_0_V);
						WI_0_s <= signed(WI_0_V);
						
						WR_1_s <= signed(WR_1_V);
						WI_1_s <= signed(WI_1_V);
						
						WR_2_s <= signed(WR_2_V);
						WI_2_s <= signed(WI_2_V);
						
						WR_3_s <= signed(WR_3_V);
						WI_3_s <= signed(WI_3_V);
						
						WAIT FOR CLK_PERIOD;
						-- :)
					END LOOP;
					
				file_close(W_BIN);
				WAIT;
			END PROCESS;
			
		Y_PROCESS:
		PROCESS IS
			FILE Y_BIN: text;
			VARIABLE y_write: LINE;
			VARIABLE Y0_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y1_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y2_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y3_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y4_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y5_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y6_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y7_V_R: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y0_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y1_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y2_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y3_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y4_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y5_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y6_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			VARIABLE Y7_V_I: STD_LOGIC_VECTOR(15 DOWNTO 0);
			
				BEGIN
				file_open(Y_BIN, "Y_BIN_VHDL.txt", write_mode);
					
					--FOR i IN 0 TO 1023 LOOP -- 1024 elaborazioni
						WAIT UNTIL DONE_s = '1';
						WAIT FOR CLK_PERIOD/10; -- Altrimenti i load non funzionano bene
						WAIT FOR CLK_PERIOD;
						
						-- Dati REALI
						Y0_V_R := std_logic_vector(y0_s);
						Y1_V_R := std_logic_vector(y1_s);
						Y2_V_R := std_logic_vector(y2_s);
						Y3_V_R := std_logic_vector(y3_s);
						Y4_V_R := std_logic_vector(y4_s);
						Y5_V_R := std_logic_vector(y5_s);
						Y6_V_R := std_logic_vector(y6_s);
						Y7_V_R := std_logic_vector(y7_s);
						WAIT FOR CLK_PERIOD;
						
						-- Dati IMMAGINARI
						Y0_V_I := std_logic_vector(y0_s);
						Y1_V_I := std_logic_vector(y1_s);
						Y2_V_I := std_logic_vector(y2_s);
						Y3_V_I := std_logic_vector(y3_s);
						Y4_V_I := std_logic_vector(y4_s);
						Y5_V_I := std_logic_vector(y5_s);
						Y6_V_I := std_logic_vector(y6_s);
						Y7_V_I := std_logic_vector(y7_s);
						WAIT FOR CLK_PERIOD;
						
						-- Scrittura dati
						write(y_write, Y0_V_R); -- Y0_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y0_V_I); -- Y0_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y1_V_R); -- Y1_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y1_V_I); -- Y1_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y2_V_R); -- Y2_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y2_V_I); -- Y2_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y3_V_R); -- Y3_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y3_V_I); -- Y3_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y4_V_R); -- Y4_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y4_V_I); -- Y4_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y5_V_R); -- Y5_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y5_V_I); -- Y5_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y6_V_R); -- Y6_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y6_V_I); -- Y6_I
						writeline(Y_BIN, y_write); 
						
						write(y_write, Y7_V_R); -- Y7_R
						writeline(Y_BIN, y_write); 
						write(y_write, Y7_V_I); -- Y7_I
						writeline(Y_BIN, y_write); 
					
					--END LOOP;	
					file_close(Y_BIN);	
					WAIT;
			END PROCESS;
				
END behaviour;