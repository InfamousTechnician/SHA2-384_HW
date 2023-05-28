
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY sha2_384_tb IS
END sha2_384_tb;
 
ARCHITECTURE behavior OF sha2_384_tb IS 
 
	 -- Component Declaration for the Unit Under Test (UUT)
 
	 COMPONENT sha2_384_single_chunk
	 Port ( reset	 : in  STD_LOGIC;
			clock	 : in  STD_LOGIC;
			--input side signals
			plain	 : in  STD_LOGIC_VECTOR(1023 downto 0);
			load : in  STD_LOGIC;
			empty	: out STD_LOGIC;
			--output side signals
			digest	: out STD_LOGIC_VECTOR (383 downto 0);
			ready	 : out STD_LOGIC);
	 END COMPONENT;
	 

	--Inputs
	signal reset : std_logic := '0';
	signal clock : std_logic := '0';
	signal plain : std_logic_vector(1023 downto 0) := (others => '0');
	signal load : std_logic := '0';

 	--Outputs
	signal digest : std_logic_vector(383 downto 0);
	signal testPassed, ready, empty : std_logic;
	
	-- Clock period definitions
	constant clock_period : time := 10 ns;
	--standard"s test vector's result
	constant hash2b : std_logic_vector(383 downto 0) := x"CB00753F45A35E8BB5A03D699AC65007272C32AB0EDED1631A8B605A43FF5BED8086072BA1E7CC2358BAECA134C825A7"; --expected for ""
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: sha2_384_single_chunk PORT MAP (
			 reset => reset,
			 clock => clock,
			 plain => plain,
			 load => load,
			 digest => digest,
			 ready => ready,
			 empty => empty
		  );

	-- Clock process definitions
	clock_process :process
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process;
 

	-- Stimulus process
	stim_proc: process
	begin		
		reset <= '1';
		wait for clock_period;
		reset <= '0';
		load <= '1';
		--test vector from the internet for the empty string
		plain <= x"6162638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018";
		wait for clock_period;
		load <= '0';
		plain <= (others => '0');
		wait for clock_period*90;
		wait;
	end process;

testPassed <= '1' when hash2b = digest else '0';

END;
