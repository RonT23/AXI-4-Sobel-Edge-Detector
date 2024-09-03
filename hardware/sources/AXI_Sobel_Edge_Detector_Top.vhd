library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity AXI_sobel_edge_detector_top is 
 
    Generic ( 
        C_COLUMNS        : integer := 512
    );
    
    Port ( 
        aresetn       : in std_logic;   
        aclk          : in std_logic;   
             
        s_axi_awaddr  : in std_logic_vector(3 downto 0);
        s_axi_awprot  : in std_logic_vector(2 downto 0);
        s_axi_awvalid : in std_logic;
        s_axi_awready : out std_logic;
        
        s_axi_wdata	  : in std_logic_vector(31 downto 0);  
        s_axi_wstrb	  : in std_logic_vector(3 downto 0);
        s_axi_wvalid  : in std_logic;
        s_axi_wready  : out std_logic;
        
        s_axi_bresp	  : out std_logic_vector(1 downto 0);
        s_axi_bvalid  : out std_logic;
        s_axi_bready  : in std_logic;
        
        s_axi_araddr  : in std_logic_vector(3 downto 0);
        s_axi_arprot  : in std_logic_vector(2 downto 0);
        s_axi_arvalid : in std_logic;
        s_axi_arready : out std_logic;
        
        s_axi_rdata	  : out std_logic_vector(31 downto 0);
        s_axi_rresp	  : out std_logic_vector(1 downto 0);
        s_axi_rvalid  : out std_logic;
        s_axi_rready  : in std_logic;
          
        s_axis_tvalid : in std_logic;
        s_axis_tready : out std_logic;
        s_axis_tlast  : in std_logic;
        s_axis_tdata  : in std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0); 
        
        m_axis_tvalid : out std_logic;
        m_axis_tready : in std_logic;
        m_axis_tlast  : out std_logic;
        m_axis_tdata  : out std_logic_vector(C_BITS_PER_PIXEL - 1 downto 0)
    );
    
end AXI_sobel_edge_detector_top;

architecture behv of AXI_sobel_edge_detector_top is
    
    signal telemetry        : telemetry_t  := (others=>(others=>'0'));
    
    signal clk_200MHz       : std_logic;    -- Sobel processor internal clock generated from the 100MHz clock
    signal locked           : std_logic;    -- The clock generation has been stabilized
    signal enable           : std_logic;    -- Sobel processor enable register
    
    signal axi_resetn       : std_logic;
    signal system_resetn    : std_logic;
    
begin
    
    system_resetn <= aresetn and locked and enable; -- active low reset for the Sobel Edge Detector Processor.
    
    Clock_Generation_200MHz : component clk_wiz_0
        Port map (
            clk_in              =>      aclk,
            resetn              =>      aresetn,
            locked              =>      locked,
            clk_200MHz          =>      clk_200MHz
        );
         
    AXI_Lite_Interface : component AXI_Lite_Registers
        Port map (
            s_axi_aresetn       =>       aresetn,
            s_axi_aclk          =>       aclk,
            
            pixel_count_in      =>       telemetry(input_counter),
            pixel_count_out     =>       telemetry(output_counter),
            clock_cycles_count  =>       telemetry(clock_counter),
            system_enable       =>       enable,
            
            s_axi_awaddr	    =>       s_axi_awaddr,
            s_axi_awprot	    =>       s_axi_awprot,
            s_axi_awvalid	    =>       s_axi_awvalid,  
            s_axi_awready	    =>       s_axi_awready,  
            
            s_axi_wdata	        =>       s_axi_wdata, 
            s_axi_wstrb	        =>       s_axi_wstrb,
            s_axi_wvalid	    =>       s_axi_wvalid,
            s_axi_wready  	    =>       s_axi_wready,
                            
            s_axi_bresp	        =>       s_axi_bresp,
            s_axi_bvalid        =>       s_axi_bvalid,
            s_axi_bready  	    =>       s_axi_bready,
            
            s_axi_araddr 	    =>       s_axi_araddr,  
            s_axi_arprot  	    =>       s_axi_arprot, 
            s_axi_arvalid 	    =>       s_axi_arvalid,
            s_axi_arready 	    =>       s_axi_arready, 
            
            s_axi_rdata	        =>       s_axi_rdata,
            s_axi_rresp	        =>       s_axi_rresp,
            s_axi_rvalid 	    =>       s_axi_rvalid, 
            s_axi_rready	    =>       s_axi_rready
        );
    
    AXI_Sobel_Edge_Detector_Core : component AXI_Sobel_Edge_Detector
        Generic map (
            C_COLUMNS           =>       C_COLUMNS
        )
        Port map (
            aresetn             =>       system_resetn,   
            clk_100MHz          =>       aclk, 
            clk_200MHz          =>       clk_200MHz,
            
            input_count         =>       telemetry(input_counter),
            output_count        =>       telemetry(output_counter),
            clock_count         =>       telemetry(clock_counter),
            
            s_axis_tvalid       =>       s_axis_tvalid,
            s_axis_tready       =>       s_axis_tready,
            s_axis_tlast        =>       s_axis_tlast,
            s_axis_tdata        =>       s_axis_tdata,
           
            m_axis_tvalid       =>       m_axis_tvalid,
            m_axis_tready       =>       m_axis_tready,
            m_axis_tlast        =>       m_axis_tlast,
            m_axis_tdata        =>       m_axis_tdata 
        );
        
end behv;
