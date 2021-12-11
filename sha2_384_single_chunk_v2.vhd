--Implementation based upon https://csrc.nist.gov/csrc/media/publications/fips/180/2/archive/2002-08-01/documents/fips180-2.pdf
--and https://en.wikipedia.org/wiki/SHA-2

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

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

ENTITY sha2_384_single_chunk is
	 Port ( reset	: in  STD_LOGIC;
			clock	: in  STD_LOGIC;
			--input side signals
			plain	: in  STD_LOGIC_VECTOR(1023 downto 0);
			load	: in  STD_LOGIC;
			empty	: out STD_LOGIC;
			--output side signals
			digest	: out STD_LOGIC_VECTOR (383 downto 0);
			ready	: out STD_LOGIC);
end sha2_384_single_chunk;

ARCHITECTURE Behavioral of sha2_384_single_chunk is

	type initT is array (0 to 7) of STD_LOGIC_VECTOR(63 downto 0);
	constant init : initT := (
		x"cbbb9d5dc1059ed8", x"629a292a367cd507", x"9159015a3070dd17", x"152fecd8f70e5939", 
        x"67332667ffc00b31", x"8eb44a8768581511", x"db0c2e0d64f98fa7", x"47b5481dbefa4fa4");
	type kT is array (0 to 84) of STD_LOGIC_VECTOR(63 downto 0);
	constant k : kT := (
		x"428a2f98d728ae22", x"7137449123ef65cd", x"b5c0fbcfec4d3b2f", x"e9b5dba58189dbbc", x"3956c25bf348b538", 
		x"59f111f1b605d019", x"923f82a4af194f9b", x"ab1c5ed5da6d8118", x"d807aa98a3030242", x"12835b0145706fbe", 
		x"243185be4ee4b28c", x"550c7dc3d5ffb4e2", x"72be5d74f27b896f", x"80deb1fe3b1696b1", x"9bdc06a725c71235", 
		x"c19bf174cf692694", x"e49b69c19ef14ad2", x"efbe4786384f25e3", x"0fc19dc68b8cd5b5", x"240ca1cc77ac9c65", 
		x"2de92c6f592b0275", x"4a7484aa6ea6e483", x"5cb0a9dcbd41fbd4", x"76f988da831153b5", x"983e5152ee66dfab", 
		x"a831c66d2db43210", x"b00327c898fb213f", x"bf597fc7beef0ee4", x"c6e00bf33da88fc2", x"d5a79147930aa725", 
		x"06ca6351e003826f", x"142929670a0e6e70", x"27b70a8546d22ffc", x"2e1b21385c26c926", x"4d2c6dfc5ac42aed", 
		x"53380d139d95b3df", x"650a73548baf63de", x"766a0abb3c77b2a8", x"81c2c92e47edaee6", x"92722c851482353b", 
		x"a2bfe8a14cf10364", x"a81a664bbc423001", x"c24b8b70d0f89791", x"c76c51a30654be30", x"d192e819d6ef5218", 
		x"d69906245565a910", x"f40e35855771202a", x"106aa07032bbd1b8", x"19a4c116b8d2d0c8", x"1e376c085141ab53", 
		x"2748774cdf8eeb99", x"34b0bcb5e19b48a8", x"391c0cb3c5c95a63", x"4ed8aa4ae3418acb", x"5b9cca4f7763e373", 
		x"682e6ff3d6b2b8a3", x"748f82ee5defb2fc", x"78a5636f43172f60", x"84c87814a1f0ab72", x"8cc702081a6439ec", 
		x"90befffa23631e28", x"a4506cebde82bde9", x"bef9a3f7b2c67915", x"c67178f2e372532b", x"ca273eceea26619c", 
		x"d186b8c721c0c207", x"eada7dd6cde0eb1e", x"f57d4f7fee6ed178", x"06f067aa72176fba", x"0a637dc5a2c898a6", 
		x"113f9804bef90dae", x"1b710b35131c471b", x"28db77f523047d84", x"32caab7b40c72493", x"3c9ebe0a15c9bebc", 
		x"431d67c49c100d4c", x"4cc5d4becb3e42b6", x"597f299cfc657e2a", x"5fcb6fab3ad6faec", x"6c44198c4a475817",
		x"0000000000000000", x"0000000000000000", x"0000000000000000", x"0000000000000000", x"0000000000000000");
	signal a, b, c, d, e, f, g, h : STD_LOGIC_VECTOR(63 downto 0);
	signal k_reg, w_reg, s0, s1, su0, su1, maj, ch, temp1, temp2 : STD_LOGIC_VECTOR(63 downto 0);
	type wT is array (15 downto 0) of STD_LOGIC_VECTOR(63 downto 0);
	signal w : wT;
	signal wCNT, chunkCNT : STD_LOGIC_VECTOR(6 downto 0);
	signal enable_pipe : STD_LOGIC_VECTOR(1 DOWNTO 0);
	signal da, db, dc, dd, de, df : STD_LOGIC_VECTOR(63 downto 0);

BEGIN

	fsm: process(clock)
	begin
		if rising_edge(clock) then
			if reset = '1' then
				chunkCNT <= "1010010";
				enable_pipe <= "00";
			else
			    enable_pipe(1) <= enable_pipe(0);
				if chunkCNT = "1010010" then
					if load = '1' then
						chunkCNT <= "0000000";
						enable_pipe(0) <= '1';
					end if;
				else
					chunkCNT <= chunkCNT + '1';
				end if;
				if chunkCNT = "1001111" then --0..79 rounds
					enable_pipe(0) <= '0';
				end if;
			end if;
		end if;
	end process;
	
	extension_pipe: process(clock)
		variable i : integer;
	begin
		if rising_edge(clock) then
			if enable_pipe(0) = '1' then
				w <= w(14 downto 0) & (w(15) + s0 + w(6) + s1);
			elsif load = '1' then
				for i in 0 to 15 loop
					w(i) <= plain((i+1)*64-1 downto i*64);
				end loop;
			end if;
		end if;
	end process;
	
	--extension_pipe asynchron circuitry
	s0 <= (w(14)(0) & w(14)(63 downto 1)) xor (w(14)(7 downto 0) & w(14)(63 downto 8)) xor ("0000000" & w(14)(63 downto 7));
	s1 <= (w(1)(18 downto 0) & w(1)(63 downto 19)) xor (w(1)(60 downto 0) & w(1)(63 downto 61)) xor ("000000" & w(1)(63 downto 6));
	--end of extension_pipe asynchron circuitry

    k_ram : process(clock)
    begin
        if rising_edge(clock) then
			if enable_pipe(0) = '1' then
                k_reg <= k(CONV_INTEGER(chunkCNT));
                w_reg <= w(15);
            end if;
        end if;
    end process;

	main_loop_pipe: process(clock)
	begin
		if rising_edge(clock) then
			if enable_pipe(1) = '1' then
				h <= g;
				g <= f;
				f <= e;
				e <= d + temp1;
				d <= c;
				c <= b;
				b <= a;
				a <= temp2;
			elsif load = '1' then
				a <= init(0);
				b <= init(1);
				c <= init(2);
				d <= init(3);
				e <= init(4);
				f <= init(5);
				g <= init(6);
				h <= init(7);				
			end if;
		end if;
	end process;

	--main_loop_pipe asynchron circuitry
	su0 <= (a(27 downto 0) & a(63 downto 28)) xor (a(33 downto 0) & a(63 downto 34)) xor (a(38 downto 0) & a(63 downto 39));
	su1 <= (e(13 downto 0) & e(63 downto 14)) xor (e(17 downto 0) & e(63 downto 18)) xor (e(40 downto 0) & e(63 downto 41));
    ch <= (e and f) xor ((not e) and g);
	temp1 <= h + su1 + ch + k_reg + w_reg;
	maj <= (a and (b xor c)) xor (b and c);
	temp2 <= temp1 + su0 + maj;
	--end of main_loop_pipe asynchron circuitry
	
	output_register : process(clock) 
	begin 
		if rising_edge(clock) then
			if reset = '1' then
			     ready <= '0';
			else
                if chunkCNT = "1010001" then
                    da <= a + init(0);
                    db <= b + init(1);
                    dc <= c + init(2);
                    dd <= d + init(3);
                    de <= e + init(4);
                    df <= f + init(5);
                    ready <= '1';
                else
                    ready <= '0';
                end if;
            end if;
        end if;
	end process;
	
	empty <= not enable_pipe(0);
	
	digest <= da & db & dc & dd & de & df;

end Behavioral;
