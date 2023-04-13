with Ada.Real_Time;
with Interfaces;
with Drivers.Ethernet;

package Network is

   type Device_Identifier_Type is mod 2**16;
   for Device_Identifier_Type'Size use 16;
   Device_Identifier_Default : constant Device_Identifier_Type := 0;

   Device_Identifier : Device_Identifier_Type := 10;

   -- Stores mapping of devices identifiers to their IP addresses

   type Device_Address_Index_Type is range 1 .. 10;
   Device_Address_Index_Default : constant Device_Address_Index_Type := 1;

   type Device_Address_Type is record
      Identifier : Device_Identifier_Type;
      Address    : Drivers.Ethernet.Address_V4_Type;
   end record;
   Device_Address_Default : constant Device_Address_Type :=
     Device_Address_Type'
       (Identifier => Device_Identifier_Default,
        Address    => Drivers.Ethernet.Address_V4_Default);

   type Device_Address_Array_Type is
     array (Device_Address_Index_Type) of Device_Address_Type;
   Device_Address_Array_Default : constant Device_Address_Array_Type :=
     Device_Address_Array_Type'(others => Device_Address_Default);

   Device_Address_Radio_Array : Device_Address_Array_Type :=
     Device_Address_Array_Default;

   Device_Address_Cloud_Array : Device_Address_Array_Type :=
     Device_Address_Array_Default;

   -- Store the list of devices currently connected to the network

   type Connected_Device_Index_Type is range 1 .. 10;
   Connected_Device_Index_Default : constant Connected_Device_Index_Type := 1;

   type Connected_Device_Type is record
      Identifier : Device_Identifier_Type;
      Active     : Boolean;
      Time       : Ada.Real_Time.Time;
   end record;
   Connected_Device_Default : constant Connected_Device_Type :=
     Connected_Device_Type'
       (Identifier => Device_Identifier_Default, Active => False,
        Time       => Ada.Real_Time.Clock);

   type Connected_Device_Array_Type is
     array (Connected_Device_Index_Type) of Connected_Device_Type;
   Connected_Device_Array_Default : constant Connected_Device_Array_Type :=
     Connected_Device_Array_Type'(others => Connected_Device_Default);

   Connected_Device_Radio_Array : Connected_Device_Array_Type :=
     Connected_Device_Array_Default;

   Connected_Device_Cloud_Array : Connected_Device_Array_Type :=
     Connected_Device_Array_Default;

   -- Define how packets are structured

   type Packet_Variant_Type is (Alive, Telemetry, Command, Response, Unknown);
   for Packet_Variant_Type use
     (Alive => 0, Telemetry => 1, Command => 2, Response => 3, Unknown => 4);
   for Packet_Variant_Type'Size use 4;
   Packet_Variant_Default : constant Packet_Variant_Type := Unknown;

   type Packet_Number_Type is mod 2**8;
   for Packet_Number_Type'Size use 8;
   Packet_Number_Default : constant Packet_Number_Type := 0;

   type Payload_Index_Type is mod 2**8;
   for Payload_Index_Type'Size use 8;
   Payload_Index_Default : constant Payload_Index_Type := 0;

   type Payload_Array_Type is
     array (Payload_Index_Type) of Interfaces.Unsigned_8;
   for Payload_Array_Type'Size use 2_048;
   Payload_Array_Default : constant Payload_Array_Type :=
     Payload_Array_Type'(others => 0);

   type My_Boolean is new Boolean;
   for My_Boolean'Size use 1;

   type Packet_Type is record
      Packet_Variant : Packet_Variant_Type;
      Packet_Number  : Packet_Number_Type;
      Broadcast      : My_Boolean;
      Source         : Device_Identifier_Type;
      Target         : Device_Identifier_Type;
      Payload_Length : Payload_Index_Type;
      Payload        : Payload_Array_Type;
   end record;
   for Packet_Type use record
      Packet_Variant at 0 * 16 range  0 ..     3;
      Packet_Number  at 0 * 16 range  4 ..    11;
      Broadcast      at 0 * 16 range 12 ..    12;
      Source         at 0 * 16 range 13 ..    28;
      Target         at 0 * 16 range 29 ..    44;
      Payload_Length at 0 * 16 range 45 ..    52;
      Payload        at 0 * 16 range 53 .. 2_103;
   end record;
   for Packet_Type'Size use 2_104;
   Packet_Default : constant Packet_Type :=
     Packet_Type'
       (Packet_Variant => Packet_Variant_Default,
        Packet_Number  => Packet_Number_Default,
        Source         => Device_Identifier_Default,
        Target         => Device_Identifier_Default,
        Payload_Length => Payload_Index_Default,
        Payload        => Payload_Array_Default, Broadcast => False);

   type Packet_Index_Type is mod 2**8;
   for Packet_Index_Type'Size use 8;
   Packet_Index_Default : constant Packet_Index_Type := 0;

   type Packet_Array_Type is array (Packet_Index_Type) of Packet_Type;
   for Packet_Array_Type'Size use 538_624;
   Packet_Array_Default : constant Packet_Array_Type :=
     Packet_Array_Type'(others => Packet_Default);

   procedure Initialize;

   procedure Schedule;

end Network;
