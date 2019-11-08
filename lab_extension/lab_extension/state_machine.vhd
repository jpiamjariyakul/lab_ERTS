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

entity state_machine is
  port(
    -- Clock and Reset -----------------
    clkm : in std_logic;
    rstn : in std_logic;
    -- AHB Master records --------------
    --dmai : out ahb_dma_out_type;
    --dmao : in ahb_dma_in_type;
    dmai : out ahb_dma_in_type;
    dmao : in ahb_dma_out_type;
    -- ARM Cortex-M0 AHB-Lite signals --
    HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: nonsequential only
    HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : in std_logic; -- AHB write control
    --HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
    HREADY : out std_logic -- AHB stall signal
  );
end;
--------------------------------------------------------
architecture structural of state_machine is
  
TYPE state_type is (idle, instr_fetch);  -- List your states here 	
SIGNAL curState, nextState: STATE_TYPE;
begin
  
combi_nextState: process(curState, HTRANS, dmao)
  --variable v_dmaiStart : ahb_dma_out_type;
  --variable v_HREADY : std_logic;
BEGIN
  CASE curState IS
    WHEN idle =>
      IF HTRANS = "10" THEN
        --dmai.start <= '1';
        --v_dmaiStart := '1';
        nextState <= instr_fetch;
      ELSE
        nextState <= curState;
      END IF;
    
    WHEN instr_fetch =>
      IF dmao.ready = '1' THEN
        --HREADY <= '1';
        --v_HREADY := '1';
        nextState <= idle; -- Fill in
      ELSE
        nextState <= curState; -- Fill in
      END IF;
    WHEN others => -- Fallback vals in case reaches other state
      nextState <= idle;
  end case;
  
  --dmai.start <= v_dmaiStart;
  --HREADY <= v_HREADY;
  
END PROCESS; -- combi_nextState
----------------------------------------
combi_setVal: PROCESS(curState, dmao, HADDR, HSIZE, HTRANS, HWDATA, HWRITE)
  variable v_dmaiStart : std_ulogic;
  variable v_HREADY : std_logic;
BEGIN
  v_dmaiStart := '0';
  -- state idle
  IF curState = idle THEN
    v_HREADY := '1';
    if HTRANS = "10" THEN
      v_dmaiStart := '1';
    end if;
  -- state instr_fetch
  ELSIF curState = instr_fetch THEN
    v_HREADY := '0';
    if dmao.ready = '1' THEN
      v_HREADY := '1';
    end if;
  END IF;
  -- Outputs vars to actual vals
  dmai.start <= v_dmaiStart;
  HREADY <= v_HREADY;
  -- Passes values from dmao to other H-based ports
  dmai.address <= HADDR;
  dmai.size <= HSIZE;
  dmai.wdata <= HWDATA;
  dmai.write <= HWRITE;
  --dmai.busy <= HTRANS;
END PROCESS; -- combi_out
----------------------------------------
combi_ResetState: PROCESS (clkm, rstn)
BEGIN
  IF rstn = '0' THEN
    curState <= idle;
  ELSIF rising_edge(clkm) THEN
    curState <= nextState;
  END IF;
END PROCESS; -- seq

end structural;