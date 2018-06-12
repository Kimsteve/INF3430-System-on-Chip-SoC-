
--************************************************************************
--**    MODEL   :       async_32Kx16.vhd                               **
--**    COMPANY :       Cypress Semiconductor                           **
--**    REVISION:       1.0 Created new base model                        ** 
--************************************************************************

library IEEE, work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use work.timing_pkg.all;
use work.utility_pkg.all;

-----------------------------
-- Architecture Description
-----------------------------

architecture behavorial of async_256kx16 is

  type mem_array_type is array (0 to depth-1) of std_logic_vector(DATA_BITS-1 downto 0);

  signal write_enable : std_logic;
  signal read_enable  : std_logic;
  signal byte_enable  : std_logic;

  signal data_skew : std_logic_vector(DATA_BITS-1 downto 0);

  signal address_internal : std_logic_vector(addr_bits-1 downto 0);

  constant tSD_dataskew : time := tSD - 1 ns;

begin

  byte_enable  <= not(nUB and nLB);
  write_enable <= not(nCE) and not(nWE) and byte_enable;
  read_enable  <= not(nCE) and (nWE) and not(nOE) and byte_enable;

  data_skew <= DQ after 1 ns;           -- changed on feb 15

  process (nOE)
  begin
    if (nOE'event and nOE = '1' and write_enable /= '1') then
      DQ <= (others => 'Z') after tHZOE;
    end if;
  end process;

  process (nCE)
  begin
    if (nCE'event and nCE = '1') then
      DQ <= (others => 'Z') after tHZCE;
    end if;
  end process;

  process (write_enable'delayed(tHA))
  begin
    if (write_enable'delayed(tHA) = '0' and TimingInfo) then
      assert (A'last_event = 0 ns) or (A'last_event > tHA)
        report "Address hold time tHA violated";
    end if;
  end process;

  process (write_enable'delayed(tHD))
  begin
    if (write_enable'delayed(tHD) = '0' and TimingInfo) then
      assert (DQ'last_event > tHD) or (DQ'last_event = 0 ns)
        report "Data hold time tHD violated";
    end if;
  end process;

-- main process
  process
    
    variable mem_array : mem_array_type;

    --- Variables for timing checks
    variable tPWE_chk : time := -10 ns;
    variable tAW_chk  : time := -10 ns;
    variable tSD_chk  : time := -10 ns;
    variable tRC_chk  : time := 0 ns;
    variable tBAW_chk : time := 0 ns;
    variable tBBW_chk : time := 0 ns;
    variable tBCW_chk : time := 0 ns;
    variable tBDW_chk : time := 0 ns;

    variable write_flag : boolean := true;

    variable accesstime : time := 0 ns;
    
  begin

    -- start of write
    if (write_enable = '1' and write_enable'event) then
      
      DQ(DATA_BITS-1 downto 0) <= (others => 'Z') after tHZWE;

      if (A'last_event >= tSA) then
        address_internal <= A;
        tPWE_chk         := NOW;
        tAW_chk          := A'last_event;
        write_flag       := true;

      else
        if (TimingInfo) then
          assert false
            report "Address setup violated";
        end if;
        write_flag := false;

      end if;

      -- end of write (with CE high or WE high)
    elsif (write_enable = '0' and write_enable'event) then

      --- check for pulse width
      if (NOW - tPWE_chk >= tPWE or NOW - tPWE_chk <= 0.1 ns or NOW = 0 ns) then
        --- pulse width OK, do nothing
      else
        if (TimingInfo) then
          assert false
            report "Pulse Width violation";
        end if;

        write_flag := false;
      end if;

      --- check for address setup with write end, i.e., tAW
      if (NOW - tAW_chk >= tAW or NOW = 0 ns) then
        --- tAW OK, do nothing
      else
        if (TimingInfo) then
          assert false
            report "Address setup tAW violation";
        end if;
        write_flag := false;
      end if;

      --- check for data setup with write end, i.e., tSD
      if (NOW - tSD_chk >= tSD_dataskew or NOW - tSD_chk <= 0.1 ns or NOW = 0 ns) then
        --- tSD OK, do nothing
      else
        if (TimingInfo) then
          assert false
            report "Data setup tSD violation";
        end if;
        write_flag := false;
      end if;

      -- perform write operation if no violations
      if (write_flag = true) then
        
        if (nLB = '1' and nLB'last_event = write_enable'last_event and NOW /= 0 ns) then
          mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
        end if;

        if (nUB = '1' and nUB'last_event = write_enable'last_event and NOW /= 0 ns) then
          mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
        end if;

        if (nLB = '0' and NOW - tBAW_chk >= tBW) then
          mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
        elsif (NOW - tBAW_chk < tBW and NOW - tBAW_chk > 0.1 ns and NOW > 0 ns) then
          assert false report "Insufficient pulse width for lower byte to be written";
        end if;

        if (nUB = '0' and NOW - tBBW_chk >= tBW) then
          mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
        elsif (NOW - tBBW_chk < tBW and NOW - tBBW_chk > 0.1 ns and NOW > 0 ns) then
          assert false report "Insufficient pulse width for higher byte to be written";
        end if;

      end if;

      -- end of write (with nUB high)
    elsif (nLB'event and not(nUB'event) and write_enable = '1') then

      if (nLB = '0') then

        --- Reset timing variables
        tAW_chk    := A'last_event;
        tBAW_chk   := NOW;
        write_flag := true;

      elsif (nLB = '1') then

        --- check for pulse width
        if (NOW - tPWE_chk >= tPWE) then
          --- tPWE OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Pulse Width violation";
          end if;

          write_flag := false;
        end if;

        --- check for address setup with write end, i.e., tAW
        if (NOW - tAW_chk >= tAW) then
          --- tAW OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Address setup tAW violation for Lower Byte Write";
          end if;

          write_flag := false;
        end if;

        --- check for byte write setup with write end, i.e., tBW
        if (NOW - tBAW_chk >= tBW) then
          --- tBW OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Lower Byte setup tBW violation";
          end if;

          write_flag := false;
        end if;

        --- check for data setup with write end, i.e., tSD
        if (NOW - tSD_chk >= tSD_dataskew or NOW - tSD_chk <= 0.1 ns or NOW = 0 ns) then
          --- tSD OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Data setup tSD violation for Lower Byte Write";
          end if;

          write_flag := false;
        end if;

        --- perform WRITE operation if no violations
        if (write_flag = true) then
          mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
          if (nUB = '0') then
            mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
          end if;
        end if;

        --- Reset timing variables
        tAW_chk    := A'last_event;
        tBAW_chk   := NOW;
        write_flag := true;

      end if;

      -- end of write (with nUB high)
    elsif (nUB'event and not(nLB'event) and write_enable = '1') then

      if (nUB = '0') then

        --- Reset timing variables
        tAW_chk    := A'last_event;
        tBBW_chk   := NOW;
        write_flag := true;

      elsif (nUB = '1') then

        --- check for pulse width
        if (NOW - tPWE_chk >= tPWE) then
          --- tPWE OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Pulse Width violation";
          end if;

          write_flag := false;
        end if;

        --- check for address setup with write end, i.e., tAW
        if (NOW - tAW_chk >= tAW) then
          --- tAW OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Address setup tAW violation for Upper Byte Write";
          end if;
          write_flag := false;
        end if;

        --- check for byte setup with write end, i.e., tBW
        if (NOW - tBBW_chk >= tBW) then
          --- tBW OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Upper Byte setup tBW violation";
          end if;

          write_flag := false;
        end if;

        --- check for data setup with write end, i.e., tSD
        if (NOW - tSD_chk >= tSD_dataskew or NOW - tSD_chk <= 0.1 ns or NOW = 0 ns) then
          --- tSD OK, do nothing
        else
          if (TimingInfo) then
            assert false
              report "Data setup tSD violation for Upper Byte Write";
          end if;

          write_flag := false;
        end if;

        --- perform WRITE operation if no violations
        if (write_flag = true) then
          mem_array(conv_integer1(address_internal))(15 downto 8) := data_skew(15 downto 8);
          if (nLB = '0') then
            mem_array(conv_integer1(address_internal))(7 downto 0) := data_skew(7 downto 0);
          end if;

        end if;

        --- Reset timing variables
        tAW_chk    := A'last_event;
        tBBW_chk   := NOW;
        write_flag := true;

      end if;

    end if;
    --- END OF WRITE

    if (data_skew'event and read_enable /= '1') then
      tSD_chk := NOW;
    end if;

    --- START of READ

    --- Tri-state the data bus if CE or OE disabled
    if (read_enable = '0' and read_enable'event) then
      if (nOE'last_event >= nCE'last_event) then
        DQ <= (others => 'Z') after tHZCE;
      elsif (nCE'last_event > nOE'last_event) then
        DQ <= (others => 'Z') after tHZOE;
      end if;
    end if;

    --- Address-controlled READ operation
    if (A'event) then
      if (A'last_event = nCE'last_event and nCE = '1') then
        DQ <= (others => 'Z') after tHZCE;
      end if;

      if (NOW - tRC_chk >= tRC or NOW - tRC_chk <= 0.1 ns or tRC_chk = 0 ns) then
        --- tRC OK, do nothing
      else
        
        if (TimingInfo) then
          assert false
            report "Read Cycle time tRC violation";
        end if;

      end if;

      if (read_enable = '1') then
        
        if (nLB = '0') then
          DQ (7 downto 0) <= mem_array (conv_integer1(A))(7 downto 0) after tAA;
        end if;

        if (nUB = '0') then
          DQ (15 downto 8) <= mem_array (conv_integer1(A))(15 downto 8) after tAA;
        end if;

        tRC_chk := NOW;

      end if;

      if (write_enable = '1') then
        --- do nothing
      end if;
      
    end if;

    if (read_enable = '0' and read_enable'event) then
      DQ <= (others => 'Z') after tHZCE;
      if (NOW - tRC_chk >= tRC or tRC_chk = 0 ns or A'last_event = read_enable'last_event) then
        --- tRC_chk needs to be reset when read ends
        tRC_CHK := 0 ns;
      else
        if (TimingInfo) then
          assert false
            report "Read Cycle time tRC violation";
        end if;
        tRC_CHK := 0 ns;
      end if;

    end if;

    --- READ operation triggered by CE/OE/nUB/nLB
    if (read_enable = '1' and read_enable'event) then

      tRC_chk := NOW;

      --- CE triggered READ
      if (nCE'last_event = read_enable'last_event) then  --  changed rev2

        if (nLB = '0') then
          DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after tACE;
        end if;

        if (nUB = '0') then
          DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after tACE;
        end if;

      end if;


      --- OE triggered READ  
      if (nOE'last_event = read_enable'last_event) then

        -- if address or CE changes before OE such that tAA/tACE > tDOE
        if (nCE'last_event < tACE - tDOE and A'last_event < tAA - tDOE) then

          if (A'last_event < nCE'last_event) then

            accesstime := tAA-A'last_event;
            if (nLB = '0') then
              DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
            end if;

            if (nUB = '0') then
              DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
            end if;

          else
            accesstime := tACE-nCE'last_event;
            if (nLB = '0') then
              DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
            end if;

            if (nUB = '0') then
              DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
            end if;
          end if;

          -- if address changes before OE such that tAA > tDOE
        elsif (A'last_event < tAA - tDOE) then

          accesstime := tAA-A'last_event;
          if (nLB = '0') then
            DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
          end if;

          if (nUB = '0') then
            DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
          end if;

          -- if CE changes before OE such that tACE > tDOE
        elsif (nCE'last_event < tACE - tDOE) then

          accesstime := tACE-nCE'last_event;
          if (nLB = '0') then
            DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
          end if;

          if (nUB = '0') then
            DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
          end if;

          -- if OE changes such that tDOE > tAA/tACE           
        else
          if (nLB = '0') then
            DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after tDOE;
          end if;

          if (nUB = '0') then
            DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after tDOE;
          end if;

        end if;
        
      end if;
      --- END of OE triggered READ

      --- nLB/nUB triggered READ  
      if (nLB'last_event = read_enable'last_event or nUB'last_event = read_enable'last_event) then

        -- if address or CE changes before nUB/nLB such that tAA/tACE > tDBE
        if (nCE'last_event < tACE - tDBE and A'last_event < tAA - tDBE) then

          if (A'last_event < nLB'last_event) then
            accesstime := tAA-A'last_event;

            if (nLB = '0') then
              DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
            end if;

            if (nUB = '0') then
              DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
            end if;

          else
            accesstime := tACE-nCE'last_event;

            if (nLB = '0') then
              DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
            end if;

            if (nUB = '0') then
              DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
            end if;
          end if;

          -- if address changes before nUB/nLB such that tAA > tDBE
        elsif (A'last_event < tAA - tDBE) then
          accesstime := tAA-A'last_event;

          if (nLB = '0') then
            DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
          end if;

          if (nUB = '0') then
            DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
          end if;

          -- if CE changes before nUB/nLB such that tACE > tDBE
        elsif (nCE'last_event < tACE - tDBE) then
          accesstime := tACE-nCE'last_event;

          if (nLB = '0') then
            DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after accesstime;
          end if;

          if (nUB = '0') then
            DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after accesstime;
          end if;

          -- if nUB/nLB changes such that tDBE > tAA/tACE   
        else
          if (nLB = '0') then
            DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after tDBE;
          end if;

          if (nUB = '0') then
            DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after tDBE;
          end if;

        end if;
        
      end if;
      -- END of nUB/nLB controlled READ

      if (nWE'last_event = read_enable'last_event) then

        if (nLB = '0') then
          DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after tACE;
        end if;

        if (nUB = '0') then
          DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after tACE;
        end if;

      end if;

    end if;
    --- END OF CE/OE/nUB/nLB controlled READ

    --- If either nUB or nLB toggle during read mode
    if (nLB'event and nLB = '0' and read_enable = '1' and not(read_enable'event)) then
      DQ (7 downto 0) <= mem_array (conv_integer1(A)) (7 downto 0) after tDBE;
    end if;

    if (nUB'event and nUB = '0' and read_enable = '1' and not(read_enable'event)) then
      DQ (15 downto 8) <= mem_array (conv_integer1(A)) (15 downto 8) after tDBE;
    end if;

    --- tri-state bus depending on nUB/nLB 
    if (nLB'event and nLB = '1') then
      DQ (7 downto 0) <= (others => 'Z') after tHZBE;
    end if;

    if (nUB'event and nUB = '1') then
      DQ (15 downto 8) <= (others => 'Z') after tHZBE;
    end if;

    wait on write_enable, A, read_enable, DQ, nLB, nUB, data_skew;
    
  end process;
end behavorial;

