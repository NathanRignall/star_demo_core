with Ada.Environment_Variables;
with Ada.Text_IO;

with Drivers.Ethernet;
with Hardware;
with Network;

package body Config is

   procedure Load_Config;

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Config Initialize");

      Load_Config;

   end Initialize;

   procedure Load_Config is
      Device_Identifier : constant String :=
        Ada.Environment_Variables.Value ("DEVICE_IDENTIFIER");

      Cloud_Address           : constant String :=
        Ada.Environment_Variables.Value ("CLOUD_ADDRESS");
      Cloud_Multicast_Address : constant String :=
        Ada.Environment_Variables.Value ("CLOUD_MULTICAST_ADDRESS");

      Radio_Address           : constant String :=
        Ada.Environment_Variables.Value ("RADIO_ADDRESS");
      Radio_Multicast_Address : constant String :=
        Ada.Environment_Variables.Value ("RADIO_MULTICAST_ADDRESS");

      use type Drivers.Ethernet.Address_Octet_Type;

   begin

      Network.Device_Identifier :=
        Network.Device_Identifier_Type'Value (Device_Identifier);

      -- create new cloud address
      Hardware.Cloud_Address.all :=
        Drivers.Ethernet.Address_V4_Type'
          (1 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Address (1 .. 3)),
           2 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Address (5 .. 7)),
           3 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Address (9 .. 11)),
           4 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Address (13 .. 15)));

      -- create new cloud broadcast address
      Hardware.Cloud_Multicast_Address.all :=
        Drivers.Ethernet.Address_V4_Type'
          (1 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address (1 .. 3)),
           2 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address (5 .. 7)),
           3 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address (9 .. 11)),
           4 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Cloud_Multicast_Address (13 .. 15)));

      -- create new radio address
      Hardware.Radio_Address.all :=
        Drivers.Ethernet.Address_V4_Type'
          (1 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Address (1 .. 3)),
           2 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Address (5 .. 7)),
           3 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Address (9 .. 11)),
           4 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Address (13 .. 15)));

      -- create new radio broadcast address
      Hardware.Radio_Multicast_Address.all :=
        Drivers.Ethernet.Address_V4_Type'
          (1 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address (1 .. 3)),
           2 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address (5 .. 7)),
           3 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address (9 .. 11)),
           4 =>
             Drivers.Ethernet.Address_Octet_Type'Value
               (Radio_Multicast_Address (13 .. 15)));

   end Load_Config;

end Config;
