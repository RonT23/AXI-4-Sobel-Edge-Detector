library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.ALL;

entity AXI_sobel_edge_detector_top_tb is
end AXI_sobel_edge_detector_top_tb;

architecture tb of AXI_sobel_edge_detector_top_tb is
    
    constant C_INPUT_FILENAME   : string  := "C:\Users\ronal\Desktop\axi-4-stream-sobel-soc\data\mandrill_512_512_csv.txt";
    constant C_OUTPUT_FILENAME  : string  := "C:\Users\ronal\Desktop\man_sim.txt";
	
	constant C_COLUMNS	        : integer := 512;
	constant C_ROWS             : integer := 512;
	
	constant C_PIXEL_COUNT      : integer := C_COLUMNS * C_ROWS;
	
	constant C_CLOCK_PERIOD     : time := 10 ns;
    
    file Input_File             : text open read_mode is C_INPUT_FILENAME;
    file Output_File            : text open write_mode is C_OUTPUT_FILENAME;
    
    signal aresetn              : std_logic := '1';
    signal aclk                 : std_logic := '0';
    
    signal m_axi_awaddr         : std_logic_vector(3 downto 0)  := (others=>'0');
    signal m_axi_awprot         : std_logic_vector(2 downto 0)  := (others=>'0');
    signal m_axi_awvalid        : std_logic                     := '0';
    signal m_axi_awready        : std_logic;
    
    signal m_axi_wdata	        : std_logic_vector(31 downto 0) := (others=>'0');  
    signal m_axi_wstrb	        : std_logic_vector(3 downto 0)  := (others=>'1');
    signal m_axi_wvalid         : std_logic                     := '0';
    signal m_axi_wready         : std_logic;
    
    signal m_axi_bresp	        : std_logic_vector(1 downto 0);
    signal m_axi_bvalid         : std_logic;
    signal m_axi_bready         : std_logic                     := '1';
    
    signal m_axi_araddr         : std_logic_vector(3 downto 0)  := (others=>'0');
    signal m_axi_arprot         : std_logic_vector(2 downto 0)  := (others=>'0');
    signal m_axi_arvalid        : std_logic                     := '0';
    signal m_axi_arready        : std_logic;
    
    signal m_axi_rdata	        : std_logic_vector(31 downto 0);
    signal m_axi_rresp	        : std_logic_vector(1 downto 0);
    signal m_axi_rvalid         : std_logic;
    signal m_axi_rready         : std_logic                     := '0';
    
    signal s_axis_tvalid        : std_logic                     := '0';
    signal s_axis_tready        : std_logic;
    signal s_axis_tlast         : std_logic                     := '0';
    signal s_axis_tdata         : std_logic_vector(7 downto 0);
    
    signal m_axis_tvalid        : std_logic;
    signal m_axis_tready        : std_logic                     := '0';
    signal m_axis_tlast         : std_logic;
    signal m_axis_tdata         : std_logic_vector(7 downto 0);
    
    signal input_count          : std_logic_vector(31 downto 0);
    signal output_count         : std_logic_vector(31 downto 0);
    signal clock_count          : std_logic_vector(31 downto 0);
    
    signal Input_Data_Counter   : integer := 0;
    
    -- Procedure to assert and hold the active low reset for a given number of clock cycles 
    procedure system_reset( signal aresetn : out std_logic;
                            signal clk     : in  std_logic;
                            reset_cycles   : integer ) is
    
    begin
        
            aresetn <= '0';
            for i in 0 to reset_cycles - 1 loop
                wait until rising_edge(clk);
            end loop;  
            aresetn <= '1';
            
    end procedure system_reset;
    
    -- Procedure to write AXI Lite registers
    procedure AXILite_Write_Register( signal clk           : in  std_logic;
                                      signal m_axi_awaddr  : out std_logic_vector(3 downto 0);
                                      signal m_axi_awvalid : out std_logic;
                                      signal m_axi_awready : in  std_logic;
                                      signal m_axi_wvalid  : out std_Logic; 
                                      signal m_axi_wready  : in  std_logic;
                                      signal m_axi_wdata   : out std_logic_vector(31 downto 0); 
                                      addr                 : std_logic_vector(3 downto 0);
                                      data                 : std_logic_vector(31 downto 0)   
                                     ) is 
    begin 
        
        m_axi_awaddr  <= addr;
        m_axi_wdata   <= data;
        
        m_axi_awvalid <= '1';
        m_axi_wvalid  <= '1';
        
        wait until rising_edge(clk) and m_axi_awready = '1' and m_axi_wready = '1';
        
        m_axi_wvalid  <= '0';
        m_axi_awvalid <= '0';
        
        wait until rising_edge(clk);
        
    end procedure AXILite_Write_Register;
      
    -- Procedure to read AXI Lite registers
    procedure AXILite_Read_Register( signal clk           : in  std_logic;  
                                     signal m_axi_araddr  : out std_logic_vector(3 downto 0);
                                     signal m_axi_arready : in  std_logic;
                                     signal m_axi_arvalid : out std_logic;
                                     signal m_axi_rvalid  : in  std_logic; 
                                     signal m_axi_rready  : out std_logic; 
                                     signal m_axi_rdata   : in  std_logic_vector(31 downto 0); 
                                     signal register_data : out std_logic_vector(31 downto 0);
                                     addr                 : std_logic_vector(3 downto 0)) is
    
    begin
            m_axi_araddr <= addr;
            m_axi_arvalid <= '1';
            
            wait until rising_edge(clk) and (m_axi_arready = '1') and (m_axi_rvalid = '1');
            --wait until rising_edge(clk) and m_axi_bvalid = '1';

            m_axi_rready  <= '1';
            register_data <= m_axi_rdata;
            
            wait until rising_edge(clk);
            
            m_axi_rready  <= '0';
            m_axi_arvalid <= '0';
            
            wait until rising_edge(clk);
            
    end procedure AXILite_Read_Register;
    
    -- Procedure to create a discntinuity in reading - writting data
    procedure add_discontinuity( signal clk    : in std_logic;
                                 signal tvalid : out std_logic;
                                 signal tready : out std_logic;
                                 cycles        : integer ) is
    begin   
            -- Create a disconntinuity on data transmission
            tvalid <= '0';
            for i in 0 to cycles loop 
                wait until rising_edge(clk);
            end loop;
            tvalid <= '1';
            
            -- Normal operation zone
            for i in 0 to cycles loop 
                wait until rising_edge(clk);
            end loop;
            
            -- Create a discontinuity on data reception
            tready <= '0';
            for i in 0 to cycles loop 
                wait until rising_edge(clk);
            end loop;
            tready <= '1';
            
            -- Normal operation zone
            for i in 0 to cycles loop 
                wait until rising_edge(clk);
            end loop;
            
            -- Stop both transmission and reception
            tvalid <= '0';
            tready <= '0';
            for i in 0 to cycles loop 
                wait until rising_edge(clk);
            end loop;
            tvalid <= '1';
            tready <= '1';
            
    end procedure add_discontinuity;
    
begin
    
    UUT: entity work.AXI_sobel_edge_detector_top
        Generic map (
           C_COLUMNS            =>          C_COLUMNS
        )
        Port map (
        
            aresetn             =>          aresetn,
            aclk                =>          aclk,
             
            s_axi_awaddr	    =>          m_axi_awaddr,
            s_axi_awprot	    =>          m_axi_awprot,
            s_axi_awvalid	    =>          m_axi_awvalid,  
            s_axi_awready	    =>          m_axi_awready,  
            
            s_axi_wdata	        =>          m_axi_wdata, 
            s_axi_wstrb	        =>          m_axi_wstrb,
            s_axi_wvalid	    =>          m_axi_wvalid,
            s_axi_wready  	    =>          m_axi_wready,
                            
            s_axi_bresp	        =>          m_axi_bresp,
            s_axi_bvalid        =>          m_axi_bvalid,
            s_axi_bready  	    =>          m_axi_bready,
            
            s_axi_araddr 	    =>          m_axi_araddr,  
            s_axi_arprot  	    =>          m_axi_arprot, 
            s_axi_arvalid 	    =>          m_axi_arvalid,
            s_axi_arready 	    =>          m_axi_arready, 
            
            s_axi_rdata	        =>          m_axi_rdata,
            s_axi_rresp	        =>          m_axi_rresp,
            s_axi_rvalid 	    =>          m_axi_rvalid, 
            s_axi_rready	    =>          m_axi_rready,
            
            s_axis_tvalid       =>          m_axis_tvalid,
            s_axis_tready       =>          m_axis_tready,
            s_axis_tlast        =>          m_axis_tlast,
            s_axis_tdata        =>          m_axis_tdata,
            
            m_axis_tvalid       =>          s_axis_tvalid,
            m_axis_tready       =>          s_axis_tready,
            m_axis_tlast        =>          s_axis_tlast,
            m_axis_tdata        =>          s_axis_tdata
           
        ); 
        
    Clock_Generator:
        process
        begin
            
            wait for C_CLOCK_PERIOD / 2;
            aclk <= not aclk;
            
        end process;    
        
    File_Data_Reader : process (aresetn, aclk)
                variable input_line_var : line;
                variable input_data_var : integer;
                variable good_var       : boolean;
                variable counter_var    : integer range 0 to C_PIXEL_COUNT-1;
         begin
         
            if aresetn = '0' then
                
                m_axis_tdata <= (others=>'0');
                m_axis_tlast <= '0';
                counter_var := 0;
                
            elsif rising_edge(aclk) then
                
                if m_axis_tvalid = '1' and m_axis_tready = '1' and ( not endfile(Input_File) ) then
                    
                    readline( Input_File, input_line_var);
                    read(input_line_var, input_data_var, good_var);
                        
                    m_axis_tdata <= std_logic_vector( to_unsigned( input_data_var, 8 ) );
                    
                    if counter_var = C_PIXEL_COUNT - 2 then
                        m_axis_tlast <= '1';
                    else
                        m_axis_tlast <= '0';
                    end if;
                    
                    counter_var := counter_var + 1;
                    
                end if;
                
                Input_Data_Counter <= counter_var;
                  
            end if;
            
         end process;
         
    File_Data_Writer : process (aresetn, aclk)
            
            variable output_line_var : line;
            
         begin
            
            if rising_edge(aclk) then
                
                if s_axis_tvalid = '1' and s_axis_tready = '1' and aresetn = '1' then 
                    
                    write(output_line_var, to_integer(unsigned(s_axis_tdata)));
                    writeline(Output_File, output_line_var);
                    
                end if;
                
            end if; 
            
         end process;
    
    Stimulus : process
    
        begin 
        ---- Assert the reset for 10 cycles
            system_reset(aresetn, aclk, 10);
             
        ---- Enable the processing
            AXILite_Write_Register( aclk,
                                    m_axi_awaddr,
                                    m_axi_awvalid,
                                    m_axi_awready,
                                    m_axi_wvalid, 
                                    m_axi_wready,
                                    m_axi_wdata, 
                                    "0000",
                                    x"00000001");
                                       
        ---- Start transmission and reception of data through the AXI4 Stream channels
            m_axis_tvalid <= '1';
            s_axis_tready <= '1';
            
            for i in 0 to 20000 loop 
                wait until rising_edge(aclk);
            end loop;
            
            add_discontinuity(aclk,
                              m_axis_tvalid,
                              s_axis_tready,
                              20000);
                               
            -- Wait until all pixels are transmitted to the uut 
            wait until rising_edge(aclk) and Input_Data_Counter >= C_PIXEL_COUNT - 1;
            
            m_axis_tvalid <= '0';
            
            -- Wait until all data are received from the uut
            wait until rising_edge(aclk) and s_axis_tlast = '1';
            
            s_axis_tready <= '0';
            
            for i in 0 to 999 loop
                wait until rising_edge(aclk); 
            end loop;
             
        ---- Read telemetry from registers
            
            -- reg2 : input pixel counter data 
            AXILite_Read_Register( aclk,  
                                   m_axi_araddr,
                                   m_axi_arready,
                                   m_axi_arvalid,
                                   m_axi_rvalid, 
                                   m_axi_rready, 
                                   m_axi_rdata, 
                                   input_count,
                                   "0100");
             
             -- reg3 : output pixel counter data
             AXILite_Read_Register(aclk,  
                                   m_axi_araddr,
                                   m_axi_arready,
                                   m_axi_arvalid,
                                   m_axi_rvalid, 
                                   m_axi_rready, 
                                   m_axi_rdata, 
                                   output_count,
                                   "1000");  
                                   
             -- reg4 : clock cycles counter data                        
             AXILite_Read_Register(aclk,  
                                   m_axi_araddr,
                                   m_axi_arready,
                                   m_axi_arvalid,
                                   m_axi_rvalid, 
                                   m_axi_rready, 
                                   m_axi_rdata, 
                                   clock_count,
                                   "1100");     

        ---- Disable the core
            AXILite_Write_Register( aclk,
                                    m_axi_awaddr,
                                    m_axi_awvalid,
                                    m_axi_awready,
                                    m_axi_wvalid, 
                                    m_axi_wready,
                                    m_axi_wdata, 
                                    "0000",
                                    x"00000001");
            wait;
            
        end process; 
        
end tb;
