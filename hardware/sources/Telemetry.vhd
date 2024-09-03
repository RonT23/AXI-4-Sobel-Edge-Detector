library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Sobel_Package.ALL;

entity Telemetry is
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
end Telemetry;

architecture behv of Telemetry is
    
    signal reset                 : std_logic := '0';
    signal input_counter_enable  : std_logic := '0';
    signal output_counter_enable : std_logic := '0';
    signal clock_counter_enable  : std_logic := '0';
    
begin
    
    -- active high reset is needed here
    reset  <= not aresetn;
    
    -- Count the valid input handshakes with the external interface
    input_counter_enable  <= (not reset) and reader_tvalid and reader_tready;
    
    Input_Pixel_Counter : component Generic_Counter
        Generic map ( C_REGISTER_WIDTH )
        Port map (
            clk             =>      aclk,
            reset           =>      reset,
            en              =>      input_counter_enable,
            count           =>      telemetry_data(input_counter)
        );
    
    -- Count the valid output handshakes with the external interface
    output_counter_enable <= (not reset) and writer_tvalid and writer_tready;
     
    Output_Pixel_Counter : component Generic_Counter
        Generic map ( C_REGISTER_WIDTH )
        Port map (
            clk             =>      aclk,
            reset           =>      reset,
            en              =>      output_counter_enable,
            count           =>      telemetry_data(output_counter)
        ); 
    
    -- Start the clock counter when the input first receives the first datum until the output asserts the tlast
    
    -- The folowing logical expression creates a timing loop which is considered a bad design practice.
    -- clock_counter_enable <= (not reset) and (not (writer_tlast)) and ( clock_counter_enable or ( (not clock_counter_enable) and (reader_tvalid) and (reader_tready) ) );
    
    Clock_Counter_Enable_Register: process(aclk, reset)
    
    begin
        
        if reset = '1' then
            clock_counter_enable <= '0';
            
        elsif rising_edge(aclk) then
            
            if writer_tlast = '0' then
                
                -- if handshake occures or the counter is already enabled then enable the counter 
                if ((reader_tvalid = '1') and (reader_tready = '1')) or (clock_counter_enable = '1') then
                    clock_counter_enable <= '1';
                
                else
                    clock_counter_enable <= clock_counter_enable; -- retain the previous value
                
                end if; 
            
            else 
                clock_counter_enable <= '0';    -- disable on tlast
            
            end if;
            
        end if;
        
    end process;
    
    Clock_Cycle_Counter : component Generic_Counter
        Generic map ( C_REGISTER_WIDTH )
        Port map (
            clk             =>      aclk,
            reset           =>      reset,
            en              =>      clock_counter_enable,
            count           =>      telemetry_data(clock_counter)
        ); 
       
end behv;
