library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity Processing_Stages is
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
        m_axis_tdata    : out std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0) 
    );
end Processing_Stages;

architecture struct of Processing_Stages is

    signal kernel_buffer_tvalid   : std_logic;
    signal kernel_buffer_tready   : std_logic;
    signal kernel_buffer_tlast    : std_logic;
    signal kernel_buffer_tdata    : kernel_pixels_t;
    
    signal scaled_pixel_tvalid    : std_logic;
    signal scaled_pixel_tready    : std_logic;
    signal scaled_pixel_tlast     : std_logic;
    signal scaled_pixel_tdata     : kernel_pixels_t;
    
    signal partial_sum_tvalid     : std_logic;
    signal partial_sum_tready     : std_logic;
    signal partial_sum_tlast      : std_logic;
    signal partial_sum_tdata      : partial_sums_t;
   
    signal gradient_tvalid        : std_logic;
    signal gradient_tready        : std_logic;
    signal gradient_tlast         : std_logic;
    signal gradient_tdata         : gradients_t;

begin
    
    Stage_1_Shift_Buffer: component shift_kernel_buffer
        Generic map (
            C_COLUMNS       =>      C_COLUMNS
        )
        Port map( 
            aresetn         =>      aresetn,
            aclk            =>      aclk,
             
            s_axis_tvalid   =>      s_axis_tvalid,
            s_axis_tready   =>      s_axis_tready,
            s_axis_tlast    =>      s_axis_tlast,
            s_axis_tdata    =>      s_axis_tdata,
            
            m_axis_tvalid   =>      kernel_buffer_tvalid,
            m_axis_tready   =>      kernel_buffer_tready,
            m_axis_tlast    =>      kernel_buffer_tlast,
            m_axis_tdata    =>      kernel_buffer_tdata
        );

    Stage_2_Scale_Down_Pixels: component Scale_Down
        Port map( 
            aresetn         =>      aresetn,
            aclk            =>      aclk,
             
            s_axis_tvalid   =>      kernel_buffer_tvalid,
            s_axis_tready   =>      kernel_buffer_tready,
            s_axis_tlast    =>      kernel_buffer_tlast,
            s_axis_tdata    =>      kernel_buffer_tdata,
            
            m_axis_tvalid   =>      scaled_pixel_tvalid,
            m_axis_tready   =>      scaled_pixel_tready,
            m_axis_tlast    =>      scaled_pixel_tlast,
            m_axis_tdata    =>      scaled_pixel_tdata
        );
        
    Stage_3_Pixel_Partial_Sums: component Partial_Sums
        Port map( 
            aresetn         =>      aresetn,
            aclk            =>      aclk,
             
            s_axis_tvalid   =>      scaled_pixel_tvalid,
            s_axis_tready   =>      scaled_pixel_tready,
            s_axis_tlast    =>      scaled_pixel_tlast,
            s_axis_tdata    =>      scaled_pixel_tdata,
            
            m_axis_tvalid   =>      partial_sum_tvalid,
            m_axis_tready   =>      partial_sum_tready,
            m_axis_tlast    =>      partial_sum_tlast,
            m_axis_tdata    =>      partial_sum_tdata
        );
     
    Stage_4_Directional_Gradients: component Gradients
        Port map( 
            aresetn         =>      aresetn,
            aclk            =>      aclk,
             
            s_axis_tvalid   =>      partial_sum_tvalid,
            s_axis_tready   =>      partial_sum_tready,
            s_axis_tlast    =>      partial_sum_tlast,
            s_axis_tdata    =>      partial_sum_tdata,
            
            m_axis_tvalid   =>      gradient_tvalid,
            m_axis_tready   =>      gradient_tready,
            m_axis_tlast    =>      gradient_tlast,
            m_axis_tdata    =>      gradient_tdata
        );
        
    Stage_5_Magnitude_Value: component Gradient_Magnitude
        Generic map (
            C_COLUMNS       =>      C_COLUMNS
        )
        Port map( 
            aresetn         =>      aresetn,
            aclk            =>      aclk,
             
            s_axis_tvalid   =>      gradient_tvalid,
            s_axis_tready   =>      gradient_tready,
            s_axis_tlast    =>      gradient_tlast,
            s_axis_tdata    =>      gradient_tdata,
            
            m_axis_tvalid   =>      m_axis_tvalid,
            m_axis_tready   =>      m_axis_tready,
            m_axis_tlast    =>      m_axis_tlast,
            m_axis_tdata    =>      m_axis_tdata
        );

end struct;
