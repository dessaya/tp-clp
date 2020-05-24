library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fpmul is
    generic (
        N: integer := 32;
        E: integer := 8
    );
    port (
        a, b: in std_logic_vector(N - 1 downto 0);
        p: out std_logic_vector(N - 1 downto 0)
    );
end;

architecture fpmul_arq of fpmul is
    constant NP: integer := N - E - 1;

    signal a_sign: std_logic;
    signal b_sign: std_logic;
    signal p_sign: std_logic;

    signal a_exp: std_logic_vector(E - 1 downto 0);
    signal b_exp: std_logic_vector(E - 1 downto 0);
    signal p_exp: std_logic_vector(E downto 0);

    signal a_frac: std_logic_vector(NP downto 0);
    signal b_frac: std_logic_vector(NP downto 0);
    signal p_frac: std_logic_vector(NP - 1 downto 0);

    signal p_frac_inter: std_logic_vector(2 * NP + 1 downto 0);

    signal add1_s: std_logic_vector(E - 1 downto 0);
    signal add1_c: std_logic;

    signal add2_a: std_logic_vector(E downto 0);
    signal p_exp_inter: std_logic_vector(E downto 0);
    signal p_exp_plus_1: std_logic_vector(E downto 0);

    constant bias: integer := 2 ** (E - 1) - 1;
    constant minus_bias: std_logic_vector(E downto 0) := std_logic_vector(to_signed(-bias, E + 1));

    function and_reduce(v: in std_logic_vector) return std_logic is
        variable r: std_logic := '1';
    begin
        for i in v'range loop
            r := r and v(i);
        end loop;
        return r;
    end function;
begin
    -- sign                    fraction/significand/mantissa (NP bits)
    --  |                      /                                     \
    --  |  exponent (E bits)  /                                       \
    --  |   /           \    /                                         \
    --  0  1 0 0 0 0 0 0 0  1 0 0 1 0 0 1 0 0 0 0 1 1 1 1 1 1 0 1 1 0 1 1
    --
    -- N-1 N-2  ......  NP  NP-1                                        0

    -- extract signs
    a_sign <= a(N - 1);
    b_sign <= b(N - 1);

    -- extract exponents
    a_exp <= a(N - 2 downto NP);
    b_exp <= b(N - 2 downto NP);

    -- extract mantissas, adding the implicit 1.
    a_frac <= '1' & a(NP - 1 downto 0);
    b_frac <= '1' & b(NP - 1 downto 0);

    -- determine the sign of the product
    p_sign <= a_sign xor b_sign;

    -- product of fractions has length 2NP + 2; is either 01.xxx or 10.xxx
    mul: entity work.mul
        generic map (N => NP + 1)
        port map(
            a => a_frac,
            b => b_frac,
            p => p_frac_inter
        );

    -- add exponents and subtract bias
    add1: entity work.addern
        generic map (N => E)
        port map(
            a => a_exp,
            b => b_exp,
            cin => '0',
            s => add1_s,
            cout => add1_c
        );
    add2_a <= add1_c & add1_s;
    add2: entity work.addern
        generic map (N => E + 1)
        port map(
            a => add2_a,
            b => minus_bias,
            cin => '0',
            s => p_exp_inter
        );

    exp_inc: entity work.addern
        generic map (N => E + 1)
        port map(
            a => p_exp_inter,
            b => std_logic_vector(to_unsigned(1, p_exp_inter'length)),
            cin => '0',
            s => p_exp_plus_1
        );

    normalize: process (p_sign, p_exp_inter, p_frac_inter) is
    begin
        -- p_exp_inter is (E downto 0) (must discard one bit)
        -- p_frac_inter is (2NP + 1 downto 0) (must discard down to NP)

        if p_frac_inter(2 * NP + 1) = '1' then
            p_frac <= p_frac_inter(2 * NP downto NP + 1);
            p_exp <= p_exp_plus_1;
        else
            p_frac <= p_frac_inter(2 * NP - 1 downto NP);
            p_exp <= p_exp_inter;
        end if;

        if p_exp_inter(E) = '1' then
            -- report "overflow!";
            p_exp <= (0 => '0', others => '1');
            p_frac <= (others => '1');
        elsif and_reduce(p_exp(E - 1 downto 0)) = '1' then
            -- report "inf!";
            p_exp <= (0 => '0', others => '1');
            p_frac <= (others => '1');
        end if;
    end process;

    p(N - 1) <= p_sign;
    p(N - 2 downto NP) <= p_exp(E - 1 downto 0);
    p(NP - 1 downto 0) <= p_frac;
end;
