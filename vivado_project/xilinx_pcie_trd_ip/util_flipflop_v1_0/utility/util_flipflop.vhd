-------------------------------------------------------------------------------
-- $Id: util_flipflop.vhd,v 1.1 2006/09/20 09:36:32 rolandp Exp $
-------------------------------------------------------------------------------
-- util_flipflop.vhd - Entity and architecture
--
--  ***************************************************************************
--  **  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
--
-----------------------------------------------------Is there a way to tell which release --------------------------
-- Filename:        util_flipflop.vhd
--
-- Description:     
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   
--              util_flipflop.vhd
--
-------------------------------------------------------------------------------
-- Author:          goran
-- Revision:        $Revision: 1.1 $
-- Date:            $Date: 2006/09/20 09:36:32 $
--
-- History:
--   goran  2003-06-06    First Version
--
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x" 
--      reset signals:                          "rst", "rst_n" 
--      generics:                               "C_*" 
--      user defined types:                     "*_TYPE" 
--      state machine next state:               "*_ns" 
--      state machine current state:            "*_cs" 
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.all;

entity util_flipflop is
  generic (
    C_SET_RST_HIGH : integer := 1;
    C_USE_RST      : integer := 1;
    C_USE_SET      : integer := 1;
    C_USE_CE       : integer := 1;
    C_USE_ASYNCH   : integer := 1;
    C_SIZE         : integer := 8;
    C_INIT         : string  := "0"
    );
  port (
    Clk : in  std_logic;
    Rst : in  std_logic;
    Set : in  std_logic;
    CE  : in  std_logic;
    D   : in  std_logic_vector(0 to C_SIZE-1);
    Q   : out std_logic_vector(0 to C_SIZE-1)
    --Q_AND : out std_logic
    );

  attribute SIGIS : string;
  attribute SIGIS of Clk : signal is "CLK";

end util_flipflop;

architecture IMP of util_flipflop is

  component FDRSE is
    -- pragma translate_off
   generic(
      INIT : bit := '0'
      );
    -- pragma translate_on    
    port (
      Q  : out std_logic;
      C  : in  std_logic;
      CE : in  std_logic;
      D  : in  std_logic;
      R  : in  std_logic;
      S  : in  std_logic);
  end component FDRSE;

  component FDCPE is
    -- pragma translate_off
    generic(
      INIT : bit := '0'
      );
    -- pragma translate_on    
    port (
      Q   : out std_logic;
      C   : in  std_logic;
      CE  : in  std_logic;
      D   : in  std_logic;
      CLR : in  std_logic;
      PRE : in  std_logic);
  end component FDCPE;

  function Get_Init(From : String; Index : Positive) return bit is
  begin
    if From'length = 1 then
      if From = "1" then
        return '1';
      end if;
    elsif Index <= From'high and Index >= From'low then
      if From(Index) = '1' then
        return '1';
      end if;
    end if;
    return '0';
  end function Get_Init;

  function Bit2Str(constant val : bit) return string is
  begin
    if val = '1' then
      return "1";
    else
      return "0";
    end if;
  end function Bit2Str;
  
  signal ce_i  : std_logic;
  signal rst_i : std_logic;
  signal set_i : std_logic;  
  signal q_and_i : std_logic := '1';
  signal q_i   : std_logic_vector(0 to C_SIZE-1);
begin

  assert not(C_SIZE > C_INIT'length and C_INIT'length /= 1)
    report "C_INIT string length does not match C_SIZE of util_flipflop"
      severity failure;

  Using_CE : if (C_USE_CE = 1) generate
    ce_i <= CE;
  end generate Using_CE;

  No_CE : if (C_USE_CE /= 1) generate
    ce_i <= '1';
  end generate No_CE;

  Using_RST : if (C_USE_RST = 1) generate
    rst_i <= RST when C_SET_RST_HIGH = 1 else
             not RST;
  end generate Using_RST;

  No_Rst : if (C_USE_RST /= 1) generate
    rst_i <= '0';
  end generate No_Rst;

  Using_SET : if (C_USE_SET = 1) generate
    set_i <= SET when C_SET_RST_HIGH = 1 else
             not SET;
  end generate Using_SET;

  No_Set : if (C_USE_SET /= 1) generate
    set_i <= '0';
  end generate No_Set;

  Using_ASYNCH : if (C_USE_ASYNCH = 1) generate
    All_Bits : for I in 0 to C_SIZE-1 generate
      attribute INIT : string;
      attribute INIT of FDCPE_I1 : label is Bit2Str(Get_Init(C_INIT,I+1));
    begin
      FDCPE_I1 : FDCPE
        -- pragma translate_off
        generic map (
          INIT => Get_Init(C_INIT,I+1))   -- [bit]
        -- pragma translate_on
        port map (
          Q   => q_i(I),                  -- [out std_logic]
          C   => Clk,                   -- [in  std_logic]
          CE  => ce_i,                  -- [in  std_logic]
          D   => D(I),                  -- [in  std_logic]
          CLR => rst_i,                 -- [in  std_logic]
          PRE => set_i);                -- [in  std_logic]
     
          --q_and_i <= q_and_i and q_i(i);

    end generate All_Bits;
  end generate Using_ASYNCH;

  Using_SYNCH : if (C_USE_ASYNCH /= 1) generate
    All_Bits : for I in 0 to C_SIZE-1 generate
      attribute INIT : string;
      attribute INIT of FDRSE_I1 : label is Bit2Str(Get_Init(C_INIT,I+1));
    begin
      FDRSE_I1 : FDRSE
        -- pragma translate_off
        generic map (
          INIT => Get_Init(C_INIT,I+1))   -- [bit]
        -- pragma translate_on
        port map (
          Q  => q_i(I),                   -- [out std_logic]
          C  => Clk,                    -- [in  std_logic]
          CE => ce_i,                   -- [in  std_logic]
          D  => D(I),                   -- [in  std_logic]
          R  => rst_i,                  -- [in  std_logic]
          S  => set_i);                 -- [in  std_logic]
          
         -- q_and_i <= q_and_i and q_i(i);
          
    end generate All_Bits;
    
  end generate Using_SYNCH;



        Q <= q_i;
        --  Q_AND <= q_and_i;
          
          
end IMP;

