with Ada.Environment_Variables;
with Ada.Text_IO;

package body Hardware is

   procedure Initialize is
      Cloud_Multicast_Address_Env : constant String :=
        Ada.Environment_Variables.Value ("CLOUD_MULTICAST_ADDRESS");

      Radio_Multicast_Address_Env : constant String :=
        Ada.Environment_Variables.Value ("RADIO_MULTICAST_ADDRESS");
   begin

      Ada.Text_IO.Put_Line ("Hardware Initialize");

      -- create new radio broadcast address
      Hardware.Radio_Multicast_Address.all :=
        Drivers.Ethernet.Address_V4_Type'
          (1 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address_Env (1 .. 3)),
           2 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address_Env (5 .. 7)),
           3 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address_Env (9 .. 11)),
           4 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address_Env (13 .. 15)));

      -- create new cloud broadcast address
      Hardware.Cloud_Multicast_Address.all :=
        Drivers.Ethernet.Address_V4_Type'
          (1 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address_Env (1 .. 3)),
           2 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address_Env (5 .. 7)),
           3 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address_Env (9 .. 11)),
           4 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address_Env (13 .. 15)));

      Radio.Initialize;
      Cloud.Initialize;

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is

         when others =>
            null;
            
      end case;

   end Schedule;

end Hardware;
