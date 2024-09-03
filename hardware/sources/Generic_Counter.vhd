library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sobel_package.all;

entity generic_counter is
    
    generic (
            C_REGISTER_WIDTH : integer := 32     
    );
    
    port (
            clk            : in std_logic;
            reset          : in std_logic;
            en             : in std_logic;
            count          : out std_logic_vector(C_REGISTER_WIDTH - 1 downto 0)    
    );
    
end generic_counter;

architecture behv of generic_counter is

begin

    process(clk, reset)
        variable r_count : std_logic_vector(C_REGISTER_WIDTH - 1 downto 0);

    begin 

        if reset = '1' then
            r_count := (others=>'0');
                
        elsif rising_edge(clk) then

            if en = '1' then
                r_count := std_logic_vector( unsigned(r_count) + 1 ); -- Increment
            else
                r_count := r_count;                                   -- Retain
            end if;
               
        end if;
        
        count <= r_count;

    end process;

end architecture behv;