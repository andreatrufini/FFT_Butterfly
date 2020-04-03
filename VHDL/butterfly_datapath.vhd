LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-- USE ieee.fixed_pkg.all;

ENTITY butterfly_datapath IS
	PORT(
		-- ingressi datapath
		CLK: IN STD_LOGIC;
		A_IN: IN SIGNED(15 DOWNTO 0);
		B_IN: IN SIGNED(15 DOWNTO 0);
		WR: IN SIGNED(15 DOWNTO 0);
		WI: IN SIGNED(15 DOWNTO 0);
		
		-- uscite datapath
		A_OUT: OUT SIGNED(15 DOWNTO 0);
		B_OUT: OUT SIGNED(15 DOWNTO 0);
		
		-- ingressi di controllo
		REG_BR_LOAD, REG_BI_LOAD,
		Reg_AR_LOAD, Reg_AI_LOAD, Reg_S_56_LOAD, 
		Reg_M_LOAD, Reg_S_1234_LOAD, Reg_OUT_LOAD, Reg_round_LOAD: IN STD_LOGIC;
		Adder_SUB: IN STD_LOGIC;
		
		Shift_done_en, Shift_done_rst, shift_done_in : IN STD_LOGIC;
		Shift_done_out : OUT STD_LOGIC;
		
		REG_BR_RST, REG_BI_RST,
		Reg_AR_RST, Reg_AI_RST, Reg_S_56_RST, 
		Reg_M_RST, Reg_S_1234_RST, Reg_OUT_RST, Reg_round_RST: IN STD_LOGIC;
		Buffer_A1_RST, Buffer_A2_RST, Buffer_B1_RST, Buffer_B2_RST: IN STD_LOGIC;
		
		MUX_W_SEL, Mux_B_SEL, Mux_bypass_B_SEL,
		Mux_A_SEL, Mux_A_S_12_SEL, Mux_DOUT_SEL: IN STD_LOGIC
	);
END butterfly_datapath;

ARCHITECTURE Structural OF butterfly_datapath IS

	COMPONENT Register_n_signed 
		GENERIC (N : integer := 16);
		PORT (
			Register_D : IN SIGNED(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN std_logic;
			Register_Q : OUT SIGNED(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;
	
	COMPONENT Mux_2to1_Nbit_signed 
		GENERIC (N : integer := 16);
		PORT( 
			Mux_2to1_Nbit_IN_1, Mux_2to1_Nbit_IN_2: IN SIGNED (N-1 DOWNTO 0);
			Mux_2to1_Nbit_SEL: IN STD_LOGIC;
			Mux_2to1_Nbit_OUT: OUT SIGNED (N-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT Multiplier
		PORT(
			Multiplier_Clock: IN STD_LOGIC;
			Multiplier_DIN_1: IN SIGNED(15 DOWNTO 0);
			Multiplier_DIN_2: IN SIGNED(15 DOWNTO 0);
			Multiplier_DOUT: OUT SIGNED(30 DOWNTO 0)
		);
	END COMPONENT;
		
	COMPONENT Adder
		PORT(
			Adder_DIN_1: IN SIGNED(32 DOWNTO 0);
			Adder_DIN_2: IN SIGNED(32 DOWNTO 0);
			Adder_SUB: IN STD_LOGIC;
			Adder_Clock: IN STD_LOGIC;
			Adder_DOUT: OUT SIGNED(32 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT Shift_reg_N
		GENERIC (N : integer := 8);
		PORT(
			Shift_clk: IN STD_LOGIC;
			Shift_in: IN STD_LOGIC;
			Shift_en: IN STD_LOGIC;
			Shift_rst: IN STD_LOGIC;
			Shift_out: OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT Rounder
		PORT(
			Rounder_Clock: IN STD_LOGIC;
			Rounder_DIN: IN SIGNED(32 DOWNTO 0);
			Rounder_DOUT: OUT SIGNED(15 DOWNTO 0)
		);
	END COMPONENT;
	
SIGNAL REG_BR_OUT_s, 
	   REG_BI_OUT_s,
	   mux_w_OUT_s,
	   Mux_B_OUT_s,
	   Reg_AR_OUT_s,
	   Reg_AI_OUT_s,
	   Mux_bypass_B_OUT_s,
	   Mux_A_OUT_s,
		Buffer_A1_OUT_s,
		Buffer_A2_OUT_s,
		Buffer_B1_OUT_s,
		Reg_OUT_s,
	   Rounder_OUT_s: SIGNED(15 DOWNTO 0);
	   
SIGNAL Multiplier_OUT_s,
	   Reg_M_OUT_s: SIGNED(30 DOWNTO 0);
	   
SIGNAL Block_div2_16to33_OUT_s,
	   Mux_A_S_12_OUT_s,
	   Block_div4_31to33_OUT_s,
	   Block_div4_16to33_OUT_s,
	   Sum_1234_OUT_s,
	   Reg_S_1234_OUT_s,
	   Sum_S_56_OUT_s,
	   Reg_S_56_OUT_s,
	   Mux_DOUT_OUT_s,
	   Reg_round_OUT_s: SIGNED(32 DOWNTO 0);

	   
BEGIN

	REG_BR: Register_n_signed
   			   PORT MAP (
				 Register_D => B_IN,
				 Register_Clock => CLK,
				 Register_Reset => REG_BR_RST,
				 Register_LOAD => REG_BR_LOAD,
				 Register_Q => REG_BR_OUT_s
			   );	
									
	REG_BI: Register_n_signed 
   			   PORT MAP (
				 Register_D => B_IN,
				 Register_Clock => CLK,
				 Register_Reset => REG_BI_RST,
				 Register_LOAD => REG_BI_LOAD,
				 Register_Q => REG_BI_OUT_s
			   );
			   
	
	Buffer_A1: Register_n_signed
				PORT MAP (
				 Register_D => A_IN,
				 Register_Clock => CLK,
				 Register_Reset => Buffer_A1_RST,
				 Register_LOAD => '1',
				 Register_Q => Buffer_A1_OUT_s
			   );
				
	Buffer_A2: Register_n_signed
				PORT MAP (
				 Register_D => Buffer_A1_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Buffer_A2_RST,
				 Register_LOAD => '1',
				 Register_Q => Buffer_A2_OUT_s
			   );
				
	Buffer_B1: Register_n_signed
				PORT MAP (
				 Register_D => Reg_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Buffer_B1_RST,
				 Register_LOAD => '1',
				 Register_Q => Buffer_B1_OUT_s
			   );
				
	Buffer_B2: Register_n_signed
				PORT MAP (
				 Register_D => Buffer_B1_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Buffer_B2_RST,
				 Register_LOAD => '1',
				 Register_Q => B_OUT
			   );
				
	Reg_AR: Register_n_signed 
   			   PORT MAP (
				 Register_D => Buffer_A2_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Reg_AR_RST,
				 Register_LOAD => Reg_AR_LOAD,
				 Register_Q => Reg_AR_OUT_s
			   );
				
	Reg_AI: Register_n_signed 
   			   PORT MAP (
					Register_D => Buffer_A2_OUT_s,
					Register_Clock => CLK,
					Register_Reset => Reg_AI_RST,
					Register_LOAD => Reg_AI_LOAD,
					Register_Q => Reg_AI_OUT_s
			   );
			   
	Mux_B: Mux_2to1_Nbit_signed
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => REG_BR_OUT_s,
				  	Mux_2to1_Nbit_IN_2 => REG_BI_OUT_s,
				  	Mux_2to1_Nbit_SEL => Mux_B_SEL,
				  	Mux_2to1_Nbit_OUT => Mux_B_OUT_s
				);
	
	mux_w: Mux_2to1_Nbit_signed
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => WI,
				  	Mux_2to1_Nbit_IN_2 => WR,
				  	Mux_2to1_Nbit_SEL => MUX_W_SEL,
				  	Mux_2to1_Nbit_OUT => mux_w_OUT_s
				);

	Mux_bypass_B: Mux_2to1_Nbit_signed
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => Mux_B_OUT_s,
				  	Mux_2to1_Nbit_IN_2 => B_IN,
				  	Mux_2to1_Nbit_SEL => Mux_bypass_B_SEL,
				  	Mux_2to1_Nbit_OUT => Mux_bypass_B_OUT_s
				);

	Mux_A: Mux_2to1_Nbit_signed
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => Reg_AR_OUT_s,
				  	Mux_2to1_Nbit_IN_2 => Reg_AI_OUT_s,
				  	Mux_2to1_Nbit_SEL => Mux_A_SEL,
				  	Mux_2to1_Nbit_OUT => Mux_A_OUT_s
				);

	Mult: Multiplier
				PORT MAP(
					Multiplier_Clock => CLK,
					Multiplier_DIN_1 => Mux_bypass_B_OUT_s,
					Multiplier_DIN_2 => mux_w_OUT_s,
					Multiplier_DOUT => Multiplier_OUT_s 
				);

	Reg_M: Register_n_signed GENERIC MAP ( N => 31 )
   			   PORT MAP (
				 Register_D => Multiplier_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Reg_M_RST,
				 Register_LOAD => Reg_M_LOAD,
				 Register_Q => Reg_M_OUT_s
			   );

	Block_div2_16to33_OUT_s <= Mux_A_OUT_s(15) & Mux_A_OUT_s(15) & Mux_A_OUT_s(14 DOWNTO 0) & "0000000000000000";
	
	Block_div4_31to33_OUT_s <= Reg_M_OUT_s(30 DOWNTO 30) & Reg_M_OUT_s(30 DOWNTO 30) & Reg_M_OUT_s(30 DOWNTO 30) & Reg_M_OUT_s(29 DOWNTO 0);

	Block_div4_16to33_OUT_s <= Buffer_A2_OUT_s(15) & Buffer_A2_OUT_s(15) & Buffer_A2_OUT_s(15) & Buffer_A2_OUT_s(14 DOWNTO 0) & "000000000000000";

	Mux_A_S_12: Mux_2to1_Nbit_signed GENERIC MAP ( N => 33 )
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => Block_div4_16to33_OUT_s,
				  	Mux_2to1_Nbit_IN_2 => Reg_S_1234_OUT_s,
				  	Mux_2to1_Nbit_SEL => Mux_A_S_12_SEL,
				  	Mux_2to1_Nbit_OUT => Mux_A_S_12_OUT_s
				);
				
	Sum_1234: Adder
				PORT MAP (
					Adder_DIN_1 => Block_div4_31to33_OUT_s,
					Adder_DIN_2 => Mux_A_S_12_OUT_s,
					Adder_SUB => Adder_SUB,
					Adder_Clock => CLK,
					Adder_DOUT => Sum_1234_OUT_s
				);


	Reg_S_1234: Register_n_signed GENERIC MAP ( N => 33 )
   			   PORT MAP (
				 Register_D => Sum_1234_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Reg_S_1234_RST,
				 Register_LOAD => Reg_S_1234_LOAD,
				 Register_Q => Reg_S_1234_OUT_s
			   );

	Sum_56: Adder 
				PORT MAP (
					Adder_DIN_1 => Reg_S_1234_OUT_s,
					Adder_DIN_2 => Block_div2_16to33_OUT_s,
					Adder_SUB => '1',
					Adder_Clock => CLK,
					Adder_DOUT => Sum_S_56_OUT_s
				);

	Reg_S_56: Register_n_signed GENERIC MAP ( N => 33 )
   			   PORT MAP (
				 Register_D => Sum_S_56_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => Reg_S_56_RST,
				 Register_LOAD => Reg_S_56_LOAD,
				 Register_Q => Reg_S_56_OUT_s
			   );

	Mux_DOUT: Mux_2to1_Nbit_signed GENERIC MAP ( N => 33 )
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => Reg_S_56_OUT_s,
				  	Mux_2to1_Nbit_IN_2 => Reg_S_1234_OUT_s,
				  	Mux_2to1_Nbit_SEL => Mux_DOUT_SEL,
				  	Mux_2to1_Nbit_OUT => Mux_DOUT_OUT_s
				);
	
	
	Rounding: Rounder
				PORT MAP (
					Rounder_Clock => CLK,
					Rounder_DIN => Mux_DOUT_OUT_s,
					Rounder_DOUT => Rounder_OUT_s
				);
				
	Reg_OUT: Register_n_signed
   			   PORT MAP (
					Register_D => Rounder_OUT_s,
					Register_Clock => CLK,
					Register_Reset => Reg_OUT_RST,
					Register_LOAD => Reg_OUT_LOAD,
					Register_Q => Reg_OUT_s
			   );
				

	A_OUT <= Reg_OUT_s;
				
	Shift_done: Shift_reg_N
		GENERIC MAP(N => 9)
		PORT MAP(
			Shift_clk => CLK,
			Shift_in => shift_done_IN,
			Shift_en => shift_done_EN,
			Shift_rst => shift_done_RST,
			Shift_out => shift_done_OUT
		);
			   
END Structural;