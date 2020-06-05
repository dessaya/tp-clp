library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    port(
            a: in  std_logic;
            b: in  std_logic;
            p: out  std_logic;
            clk: in std_logic
        );
end main;

architecture Behavioral of main is
    signal a_num: std_logic_vector(31 downto 0);
    signal b_num: std_logic_vector(31 downto 0);
    signal p_num: std_logic_vector(31 downto 0);
begin
    in_a: entity work.ser2par
    generic map (DATA_W => 32)
    port map (
                 clk => clk,
                 rst => '0',
                 data_in =>     a,
                 frame_in =>    '1',
                 rd => '0',
                 data_out =>    a_num
             );
    in_b: entity work.ser2par
    generic map (DATA_W => 32)
    port map (
                 clk => clk,
                 rst => '0',
                 data_in =>     b,
                 frame_in =>    '1',
                 rd => '0',
                 data_out =>    b_num
             );

    fp: entity work.fpmul
    port map (
                 a => a_num,
                 b => b_num,
                 p => p_num
             );

    p_out: entity work.par2ser
    generic map (DATA_W => 32)
    port map (
                 clk => clk,
                 rst => '0',
                 data_in => p_num,
                 load => '1',
                 data_out => p
             );


end Behavioral;
