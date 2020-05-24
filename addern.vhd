library IEEE;
use IEEE.std_logic_1164.all;

entity addern is
    generic (
        N: integer := 4
    );
    port (
        a, b: in std_logic_vector(N - 1 downto 0);
        cin: in std_logic;

        s: out std_logic_vector(N - 1 downto 0);
        cout: out std_logic
    );
end;

architecture addern_arq of addern is
    signal c: std_logic_vector(N downto 0);
begin
    adders: for i in N - 1 downto 0 generate
        adder1: entity work.adder1
            port map(
                a => a(i),
                b => b(i),
                cin => c(i),

                s => s(i),
                cout => c(i + 1)
            );
    end generate;
    c(0) <= cin;
    cout <= c(N);
end;

