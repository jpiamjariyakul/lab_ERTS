
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;

entity data_swapper is
--  generic (
 --   hindex  : integer := 0;
  --  hirq    : integer := 0;
   -- venid   : integer := VENDOR_GAISLER;
   -- devid   : integer := 0;
   -- version : integer := 0;
    -- chprot  : integer := 3;
    -- incaddr : integer := 0); 
   port (
      
      clkm : in std_ulogic;
      HRDATA : out STD_LOGIC_VECTOR(31 DOWNTO 0);
      dmao : in ahb_dma_out_type
      );
end;

architecture structural of data_swapper is
  signal R_data : std_logic_vector(31 DOWNTO 0);
begin

combi_data_swapper: PROCESS(clkm, dmao)
BEGIN
    HRDATA(31 downto 24) <= dmao.rdata(7 downto 0);
    HRDATA(23 downto 16) <= dmao.rdata(15 downto 8);
    HRDATA(15 downto 8) <= dmao.rdata(23 downto 16);
    HRDATA(7 downto 0) <= dmao.rdata(31 downto 24);
END PROCESS; 

end structural;