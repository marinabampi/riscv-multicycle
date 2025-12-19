---------------------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O
--! @Todo: Module should mask bytes (Word, half word and byte access)
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity animation_bus is
	generic (
		--! Chip selec
		MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
		-- IRDA BASE ADDRESS (4 most significant bytes)
		MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0020";	
		DADDRESS_BUS_SIZE : integer := 32
	);
	
	port(
		clk : in std_logic;

		rst : in std_logic;
		--speed      : in std_logic_vector(1 downto 0);
		-- Core data bus signals
		daddress  : in  unsigned(DADDRESS_BUS_SIZE-1 downto 0);
		ddata_w	  : in 	std_logic_vector(31 downto 0);
		ddata_r   : out	std_logic_vector(31 downto 0);
		d_we      : in std_logic;
		d_rd	  : in std_logic;
		dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
		-- ToDo: Module should mask bytes (Word, half word and byte access)
		dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask
		segs : out std_logic_vector(7 downto 0);
		
		-- hardware input/output signals
		--animation_sensor  : in std_logic;
    	animation_debug : out std_logic_vector(31 downto 0)
    
	);
end entity animation_bus;

architecture RTL of animation_bus is
  
    signal animation_data : std_logic_vector(31 downto 0);
    signal data_ready : std_logic;

    signal direction : std_logic;
    signal speed  : std_logic_vector(1 downto 0);



begin 
    animation_debug <= animation_data;
	-- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            speed <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) = MY_WORD_ADDRESS then
                        speed <= std_logic_vector(ddata_w);
                    end if;
                end if;
            end if;
        end if;
    end process;


	 
    animation: entity work.animation_segs
        port map(
            clk        => clk, 
            rst        => rst,
            direction  => direction,
            speed   => speed,
            segs   => segs
        );

end architecture RTL;
