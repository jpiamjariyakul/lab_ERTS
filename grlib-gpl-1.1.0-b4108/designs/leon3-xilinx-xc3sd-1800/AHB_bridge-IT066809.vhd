library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;

entity AHB_bridge is
  port(
    -- Clock and Reset -----------------
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records --------------
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    -- ARM Cortex-M0 AHB-Lite signals --
    HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: nonsequential only
    HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : in std_logic; -- AHB write control
    HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
    HREADY : out std_logic -- AHB stall signal
  );
end;
-- =================================================
-- =================================================

architecture structural of AHB_bridge is

TYPE state_type is (init, instr_fetch);  -- List your states here 	
SIGNAL curState, nextState: STATE_TYPE;
-- =================================================
-- declare a component for state_machine
component state_machine is
  port(
    HADDR : in std_logic_vector (31 downto 0);
    HSIZE : in std_logic_vector (2 downto 0);
    HTRANS : in std_logic_vector (1 downto 0);
    HWDATA : in std_logic_vector (31 downto 0);
    HWRITE : in std_logic;
    HREADY : out std_logic;
    
    dmai: out ahb_dma_out_type;
    dmao: in ahb_dma_in_type;
    
    clkm : in std_logic;
    rstn: in std_logic
  );
end component state_machine;
-- =================================================
-- declare a component for ahbmst
component ahbmst is
  port(
    dmao: in ahb_dma_out_type;
    HRDATA: out std_logic_vector (31 downto 0);
    clkm : in std_logic
  );
end component ahbmst;
-- =================================================
-- declare a component for data_swapper
component data_swapper is
  port(
    dmao: in ahb_dma_in_type;
    HRDATA: out std_logic_vector (31 downto 0);
    clkm : in std_logic
  );
end component data_swapper;
-- =================================================
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
-- =================================================
begin
-- instantiate state_machine component and make the connections
combi_nextState: process(curState, HTRANS, dmao, HREADY, dmai)
BEGIN
CASE curState IS
  WHEN init =>
    IF HTRANS = 10 THEN
      dmai.start <= 1;
      nextState <= instr_fetch;
    ELSE
      nextState <= curState;
    END IF;
    
  WHEN instr_fetch =>
    IF dmao.ready = 1 THEN
      HREADY <= 1;
      nextState <= init; -- Fill in
    ELSE
      nextState <= curState; -- Fill in
    END IF;
END PROCESS; -- combi_nextState
-- =================================================
-- Set values in state "idle"
PROCESS(curState, HREADY, dmai)
BEGIN
  IF curState = init THEN
    --HREADY <= 1;
    dmai.start <= 0;
  END IF;
END PROCESS; -- combi_out
-- =================================================
-- Set values in state "instr_fetch"
PROCESS(curState, HREADY, dmai)
BEGIN
  IF curState = instr_fetch THEN
    HREADY <= 0;
    dmai.start <= 0;
  END IF;
END PROCESS; -- combi_out

-- instantiate the ahbmst component and make the connections
-- instantiate the data_swapper component and make the connections
end structural;