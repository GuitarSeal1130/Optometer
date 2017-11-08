library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity Optometer is
	port(clk: in std_logic;
		 pwr: in std_logic;
		 
		 kbrow: in std_logic_vector(3 downto 0);
		 kbcol: out std_logic_vector(3 downto 0);
		 ld: out std_logic_vector(3 downto 0);
		 led:out std_logic;
		 
		 
		 row: out std_logic_vector(7 downto 0);
		 col_g: out std_logic_vector(7 downto 0);
		 col_r: out std_logic_vector(7 downto 0);
		 
		 cat: out std_logic_vector(7 downto 0);
		 digit: out std_logic_vector(7 downto 0));

end Optometer;


architecture a of Optometer is
signal clkcnt1: integer range 0 to 249999; 
signal clktmp1: std_logic; --100Hz,10ms
signal cnt1: integer range 0 to 7;

signal clkcnt2: integer range 0 to 24999999; 
signal clktmp2: std_logic; --1Hz,1s
signal cnt2: integer range 0 to 6;

signal ran:integer range 1 to 4;

signal kbbuf0,kbbuf1,kbbuf2,kbbuf3,kbbuf4: integer range 0 to 5;
signal kbcolstate: integer range 1 to 3;
signal ans: std_logic_vector(1 downto 0);
signal cnfrm: std_logic;

type all_state is (n,
				   a1,a2,a3,a4,
				   b1,b2,b3,b4,
				   c1,c2,c3,c4,
				   d1,d2,d3,d4,
				   e1,e2,e3,e4,
				   f1,f2,f3,f4,
				   g1,g2,g3,g4,
				   h1,h2,h3,h4,
				   false,a0,b0,c0,d0,e0,f0,g0,h0);
signal curstate,nxtstate: all_state;

signal cnt3: integer range 1 to 42;


begin

	--Scanning Frequency--
	process(clk)
	begin
		if clk'event and clk='1' then
			if clkcnt1=2499 then
				clkcnt1<=0;
				clktmp1<= not clktmp1;
			else
				clkcnt1<=clkcnt1+1;
			end if;
		end if;
	end process;
	
	process(clktmp1)
	begin
		if clktmp1'event and clktmp1='1' then
			if cnt1=7 then
				cnt1<=0;
			else 
				cnt1<=cnt1+1;
			end if;
		end if;
	end process;
	
	
	--Count-Down--
	process(clk)
	begin
		if clk'event and clk='1' then
			if clkcnt2=24999999 then
				clkcnt2<=0;
				clktmp2<= not clktmp2;
			else
				clkcnt2<=clkcnt2+1;
			end if;
		end if;
	end process;
	
	process(clktmp2,pwr)
	begin
		if pwr='1' then
			if clktmp2'event and clktmp2='1' then
				if cnt2 /= 6 then
					cnt2<=cnt2+1;
				end if;
			end if;
		else
			cnt2<=0;
		end if;
	end process;
	
	
	--Random Number
	process(clktmp1)
	begin
		if clktmp1'event and clktmp1='1' then
			if ran=4 then
				ran<=1;
			else 
				ran<=ran+1;
			end if;
		end if;
	end process;
	
	
	--Keyboard Anti-Quiver & Scanning--

	process(clktmp1)
	begin
		if clktmp1'event and clktmp1='1' then
			case kbcolstate is
				when 3 =>
					kbcol<="1101";
					kbcolstate<=1;
					if kbrow="1011" then 
						if kbbuf3=2 then
							ld<="0100";
							ans<="11";
							cnfrm<='0';
							led<='0';
							kbbuf3<=0;
						else
							kbbuf3<=kbbuf3+1;
						end if;
					else 
						kbbuf3<=0;
					end if;
	
				when 1 =>
					kbcol<="1011";
					kbcolstate<=2;
					case  kbrow is
						when "0111" =>
							if kbbuf2=2 then
								ld<="0010";
								ans<="10";
								cnfrm<='0';
								led<='0';	
								kbbuf2<=0;
							else
								kbbuf2<=kbbuf2+1;
							end if;
					
						when "1011" =>
							if kbbuf0=2 then
								cnfrm<='1';
								led<='1';
								ld<="0000";
							else
								kbbuf0<=kbbuf0+1;
							end if;
							

						when "1101" =>
							if kbbuf4=2 then
								ld<="1000";
								ans<="00";
								cnfrm<='0';
								led<='0';
								kbbuf4<=0;
							else
								kbbuf4<=kbbuf4+1;
							end if;
					
						when others =>
							kbbuf2<=0;
							kbbuf4<=0;
						
					end case;
					
				when 2=> 
					kbcol<="1110";
					kbcolstate<=3;
					if kbrow="1011" then
						if kbbuf1=2 then
							ld<="0001";
							ans<="01";
							cnfrm<='0';
							led<='0';
							kbbuf1<=0;
						else
							kbbuf1<=kbbuf1+1;
						end if;
					else
						kbbuf1<=0;
					end if;
					
			end case;
		end if;
	end process;

												
	--State Machine--
	process(curstate,ans,ran)
	begin
			case curstate is
				when e1 =>
					cnt3 <= 5;
					if ans="01" then
						case ran is
							when 1 => nxtstate <= f1;
							when 2 => nxtstate <= f2;
							when 3 => nxtstate <= f3;
							when 4 => nxtstate <= f4;
						end case;
					else 
						case ran is
							when 1 => nxtstate <= d1;
							when 2 => nxtstate <= d2;
							when 3 => nxtstate <= d3;
							when 4 => nxtstate <= d4;
						end case;
					end if;
				
				when a1 =>
					cnt3 <= 1;
					if ans="01" then
						nxtstate <= a0;
					else 
						nxtstate <= false;
					end if;
				
				when b1 =>
					cnt3 <= 2;
					if ans="01" then
						nxtstate <= b0;
					else 
						case ran is
							when 1 => nxtstate <= a1;
							when 2 => nxtstate <= a2;
							when 3 => nxtstate <= a3;
							when 4 => nxtstate <= a4;
						end case;
					end if;
				
				when c1 =>
					cnt3 <= 3;
					if ans="01" then
						nxtstate <= c0;
					else 
						case ran is
							when 1 => nxtstate <= b1;
							when 2 => nxtstate <= b2;
							when 3 => nxtstate <= b3;
							when 4 => nxtstate <= b4;
						end case;
					end if;
				
				when d1 =>
					cnt3 <= 4;
					if ans="01" then
						nxtstate <= d0;
					else 
						case ran is
							when 1 => nxtstate <= c1;
							when 2 => nxtstate <= c2;
							when 3 => nxtstate <= c3;
							when 4 => nxtstate <= c4;
						end case;
					end if;
				
				when f1 =>
					cnt3 <= 6;
					if ans="01" then
						case ran is
							when 1 => nxtstate <= g1;
							when 2 => nxtstate <= g2;
							when 3 => nxtstate <= g3;
							when 4 => nxtstate <= g4;
						end case;
					else 
						nxtstate <= e0;
					end if;
				
				when g1 =>
					cnt3 <= 7;
					if ans="01" then
						case ran is
							when 1 => nxtstate <= h1;
							when 2 => nxtstate <= h2;
							when 3 => nxtstate <= h3;
							when 4 => nxtstate <= h4;
						end case;
					else 
						nxtstate <= f0;
					end if;
				
				when h1 =>	
					cnt3 <= 8;
					if ans="01" then
						nxtstate <= h0;
					else 
						nxtstate <= g0;
					end if;
					
				when e2 =>
					cnt3 <= 14;
					if ans="10" then
						case ran is
							when 1 => nxtstate <= f1;
							when 2 => nxtstate <= f2;
							when 3 => nxtstate <= f3;
							when 4 => nxtstate <= f4;
						end case;
					else 
						case ran is
							when 1 => nxtstate <= d1;
							when 2 => nxtstate <= d2;
							when 3 => nxtstate <= d3;
							when 4 => nxtstate <= d4;
						end case;
					end if;
				
				when a2 =>
					cnt3 <= 10;
					if ans="10" then
						nxtstate <= a0;
					else 
						nxtstate <= false;
					end if;
				
				when b2 =>
					cnt3 <= 11;
					if ans="10" then
						nxtstate <= b0;
					else 
						case ran is
							when 1 => nxtstate <= a1;
							when 2 => nxtstate <= a2;
							when 3 => nxtstate <= a3;
							when 4 => nxtstate <= a4;
						end case;
					end if;
				
				when c2 =>
					cnt3 <= 12;
					if ans="10" then
						nxtstate <= c0;
					else 
						case ran is
							when 1 => nxtstate <= b1;
							when 2 => nxtstate <= b2;
							when 3 => nxtstate <= b3;
							when 4 => nxtstate <= b4;
						end case;
					end if;
				
				when d2 =>
					cnt3 <= 13;
					if ans="10" then
						nxtstate <= d0;
					else 
						case ran is
							when 1 => nxtstate <= c1;
							when 2 => nxtstate <= c2;
							when 3 => nxtstate <= c3;
							when 4 => nxtstate <= c4;
						end case;
					end if;
				
				when f2 =>
					cnt3 <= 15;
					if ans="10" then
						case ran is
							when 1 => nxtstate <= g1;
							when 2 => nxtstate <= g2;
							when 3 => nxtstate <= g3;
							when 4 => nxtstate <= g4;
						end case;
					else 
						nxtstate <= e0;
					end if;
				
				when g2 =>
					cnt3 <= 16;
					if ans="10" then
						case ran is
							when 1 => nxtstate <= h1;
							when 2 => nxtstate <= h2;
							when 3 => nxtstate <= h3;
							when 4 => nxtstate <= h4;
						end case;
					else 
						nxtstate <= f0;
					end if;
				
				when h2 =>	
					cnt3 <= 17;
					if ans="10" then
						nxtstate <= h0;
					else 
						nxtstate <= g0;
					end if;
				
				when e3 =>
					cnt3 <= 22;
					if ans="00" then
						case ran is
							when 1 => nxtstate <= f1;
							when 2 => nxtstate <= f2;
							when 3 => nxtstate <= f3;
							when 4 => nxtstate <= f4;
						end case;
					else 
						case ran is
							when 1 => nxtstate <= d1;
							when 2 => nxtstate <= d2;
							when 3 => nxtstate <= d3;
							when 4 => nxtstate <= d4;
						end case;
					end if;	
				
				when a3 =>
					cnt3 <= 18;
					if ans="00" then
						nxtstate <= a0;
					else 
						nxtstate <= false;
					end if;
				
				when b3 =>
					cnt3 <= 19;
					if ans="00" then
						nxtstate <= b0;
					else 
						case ran is
							when 1 => nxtstate <= a1;
							when 2 => nxtstate <= a2;
							when 3 => nxtstate <= a3;
							when 4 => nxtstate <= a4;
						end case;
					end if;
				
				when c3 =>
					cnt3 <= 20;
					if ans="00" then
						nxtstate <= c0;
					else 
						case ran is
							when 1 => nxtstate <= b1;
							when 2 => nxtstate <= b2;
							when 3 => nxtstate <= b3;
							when 4 => nxtstate <= b4;
						end case;
					end if;
				
				when d3 =>
					cnt3 <= 21;
					if ans="00" then
						nxtstate <= d0;
					else 
						case ran is
							when 1 => nxtstate <= c1;
							when 2 => nxtstate <= c2;
							when 3 => nxtstate <= c3;
							when 4 => nxtstate <= c4;
						end case;
					end if;
				
				when f3 =>
					cnt3 <= 23;
					if ans="00" then
						case ran is
							when 1 => nxtstate <= g1;
							when 2 => nxtstate <= g2;
							when 3 => nxtstate <= g3;
							when 4 => nxtstate <= g4;
						end case;
					else 
						nxtstate <= e0;
					end if;
				
				when g3 =>
					cnt3 <= 24;
					if ans="00" then
						case ran is
							when 1 => nxtstate <= h1;
							when 2 => nxtstate <= h2;
							when 3 => nxtstate <= h3;
							when 4 => nxtstate <= h4;
						end case;
					else 
						nxtstate <= f0;
					end if;
				
				when h3 =>	
					cnt3 <= 25;
					if ans="00" then
						nxtstate <= h0;
					else 
						nxtstate <= g0;
					end if;
					
				when e4 =>
					cnt3 <= 30;
					if ans="11" then
						case ran is
							when 1 => nxtstate <= f1;
							when 2 => nxtstate <= f2;
							when 3 => nxtstate <= f3;
							when 4 => nxtstate <= f4;
						end case;
					else 
						case ran is
							when 1 => nxtstate <= d1;
							when 2 => nxtstate <= d2;
							when 3 => nxtstate <= d3;
							when 4 => nxtstate <= d4;
						end case;
					end if;
					
				when a4 =>
					cnt3 <= 26;
					if ans="11" then
						nxtstate <= a0;
					else 
						nxtstate <= false;
					end if;
				
				when b4 =>
					cnt3 <= 27;
					if ans="11" then
						nxtstate <= b0;
					else 
						case ran is
							when 1 => nxtstate <= a1;
							when 2 => nxtstate <= a2;
							when 3 => nxtstate <= a3;
							when 4 => nxtstate <= a4;
						end case;
					end if;
				
				when c4 =>
					cnt3 <= 28;
					if ans="11" then
						nxtstate <= c0;
					else 
						case ran is
							when 1 => nxtstate <= b1;
							when 2 => nxtstate <= b2;
							when 3 => nxtstate <= b3;
							when 4 => nxtstate <= b4;
						end case;
					end if;
				
				when d4 =>
					cnt3 <= 29;
					if ans="11" then
						nxtstate <= d0;
					else 
						case ran is
							when 1 => nxtstate <= c1;
							when 2 => nxtstate <= c2;
							when 3 => nxtstate <= c3;
							when 4 => nxtstate <= c4;
						end case;
					end if;
				
				when f4 =>
					cnt3 <= 31;
					if ans="11" then
						case ran is
							when 1 => nxtstate <= g1;
							when 2 => nxtstate <= g2;
							when 3 => nxtstate <= g3;
							when 4 => nxtstate <= g4;
						end case;
					else 
						nxtstate <= e0;
					end if;
				
				when g4 =>
					cnt3 <= 32;
					if ans="11" then
						case ran is
							when 1 => nxtstate <= h1;
							when 2 => nxtstate <= h2;
							when 3 => nxtstate <= h3;
							when 4 => nxtstate <= h4;
						end case;
					else 
						nxtstate <= f0;
					end if;
				
				when h4 =>	
					cnt3 <= 33;
					if ans="11" then
						nxtstate <= h0;
					else 
						nxtstate <= g0;
					end if;
				
				when false => nxtstate <= false; cnt3 <= 9;
				when a0 => nxtstate <= a0; cnt3 <= 34;
				when b0 => nxtstate <= b0; cnt3 <= 35;
				when c0 => nxtstate <= c0; cnt3 <= 36;
				when d0 => nxtstate <= d0; cnt3 <= 37;
				when e0 => nxtstate <= e0; cnt3 <= 38;
				when f0 => nxtstate <= f0; cnt3 <= 39;
				when g0 => nxtstate <= g0; cnt3 <= 40;
				when h0 => nxtstate <= h0; cnt3 <= 41;
				when n=> nxtstate <= n; cnt3 <= 42;
			end case;
	end process;
	
	process (cnfrm,pwr,ran)
	begin
		if  pwr='0' then
			curstate <= n;
		elsif curstate=n and pwr='1' then
			case ran is
				when 1 => curstate <= e1;
				when 2 => curstate <= e2;
				when 3 => curstate <= e3;
				when 4 => curstate <= e4;
			end case;
		else
			if cnfrm'event and cnfrm='1' then
				curstate <= nxtstate;
			end if;
		end if;
	end process;
			
				
	--Display Encoding--
	process(cnt1,cnt2,cnt3)
	begin
		case cnt3 is
	
			when 1 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01111110"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01111110"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100000";
				end case;
				
			when 2 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01111100"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01111100"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 3 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01111100"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01111100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100110";
				end case;
				
			when 4 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00100000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10111110";
				end case;
				
			when 5 => 
				case cnt2 is
					when 0 => row<="11111111"; col_r<="00000000"; col_g<="00000000";
					when 1 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="10110110";
							when 1 => row <="10111111"; col_r<="00100000"; col_g<="00100000"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00100000"; col_g<="00100000"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 2 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00100100"; col_g<="00100100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00100100"; col_g<="00100100"; cat<="10111111"; digit<="01100110";
							when 2 => row <="11011111"; col_r<="00100100"; col_g<="00100100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 3 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="11110010";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 4 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="11011010";
							when 4 => row <="11110111"; col_r<="00100000"; col_g<="00100000"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00100000"; col_g<="00100000"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00100000"; col_g<="00100000"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 5 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000100"; col_g<="00000100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000100"; col_g<="00000100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="01100000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;
					when 6 =>
						case cnt1 is
							when 0 => row <="01111111"; col_g<="00000000";col_r<="00000000"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_g<="00000000";col_r<="00000000"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_g<="00111100";col_r<="00000000"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_g<="00100000";col_r<="00000000"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_g<="00100000";col_r<="00000000"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_g<="00111100";col_r<="00000000"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_g<="00000000";col_r<="00000000"; cat<="11111101"; digit<="11111101";
							when 7 => row <="11111110"; col_g<="00000000";col_r<="00000000"; cat<="11111110"; digit<="11111110";
						end case;	
				end case;	
				
			when 6 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00111000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00100000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00111000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11111100";
				end case;	
				
			when 7 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00111000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00111000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;	
				
			when 8 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00011000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00010000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00011000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10110110";
				end case;			

			
			when 9=> 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00011000"; col_r<="00011000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00011000"; col_r<="00011000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00100100"; col_r<="00100100"; cat<="11111011"; digit<="11111101";
					when 6 => row <="11111101"; col_g<="01000010"; col_r<="01000010"; cat<="11111101"; digit<="01100000";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="00000010";
				end case;
				
			
			when 10 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01111110"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100000";
				end case;
				
			when 11=> 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01111110"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 12 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01111100"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100110";
				end case;
				
			when 13 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01111100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10111110";
				end case;
				
			when 14 => 
				case cnt2 is
					when 0 => row<="11111111"; col_r<="00000000"; col_g<="00000000";
					when 1 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="10110110";
							when 1 => row <="10111111"; col_r<="00100000"; col_g<="00100000"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00100000"; col_g<="00100000"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 2 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00100100"; col_g<="00100100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00100100"; col_g<="00100100"; cat<="10111111"; digit<="01100110";
							when 2 => row <="11011111"; col_r<="00100100"; col_g<="00100100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 3 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="11110010";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 4 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="11011010";
							when 4 => row <="11110111"; col_r<="00100000"; col_g<="00100000"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00100000"; col_g<="00100000"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00100000"; col_g<="00100000"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 5 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000100"; col_g<="00000100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000100"; col_g<="00000100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="01100000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;
					when 6 =>
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000000"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000000"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000000"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000000"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000000"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000000"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000000"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
							when 7 => row <="11111110"; col_r<="00000000"; col_g<="00000000"; cat<="11111110"; digit<="11111110";
						end case;
				end case;
				
			when 15 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11111100";
				end case;
				
			when 16 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00101000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00101000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00111000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 17 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00101000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00111000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10110110";
				end case;
            when 18 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01111110"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01000010"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100000";
				end case;
				
			when 19=> 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01111110"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 20 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00111110"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100110";
				end case;
				
			when 21 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00111110"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00100010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10111110";
				end case;
				
			when 22 => 
				case cnt2 is
					when 0 => row<="11111111"; col_r<="00000000"; col_g<="00000000";
					when 1 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="10110110";
							when 1 => row <="10111111"; col_r<="00100000"; col_g<="00100000"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00100000"; col_g<="00100000"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 2 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00100100"; col_g<="00100100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00100100"; col_g<="00100100"; cat<="10111111"; digit<="01100110";
							when 2 => row <="11011111"; col_r<="00100100"; col_g<="00100100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 3 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="11110010";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 4 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="11011010";
							when 4 => row <="11110111"; col_r<="00100000"; col_g<="00100000"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00100000"; col_g<="00100000"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00100000"; col_g<="00100000"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 5 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000100"; col_g<="00000100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000100"; col_g<="00000100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="01100000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;
					when 6 =>
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000000"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000000"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000000"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000000"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000000"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000000"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000000"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
							when 7 => row <="11111110"; col_r<="00000000"; col_g<="00000000"; cat<="11111110"; digit<="11111110";
						end case;
				end case;
				
			when 23 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00100100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11111100";
				end case;
				
			when 24 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00011100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00010100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00010100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 25 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00011100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00010100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10110110";
				end case;
            when 26 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="01111110"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01111110"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100000";
				end case;
				
			when 27=> 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00111110"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111110"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 28 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00111110"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111110"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="01100110";
				end case;
				
			when 29 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111100"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10111110";
				end case;
				
			when 30 => 
				case cnt2 is
					when 0 => row<="11111111"; col_r<="00000000"; col_g<="00000000";
					when 1 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="10110110";
							when 1 => row <="10111111"; col_r<="00100000"; col_g<="00100000"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00100000"; col_g<="00100000"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 2 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00100100"; col_g<="00100100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00100100"; col_g<="00100100"; cat<="10111111"; digit<="01100110";
							when 2 => row <="11011111"; col_r<="00100100"; col_g<="00100100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 3 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="11110010";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;				
					when 4 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00111100"; col_g<="00111100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00111100"; col_g<="00111100"; cat<="11101111"; digit<="11011010";
							when 4 => row <="11110111"; col_r<="00100000"; col_g<="00100000"; cat<="11110111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00100000"; col_g<="00100000"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00100000"; col_g<="00100000"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00111100"; col_g<="00111100"; cat<="11111110"; digit<="00000000";
						end case;					
					when 5 =>                   
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000100"; col_g<="00000100"; cat<="01111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000100"; col_g<="00000100"; cat<="10111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000100"; col_g<="00000100"; cat<="11011111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000100"; col_g<="00000100"; cat<="11101111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000100"; col_g<="00000100"; cat<="11110111"; digit<="01100000";
							when 5 => row <="11111011"; col_r<="00000100"; col_g<="00000100"; cat<="11111011"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000100"; col_g<="00000100"; cat<="11111101"; digit<="00000000";
							when 7 => row <="11111110"; col_r<="00000100"; col_g<="00000100"; cat<="11111110"; digit<="00000000";
						end case;
					when 6 =>
						case cnt1 is
							when 0 => row <="01111111"; col_r<="00000000"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
							when 1 => row <="10111111"; col_r<="00000000"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
							when 2 => row <="11011111"; col_r<="00000000"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
							when 3 => row <="11101111"; col_r<="00000000"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
							when 4 => row <="11110111"; col_r<="00000000"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
							when 5 => row <="11111011"; col_r<="00000000"; col_g<="00111100"; cat<="11111111"; digit<="00000000";
							when 6 => row <="11111101"; col_r<="00000000"; col_g<="00000000"; cat<="11111101"; digit<="11111101";
							when 7 => row <="11111110"; col_r<="00000000"; col_g<="00000000"; cat<="11111110"; digit<="11111110";
						end case;
					end case;
				
			when 31 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00011100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00011100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11111100";
				end case;
				
			when 32 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00011100"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00000100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00011100"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 33 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00011000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00001000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="00011000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00000000"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; cat<="11111110"; digit<="10110110";
				end case;
			
			when 34 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00111100"; col_r<="00111100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01000010"; col_r<="01000010"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="01100000";
				end case;
				
			when 35=> 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00111100"; col_r<="00111100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01000010"; col_r<="01000010"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 36 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00111100"; col_r<="00111100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01000010"; col_r<="01000010"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="01100110";
				end case;
				
			when 37 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="00111100"; col_r<="00111100"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="01000010"; col_r<="01000010"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="10111110";
				end case;
				
			when 38 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111100"; col_r<="00111100"; cat<="11111101"; digit<="11111101";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="11111110";
				end case;
				
			when 39 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111100"; col_r<="00111100"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="11111100";
				end case;
				
			when 40 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111100"; col_r<="00111100"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="11011010";
				end case;
				
			when 41 => 
				case cnt1 is
					when 0 => row <="01111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="10111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11011111"; col_g<="00100100"; col_r<="00100100"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11101111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11110111"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111011"; col_g<="01000010"; col_r<="01000010"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111101"; col_g<="00111100"; col_r<="00111100"; cat<="11111101"; digit<="01100001";
					when 7 => row <="11111110"; col_g<="00000000"; col_r<="00000000"; cat<="11111110"; digit<="10110110";
				end case;
				
			when 42 => 
				case cnt1 is
					when 0 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 1 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 2 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 3 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 4 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 5 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 6 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
					when 7 => row <="11111111"; col_g<="00000000"; col_r<="00000000"; cat<="11111111"; digit<="00000000";
				end case;
			
		end case;		
    end process;
    
    
end a;

		
			
			