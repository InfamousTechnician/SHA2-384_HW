--Implementation based upon https://csrc.nist.gov/csrc/media/publications/fips/180/2/archive/2002-08-01/documents/fips180-2.pdf

--MIT License
--
--Copyright (c) 2021 Balazs Valer Fekete fbv81bp@outlook.hu fbv81bp@gmail.com
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

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
