library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.ALL;

entity sobel_edge_detector_tb is
end sobel_edge_detector_tb;

architecture tb of sobel_edge_detector_tb is
    
    constant C_INPUT_FILENAME   : string  := "C:\Users\ronal\Desktop\axi-4-stream-sobel-soc\data\mandrill_512_512_csv.txt";
    constant C_OUTPUT_FILENAME  : string  := "C:\Users\ronal\Desktop\man_sim.txt";
	
	constant C_COLUMNS	        : integer := 512;
	constant C_ROWS             : integer := 512;
	
	constant C_PIXEL_COUNT      : integer := C_COLUMNS * C_ROWS;
	
	constant C_CLOCK_PERIOD_100MHz   : time := 10 ns;
    constant C_CLOCK_PERIOD_200MHz   : time := 5 ns;
    
    file Input_File             : text open read_mode is C_INPUT_FILENAME;
    file Output_File            : text open write_mode is C_OUTPUT_FILENAME;
    
    signal aresetn              : std_logic := '1';
    signal clk_100MHz           : std_logic := '0';
    signal clk_200MHz           : std_logic := '0';
    
    signal s_axis_tvalid        : std_logic := '0';
    signal s_axis_tready        : std_logic;
    signal s_axis_tlast         : std_logic := '0';
    signal s_axis_tdata         : std_logic_vector(7 downto 0);
    
    signal m_axis_tvalid        : std_logic;
    signal m_axis_tready        : std_logic := '0';
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
    
    UUT: entity work.AXI_sobel_edge_detector
        Generic map (
           C_COLUMNS        =>          C_COLUMNS
        )
        Port map (
           aresetn          =>          aresetn,
           clk_100MHz       =>          clk_100MHz,
           clk_200MHz       =>          clk_200MHz,
           
           input_count      =>          input_count,
           output_count     =>          output_count,
           clock_count      =>          clock_count,
            
           s_axis_tvalid    =>          m_axis_tvalid,
           s_axis_tready    =>          m_axis_tready,
           s_axis_tlast     =>          m_axis_tlast,
           s_axis_tdata     =>          m_axis_tdata,
           
           m_axis_tvalid    =>          s_axis_tvalid,
           m_axis_tready    =>          s_axis_tready,
           m_axis_tlast     =>          s_axis_tlast,
           m_axis_tdata     =>          s_axis_tdata
           
        ); 
        
    Interface_Clock_Generator:
        process
        begin
            
            wait for C_CLOCK_PERIOD_100MHz / 2;
            clk_100MHz <= not clk_100MHz;
            
        end process;    

    Processing_Clock_Generator:
        process
        begin
            
            wait for C_CLOCK_PERIOD_200MHz / 2;
            clk_200MHz <= not clk_200MHz;
            
        end process;
        
    File_Data_Reader : process (aresetn, clk_100MHz)
                variable input_line_var : line;
                variable input_data_var : integer;
                variable good_var       : boolean;
                variable counter_var    : integer range 0 to C_PIXEL_COUNT-1;
         begin
         
            if aresetn = '0' then
                
                m_axis_tdata <= (others=>'0');
                m_axis_tlast <= '0';
                counter_var := 0;
                
            elsif rising_edge(clk_100MHz) then
                
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
         
    File_Data_Writer : process (aresetn, clk_100MHz)
            
            variable output_line_var : line;
            
         begin
            
            if rising_edge(clk_100MHz) then
                
                if s_axis_tvalid = '1' and s_axis_tready = '1' and aresetn = '1' then 
                    
                    write(output_line_var, to_integer(unsigned(s_axis_tdata)));
                    writeline(Output_File, output_line_var);
                    
                end if;
                
            end if; 
            
         end process;
    
    Stimulus : process
    
        begin 
            
            --- Assert the reset for 10 cycles
            system_reset( aresetn, clk_100MHz, 100);
            
            --- Start transmission and reception of data
            m_axis_tvalid <= '1';
            s_axis_tready <= '1';
            
            for i in 0 to 20000 loop 
                wait until rising_edge(clk_100MHz);
            end loop;
            
            add_discontinuity(clk_100MHz,
                              m_axis_tvalid,
                              s_axis_tready,
                              20000);
           
            wait until rising_edge(clk_100MHz) and Input_Data_Counter >= C_PIXEL_COUNT - 1;
            
            m_axis_tvalid <= '0';
            
            wait until rising_edge(clk_100MHz) and s_axis_tlast = '1';
            
            s_axis_tready <= '0';
            
            wait;
            
        end process; 
        
end tb;
