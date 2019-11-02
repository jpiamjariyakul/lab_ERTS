-- cm0_wrapper used in leon3mp.vhd

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
use techmap.allclkgen.all;
library gaisler;
use gaisler.memctrl.all;
use gaisler.leon3.all;
use gaisler.uart.all;
use gaisler.misc.all;
use gaisler.net.all;
use gaisler.jtag.all;
library esa;
use esa.memoryctrl.all;

use work.config.all;

-- !!!: Declaring files in cm0_wrapper
--use work.AHB_bridge.all;
--use work.CM0_DSSystem.all;

-- ENTITY gate IS 
--   PORT ( 
--     a:IN BIT; -- input
--  		b:IN BIT;
--	 	q:OUT BIT
--   );
-- END gate;

-- ARCHITECTURE dataflow OF gate IS
--   SIGNAL q_prim : BIT;
-- BEGIN
--     q_prim <= a AND b AFTER 5 ns;
--     q <= NOT q_prim AFTER 3 ns;
-- END dataflow;



entity cm0_wrapper is
  port(
    -- CLK and RESET
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type
  );
end entity;
--------------------------------------------------------
--------------------------------------------------------
architecture structural of cm0_wrapper is
-- Signals between CortexM0 and AHB Bridge
SIGNAL s_HADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_HSIZE : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL s_HTRANS : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL s_HWDATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_HWRITE : STD_LOGIC;
SIGNAL s_HRDATA : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_HREADY : STD_LOGIC;
-- declare a component for CORTEXM0DS

component cortexm0ds
  PORT (
    HCLK : IN STD_LOGIC;
    HRESETn : IN STD_LOGIC;
    -- Components that are not clk or reset
    HADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    HSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    HTRANS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    HWDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    HWRITE : OUT STD_LOGIC;
    HRDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    HREADY : IN STD_LOGIC
  );
end component;
-- declare a component for AHB_bridge
component AHB_bridge
  PORT (
    ahb_clk : IN STD_LOGIC;
    ahb_rst : IN STD_LOGIC;
    -- H-based ports
    HADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    HSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    HTRANS : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    HWDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    HWRITE : IN STD_LOGIC;
    HRDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    HREADY : OUT STD_LOGIC;
    -- AHB Bus ports
    ahbo: OUT ahb_mst_out_type;
    ahbi: IN ahb_mst_in_type 
  );
end component;
-- Signals inside wrapper that do not i/o of wrapper
--signal dmai : ahb_dma_in_type;
--signal dmao : ahb_dma_out_type;

begin
-- Port map between cm0_wrapper and CORTEXM0DS
cortexm0ds_map: cortexm0ds
  port map (
    HCLK => clkm,
    HRESETn => rstn,
    
    HADDR => s_HADDR,
    HSIZE => s_HSIZE,
    HTRANS => s_HTRANS,
    HWDATA => s_HWDATA,
    HWRITE => s_HWRITE,
    HRDATA => s_HRDATA,
    HREADY => s_HREADY
  );
-- Port map between cm0_wrapper and AHB_bridge
ahb_map: AHB_bridge
  port map (
    ahb_clk => clkm,
    ahb_rst => rstn,
    --ahbo => ahbmo(0),
    ahbo => ahbmo,
    ahbi => ahbmi,
    
    HADDR => s_HADDR,
    HSIZE => s_HSIZE,
    HTRANS => s_HTRANS,
    HWDATA => s_HWDATA,
    HWRITE => s_HWRITE,
    HRDATA => s_HRDATA,
    HREADY => s_HREADY
  );
end structural;