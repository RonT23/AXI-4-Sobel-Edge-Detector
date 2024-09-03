library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity AXI_sobel_edge_detector is

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
    
end AXI_sobel_edge_detector;

architecture struct of AXI_sobel_edge_detector is
    
    -- Input FIFO signals
    signal input_fifo_in_tvalid   : std_logic;
    signal input_fifo_in_tlast    : std_logic;
    signal input_fifo_in_tready   : std_logic;
    signal input_fifo_in_tdata    : std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    
    signal input_fifo_out_tvalid  : std_logic;
    signal input_fifo_out_tlast   : std_logic;
    signal input_fifo_out_tready  : std_logic;
    signal input_fifo_out_tdata   : std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    
    -- Output FIFO signals
    signal output_fifo_in_tvalid  : std_logic;
    signal output_fifo_in_tlast   : std_logic;
    signal output_fifo_in_tready  : std_logic;
    signal output_fifo_in_tdata   : std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    
    signal output_fifo_out_tvalid : std_logic;
    signal output_fifo_out_tlast  : std_logic;
    signal output_fifo_out_tready : std_logic;
    signal output_fifo_out_tdata  : std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0);
    
    signal counter_values         : telemetry_t; 
     
begin
    
    -- Reader interface
    input_fifo_in_tvalid    <=      s_axis_tvalid;
    s_axis_tready           <=      input_fifo_in_tready;
    input_fifo_in_tlast     <=      s_axis_tlast;
    input_fifo_in_tdata     <=      s_axis_tdata;
    
    -- Writer interface
    m_axis_tvalid           <=      output_fifo_out_tvalid;
    output_fifo_out_tready  <=      m_axis_tready;
    m_axis_tlast            <=      output_fifo_out_tlast;
    m_axis_tdata            <=      output_fifo_out_tdata;
    
    -- Performance counters
    input_count             <=      counter_values(input_counter);
    output_count            <=      counter_values(output_counter);
    clock_count             <=      counter_values(clock_counter);
    
    Input_FIFO : component axis_data_fifo_0
        Port map (
          s_axis_aresetn    =>      aresetn,
          
          s_axis_aclk       =>      clk_100MHz, 
          s_axis_tvalid     =>      input_fifo_in_tvalid,
          s_axis_tready     =>      input_fifo_in_tready,
          s_axis_tdata      =>      input_fifo_in_tdata,
          s_axis_tlast      =>      input_fifo_in_tlast,
          
          m_axis_aclk       =>      clk_200MHz,
          m_axis_tvalid     =>      input_fifo_out_tvalid,
          m_axis_tready     =>      input_fifo_out_tready,
          m_axis_tdata      =>      input_fifo_out_tdata,
          m_axis_tlast      =>      input_fifo_out_tlast
        );
   
    Processing_Pipeline: component Processing_Stages
        Generic map (
            C_COLUMNS       =>      C_COLUMNS
        )
        Port map( 
            aresetn         =>      aresetn, 
            aclk            =>      clk_200MHz,
             
            s_axis_tvalid   =>      input_fifo_out_tvalid,
            s_axis_tready   =>      input_fifo_out_tready,
            s_axis_tlast    =>      input_fifo_out_tlast,
            s_axis_tdata    =>      input_fifo_out_tdata,

            m_axis_tvalid   =>      output_fifo_in_tvalid,
            m_axis_tready   =>      output_fifo_in_tready,
            m_axis_tlast    =>      output_fifo_in_tlast,
            m_axis_tdata    =>      output_fifo_in_tdata
        );
        
    Output_FIFO : component axis_data_fifo_0
        Port map(
          s_axis_aresetn    =>      aresetn,
          
          s_axis_aclk       =>      clk_200MHz, 
          s_axis_tvalid     =>      output_fifo_in_tvalid,
          s_axis_tready     =>      output_fifo_in_tready,
          s_axis_tdata      =>      output_fifo_in_tdata,
          s_axis_tlast      =>      output_fifo_in_tlast,
          
          m_axis_aclk       =>      clk_100MHz,
          m_axis_tvalid     =>      output_fifo_out_tvalid,
          m_axis_tready     =>      output_fifo_out_tready,
          m_axis_tdata      =>      output_fifo_out_tdata,
          m_axis_tlast      =>      output_fifo_out_tlast
        );
  
    Performance_Counters : component Telemetry
        Port map (
            aresetn         =>      aresetn, 
            aclk            =>      clk_100MHz,
            
            reader_tvalid   =>      input_fifo_in_tvalid,
            reader_tready   =>      input_fifo_in_tready,
            
            writer_tvalid   =>      output_fifo_out_tvalid,
            writer_tready   =>      output_fifo_out_tready,
            writer_tlast    =>      output_fifo_out_tlast,
            
            telemetry_data  =>      counter_values 
        );
    
end struct;
