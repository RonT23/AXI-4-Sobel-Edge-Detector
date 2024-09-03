library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity Gradients is

    Port ( 
        aclk            : in std_logic; 
        aresetn         : in std_logic;
        
        s_axis_tvalid   : in std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tlast    : in std_logic; 
        s_axis_tdata    : in partial_sums_t; 
        
        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tdata    : out gradients_t
    );

end Gradients;

architecture behv of Gradients is
    
begin


    process(aclk, aresetn)
    begin

        if aresetn = '0' then
                
            s_axis_tready <= '0';
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0'; 
            m_axis_tdata  <= (others=>(others=>'0'));
            
        elsif rising_edge(aclk) then
            
            s_axis_tready <= m_axis_tready;
            m_axis_tvalid <= s_axis_tvalid;
            m_axis_tlast  <= s_axis_tlast;

            if s_axis_tvalid = '1' and m_axis_tready = '1' then

                m_axis_tdata(gx) <= std_logic_vector( signed(s_axis_tdata(sx_1)) + signed(s_axis_tdata(sx_2)) + signed(s_axis_tdata(sx_3)) );
                m_axis_tdata(gy) <= std_logic_vector( signed(s_axis_tdata(sy_3)) - signed(s_axis_tdata(sy_1)) );
            
            end if;

        end if;

    end process;


end behv;
