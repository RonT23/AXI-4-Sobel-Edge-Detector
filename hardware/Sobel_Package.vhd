library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package Sobel_Package is
    
    constant C_BITS_PER_PIXEL   : integer := 8;
    constant C_REGISTER_WIDTH   : integer := 32;
    
    constant sx_1               : integer := 0;
    constant sx_2               : integer := 1;
    constant sx_3               : integer := 2;
    constant sy_1               : integer := 3;
    constant sy_3               : integer := 4;
    
    constant gx                 : integer := 0;
    constant gy                 : integer := 1;
    
    constant input_counter      : integer := 0;
    constant output_counter     : integer := 1;
    constant clock_counter      : integer := 2;
    
    type kernel_pixels_t is array(7 downto 0) of std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);  
    type partial_sums_t  is array(4 downto 0) of std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    type gradients_t     is array(1 downto 0) of std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    type telemetry_t     is array(2 downto 0) of std_logic_vector(C_REGISTER_WIDTH - 1 downto 0);
     
    -- Xilinx component
    component axis_data_fifo_0 is
        
        Port (
            s_axis_aresetn  : in std_logic;
            
            s_axis_aclk     : in std_logic;
            s_axis_tvalid   : in std_logic;  
            s_axis_tready   : out std_logic;
            s_axis_tlast    : in std_logic; 
            s_axis_tdata    : in std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
            
            m_axis_aclk     : in std_logic;
            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tdata    : out std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0)
        );
        
    end component axis_data_fifo_0;
    
    -- Xilinx component
    component clk_wiz_0 is
       
        Port (
            clk_in      : in  std_logic;
            resetn      : in  std_logic;
            locked      : out std_logic; 
            clk_200MHz  : out std_logic 
        );
        
    end component clk_wiz_0;
    
    component generic_counter is
    
        generic (
            C_REGISTER_WIDTH : integer := 32
        );
        
        Port (
            clk            : in std_logic;
            reset          : in std_logic;
            en             : in std_logic;
            count          : out std_logic_vector(C_REGISTER_WIDTH - 1 downto 0)        
        );
        
    end component generic_counter;
    
    component shift_kernel_buffer is
       
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
        
    end component shift_kernel_buffer;
    
    component Scale_Down is
        
        Port ( 
            aclk            : in std_logic; 
            aresetn         : in std_logic;
            
            s_axis_tvalid   : in std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tlast    : in std_logic; 
            s_axis_tdata    : in kernel_pixels_t; 
            
            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tdata    : out kernel_pixels_t
        );
        
    end component Scale_Down;
    
    component Partial_Sums is
        
        Port ( 
            aclk            : in std_logic; 
            aresetn         : in std_logic;
            
            s_axis_tvalid   : in std_logic;
            s_axis_tready   : out std_logic;
            s_axis_tlast    : in std_logic; 
            s_axis_tdata    : in kernel_pixels_t; 
            
            m_axis_tvalid   : out std_logic;
            m_axis_tready   : in std_logic;
            m_axis_tlast    : out std_logic;
            m_axis_tdata    : out partial_sums_t
        );
        
    end component Partial_Sums;
    
    component Gradients is
        
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
        
    end component Gradients;
    
    component Gradient_Magnitude is
        
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
        
    end component Gradient_Magnitude;
   
    component Processing_Stages is
 
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
 
    end component Processing_Stages;
    
    component Telemetry is
 
        Port ( 
            aresetn        : in std_logic;
            aclk           : in std_logic;
            
            reader_tvalid  : in std_logic;
            reader_tready  : in std_logic;
            
            writer_tvalid  : in std_logic;
            writer_tready  : in std_logic;
            writer_tlast   : in std_logic;
            
            telemetry_data : out telemetry_t
        );
 
    end component Telemetry;
    
    component AXI_sobel_edge_detector is

        Generic ( 
            C_COLUMNS        : integer := 512
        );
        
        Port ( 
            aresetn       : in std_logic;
            clk_100MHz    : in std_logic;
            clk_200MHz    : in std_logic; 
             
            input_count   : out std_logic_vector(C_REGISTER_WIDTH - 1 downto 0);
            output_count  : out std_logic_vector(C_REGISTER_WIDTH - 1 downto 0);
            clock_count   : out std_logic_vector(C_REGISTER_WIDTH - 1 downto 0); 
            
            s_axis_tvalid : in std_logic;
            s_axis_tready : out std_logic;
            s_axis_tlast  : in std_logic;
            s_axis_tdata  : in std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0); 
            
            m_axis_tvalid : out std_logic;
            m_axis_tready : in std_logic;
            m_axis_tlast  : out std_logic;
            m_axis_tdata  : out std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0)
        );
        
    end component AXI_sobel_edge_detector;
    
    component AXI_Lite_Registers is
 
        port (
          s_axi_aclk	     : in std_logic;
          s_axi_aresetn      : in std_logic;
        
          pixel_count_in     : in std_logic_vector(31 downto 0);
          pixel_count_out    : in std_logic_vector(31 downto 0);
          clock_cycles_count : in std_logic_vector(31 downto 0);
          system_enable      : out std_logic;
          
          s_axi_awaddr	     : in std_logic_vector(3 downto 0);
          s_axi_awprot	     : in std_logic_vector(2 downto 0);
          s_axi_awvalid	     : in std_logic;
          s_axi_awready	     : out std_logic;
        
          s_axi_wdata	     : in std_logic_vector(31 downto 0);  
          s_axi_wstrb	     : in std_logic_vector(3 downto 0);
          s_axi_wvalid	     : in std_logic;
          s_axi_wready  	 : out std_logic;
            
          s_axi_bresp	     : out std_logic_vector(1 downto 0);
          s_axi_bvalid       : out std_logic;
          s_axi_bready  	 : in std_logic;
        
          s_axi_araddr 	     : in std_logic_vector(3 downto 0);
          s_axi_arprot  	 : in std_logic_vector(2 downto 0);
          s_axi_arvalid 	 : in std_logic;
          s_axi_arready 	 : out std_logic;
        
          s_axi_rdata	     : out std_logic_vector(31 downto 0);
          s_axi_rresp	     : out std_logic_vector(1 downto 0);
          s_axi_rvalid 	     : out std_logic;
          s_axi_rready	     : in std_logic
        );
 
    end component AXI_Lite_Registers;

end package Sobel_Package;