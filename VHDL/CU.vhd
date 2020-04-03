LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY CU IS
	PORT(
		-- INGRESSI
		Start: IN STD_LOGIC;
		RST: IN STD_LOGIC;
		CLK: IN STD_LOGIC;
		
		-- USCITE
		Control: OUT STD_LOGIC_VECTOR(16 DOWNTO 0)

	);
END CU;

ARCHITECTURE Structural OF CU IS

type MEM_16x24 is array (0 to 15) of STD_LOGIC_VECTOR(0 to 23);
type MEM_18x12 is array (0 to 17) of STD_LOGIC_VECTOR(0 to 11);


	CONSTANT micro_rom : 
		Mem_16x24 := ("100001000001010010000000", -- Stato
						  "110000000110000100010010", -- 
						  "000101010100110000010110", -- 
						  "000111011010000010011100", --
						  "010011100000110010000001", --
						  "100000001110010010100010",
						  "101010001100001000011110",
						  "101100001010000110011000",
						  "101110001000000011010000",
						  "010011000010000010000100",
						  "100001000001100001000001",
						  "100001000001100001000001",
						  "100001000001100001000001",
						  "100001000001100001000001",
						  "100001000001100001000001",
						  "100001000001100001000001"
						 );

	CONSTANT comm_generator : 
		Mem_18x12 := ("110011000000", -- S1
						  "101011010000", -- S2
						  "100100011000", -- S3
						  "100000010100", -- S4
						  "100000100000", -- S5_N
						  "100000110000", -- S6_N
						  "100000010001", -- S7_N
						  "100000010011", -- S8_N
						  "110011100000", -- S5_s
						  "101011110000", -- S6_s
						  "100100011001", -- S7_s
						  "100000010111", -- S8_s
						  "110011110000", -- S5_N1
						  "101011010001", -- S5_N2
						  "100100011011", -- S5_N3
						  "110011010101", -- S6_N1
						  "101011010011", -- S6_N2
						  "110011011011"  -- S7_N1
						 );
						 
						   

	COMPONENT Mux_2to1_Nbit_stdlogic
		GENERIC (N : integer := 16);
		PORT(   
			Mux_2to1_Nbit_IN_1, Mux_2to1_Nbit_IN_2: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
			Mux_2to1_Nbit_SEL : IN STD_LOGIC;
			Mux_2to1_Nbit_OUT : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT Mux_2to1_stdlogic
		PORT(   
			Mux_2to1_IN_1, Mux_2to1_IN_2: IN STD_LOGIC;
			Mux_2to1_SEL : IN STD_LOGIC;
			Mux_2to1_OUT : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT Register_n_stdlogic 
		GENERIC (N : integer := 16);
		PORT (
			Register_D : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN STD_LOGIC;
			Register_Q : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;
	
	COMPONENT Register_n_stdlogic_PHI_B
		GENERIC (N : integer := 16);
		PORT (
			Register_D : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0); -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN STD_LOGIC;
			Register_Q : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0) -- Segnale di uscita
		);
	END COMPONENT;
	
	COMPONENT Register_stdlogic 
		PORT (
			Register_D : IN STD_LOGIC; -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN STD_LOGIC;
			Register_Q : OUT STD_LOGIC -- Segnale di uscita
		);
	END COMPONENT;
	
	COMPONENT Register_stdlogic_PHI_B
		PORT (
			Register_D : IN STD_LOGIC; -- Segnale che viene riportato in uscita al colpo di clock successivo
			Register_Clock, Register_Reset, Register_LOAD: IN STD_LOGIC;
			Register_Q : OUT STD_LOGIC -- Segnale di uscita
		);
	END COMPONENT;

SIGNAL Mux_mem_IN_A_s, Mux_mem_IN_B_s, Mux_mem_OUT_s: STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL uPC_reg_OUT_s: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL Instr_reg_OUT_s: STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL Mux_pla_OUT_s, uPC_sel_reg_OUT_s, Mux_jump_OUT_s: STD_LOGIC;
SIGNAL Mux_control_IN_B_s: STD_LOGIC_VECTOR(16 DOWNTO 0);
SIGNAL micro_rom_OUT_s: STD_LOGIC_VECTOR(23 DOWNTO 0);

BEGIN
	micro_rom_OUT_s <= micro_rom(to_integer(unsigned(uPC_reg_OUT_s)));
	Mux_mem_IN_A_s <= micro_rom_OUT_s(23 DOWNTO 12);
	Mux_mem_IN_B_s <= micro_rom_OUT_s(11 DOWNTO 0);
	
	Mux_mem: Mux_2to1_Nbit_stdlogic GENERIC MAP ( N => 12 )
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => Mux_mem_IN_A_s,
				  	Mux_2to1_Nbit_IN_2 => Mux_mem_IN_B_s,
				  	Mux_2to1_Nbit_SEL => Mux_jump_OUT_s,
				  	Mux_2to1_Nbit_OUT => Mux_mem_OUT_s
				);
				
	Instr_Reg: Register_n_stdlogic GENERIC MAP ( N => 12 )
   			   PORT MAP (
				 Register_D => Mux_mem_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => '0',
				 Register_LOAD => '1',
				 Register_Q => Instr_reg_OUT_s
			   );
	
	   
	Mux_PLA: Mux_2to1_stdlogic
				PORT MAP (
				  	Mux_2to1_IN_1 => Instr_reg_OUT_s(6),
				  	Mux_2to1_IN_2 => Start,
				  	Mux_2to1_SEL => Instr_reg_OUT_s(11),
				  	Mux_2to1_OUT => Mux_pla_OUT_s
				); 
				
	uPC_sel_REG: Register_stdlogic_PHI_B
   			   PORT MAP (
				 Register_D => Mux_pla_OUT_s,
				 Register_Clock => CLK,
				 Register_Reset => RST,
				 Register_LOAD => '1',
				 Register_Q => uPC_sel_reg_OUT_s
			   );
			   
	Mux_JUMP: Mux_2to1_stdlogic
				PORT MAP (
				  	Mux_2to1_IN_1 => uPC_sel_reg_OUT_s,
				  	Mux_2to1_IN_2 => Mux_pla_OUT_s,
				  	Mux_2to1_SEL => Instr_reg_OUT_s(11),
				  	Mux_2to1_OUT => Mux_jump_OUT_s
				); 
	
	uPC_REG: Register_n_stdlogic_PHI_B GENERIC MAP ( N => 4 )
   			   PORT MAP (
				 Register_D => Instr_reg_OUT_s(10 DOWNTO 7),
				 Register_Clock => CLK,
				 Register_Reset => RST,
				 Register_LOAD => '1',
				 Register_Q => uPC_reg_OUT_s
			   );
			   
	Mux_control: Mux_2to1_Nbit_stdlogic GENERIC MAP ( N => 17 )
				PORT MAP (
				  	Mux_2to1_Nbit_IN_1 => Mux_control_IN_B_s(16 DOWNTO 0),
				  	Mux_2to1_Nbit_IN_2 => "10000001000000011", -- STATO DI IDLE (L'MSB è l'enable dello shift reg_done)
				  	Mux_2to1_Nbit_SEL => Instr_reg_OUT_s(0),
				  	Mux_2to1_Nbit_OUT => Control
				); 
	
	Mux_control_IN_B_s <= comm_generator(to_integer(unsigned(Instr_reg_OUT_s(5 DOWNTO 1)))) & "11111";
	
				
END Structural;