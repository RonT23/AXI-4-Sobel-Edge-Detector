library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity Gradient_Magnitude is
    Generic ( 
        C_COLUMNS       : integer := 512
    );
    Port ( 
        aclk            : in std_logic; 
        aresetn         : in std_logic;
        
        s_axis_tvalid   : in std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tlast    : in std_logic; 
        s_axis_tdata    : in gradients_t; 
        
        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tdata    : out std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0)
    );

end Gradient_Magnitude;

architecture behv of Gradient_Magnitude is
    
begin
    
    process(aclk, aresetn)
        
        variable counter_var : integer range 0 to C_COLUMNS := 0; 
        
    begin

        if aresetn = '0' then
            
            counter_var   := 0;
            
            s_axis_tready <= '0';
            m_axis_tvalid <= '0';
            m_axis_tlast  <= '0'; 
            m_axis_tdata  <= (others=>'0');
            
        elsif rising_edge(aclk) then
            
            s_axis_tready <= m_axis_tready;
            m_axis_tvalid <= s_axis_tvalid;
            m_axis_tlast  <= s_axis_tlast;

            if s_axis_tvalid = '1' and m_axis_tready = '1' then
                 
                 if (counter_var <= 0) or (counter_var >= C_COLUMNS - 1) then
                    m_axis_tdata <= (others=>'0');
                 else 
                    m_axis_tdata <= std_logic_vector( abs( signed(s_axis_tdata(gx)) ) + abs( signed(s_axis_tdata(gy)) ) );
                 end if;
                 
                 if (counter_var < C_COLUMNS - 1) then
                    counter_var := counter_var + 1;
                 else
                    counter_var := 0;
                 end if;
                 
            end if;
            
        end if;

    end process;


end behv;
