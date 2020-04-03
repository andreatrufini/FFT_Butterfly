LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Butterfly IS
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
END Butterfly;

ARCHITECTURE Structural OF Butterfly IS
	
	COMPONENT butterfly_datapath
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
	END COMPONENT;
	
	COMPONENT CU
		PORT(
			-- INGRESSI
			Start: IN STD_LOGIC;
			RST: IN STD_LOGIC;
			CLK: IN STD_LOGIC;
			
			-- USCITE
			Control: OUT STD_LOGIC_VECTOR(16 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL CU_OUT_s: STD_LOGIC_VECTOR(16 DOWNTO 0);
	
BEGIN

	Datapath: butterfly_datapath
		PORT MAP(
			CLK 			 => Butterfly_CLK,
			A_IN 			 => Butterfly_A_IN,
			B_IN 			 => Butterfly_B_IN,
			WR				 => Butterfly_WR,
			WI 			 => Butterfly_WI,
			A_OUT 			 => Butterfly_A_OUT,
			B_OUT 			 => Butterfly_B_OUT,
			REG_BR_LOAD 	 => CU_OUT_s(15),
			REG_BI_LOAD 	 => CU_OUT_s(14), 
			Reg_AR_LOAD 	 => CU_OUT_s(8),
			Reg_AI_LOAD 	 => CU_OUT_s(7),
			Reg_S_56_LOAD    => CU_OUT_s(1),
			Reg_M_LOAD       => CU_OUT_s(3),
			Reg_S_1234_LOAD  => CU_OUT_s(2),
			Reg_OUT_LOAD     => CU_OUT_s(0),
			Reg_round_LOAD   => CU_OUT_s(4),
			REG_BR_RST    => Butterfly_RST,
			REG_BI_RST    => Butterfly_RST,
			Reg_AR_RST       => Butterfly_RST,
			Reg_AI_RST       => Butterfly_RST,
			Reg_S_56_RST     => Butterfly_RST,
			Reg_M_RST        => Butterfly_RST,
			Reg_S_1234_RST   =>	Butterfly_RST, 
			Reg_OUT_RST      => Butterfly_RST,
			Reg_round_RST    => Butterfly_RST,
			Buffer_A1_RST	  => Butterfly_RST,
			Buffer_A2_RST	  => Butterfly_RST,
			Buffer_B1_RST	  => Butterfly_RST,
			Buffer_B2_RST	  => Butterfly_RST,
			MUX_W_SEL => CU_OUT_s(11),
			Mux_B_SEL        => CU_OUT_s(13),
			Mux_bypass_B_SEL =>	CU_OUT_s(12), 
			Mux_A_SEL        => CU_OUT_s(6),
			Mux_A_S_12_SEL   =>	CU_OUT_s(10), 
			Mux_DOUT_SEL     => CU_OUT_s(5),
			Adder_SUB => CU_OUT_s(9),
			Shift_done_en => CU_OUT_s(16),
			Shift_done_rst => Butterfly_RST,
			Shift_done_in => Butterfly_START,
			Shift_done_out => Butterfly_DONE
		);
		
		ControlUnit: CU
			PORT MAP(
				Start           => Butterfly_START, 
				RST             => Butterfly_RST,
				CLK             => Butterfly_CLK,
				Control         => CU_OUT_s
			);
	
END Structural;