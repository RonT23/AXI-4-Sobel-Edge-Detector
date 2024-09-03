library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity shift_kernel_buffer is
    
    Generic (
        C_COLUMNS       : integer := 512
    );
    
    Port ( 
        aresetn         : in std_logic;
        aclk            : in std_logic;
         
        s_axis_tvalid   : in std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tlast    : in std_logic;
        s_axis_tdata    : in std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
        
        m_axis_tvalid   : out std_logic;
        m_axis_tready   : in std_logic;
        m_axis_tlast    : out std_logic;
        m_axis_tdata    : out kernel_pixels_t 
    );
    
end shift_kernel_buffer;

architecture behv of shift_kernel_buffer is
    
    -- Buffer size: The image is stored sequentially, line-by-line. 
    --              Therefore, the 2D convolution operation with the 3x3 Sobel operators
    --              requires local buffering of at least 2 complete lines and 3 additional pixels.
    --              Each line contains C_COLUMNS pixels.
    constant C_KERNEL_BUFFER_SIZE  : integer := 2 * C_COLUMNS + 3;
    
    type kernel_indexes_t is array(7 downto 0) of integer;
    constant kernel_indexes_buf : kernel_indexes_t := (
    
                                    2 * C_COLUMNS + 2, 2 * C_COLUMNS + 1, 2 * C_COLUMNS,
                                    C_COLUMNS,                              C_COLUMNS + 2,
                                    0,                       1,                   2
                                    
                                );

    -- Kernel buffer type
    type ram_t is array(C_KERNEL_BUFFER_SIZE - 1 downto 0) of std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    signal kernel_buffer : ram_t := (others=>(others=>'0'));
    
begin
    
    process(aclk, aresetn)

    begin
    
            if aresetn = '0' then
                
                s_axis_tready <= '0';
                m_axis_tvalid <= '0';
                m_axis_tlast  <= '0'; 
                m_axis_tdata  <= (others=>(others=>'0'));
                kernel_buffer <= (others=>(others=>'0'));
                
            elsif rising_edge(aclk) then
                
                s_axis_tready <= m_axis_tready;
                m_axis_tvalid <= s_axis_tvalid;
                m_axis_tlast  <= s_axis_tlast;
                
                -- Shift all pixel by one position and append the new one at the end of the buffer.
                -- Export the 3x3 group of pixels that neighbor the center pixel.
                if s_axis_tvalid = '1' and m_axis_tready = '1' then
                    
                    -- Shift
                    for i in 0 to C_KERNEL_BUFFER_SIZE - 2 loop
                        kernel_buffer(i+1) <= kernel_buffer(i);
                    end loop;

                    -- Append
                    kernel_buffer(0) <= s_axis_tdata;
                                  
                    -- Output
                    for i in 0 to 7 loop
                        m_axis_tdata(i) <= kernel_buffer(kernel_indexes_buf(i));
                    end loop;
                    
                else
                    
                    kernel_buffer <= kernel_buffer;
                    
                end if;

                
            end if;
    
        end process;

end behv;
