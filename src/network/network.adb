with Ada.Streams;
with Ada.Text_IO;

with Hardware;

package body Network is

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Network Initialize");

      Ada.Text_IO.Put_Line ("Device Id" & Device_Identifier'Image);

      -- connect some dummy devices

      Connected_Device_Radio_Array (0) := (Identifier => 200, Active => True);
      Device_Address_Radio_Array (0)   :=
        Device_Address_Type'
          (Identifier => 200,
           Address    => Drivers.Ethernet.Address_V4_Type'(127, 0, 0, 1));

   end Initialize;

   procedure Receive_Packet (Packet : out Packet_Type);
   procedure Process_Packet (Packet : Packet_Type);
   procedure Send_Packet (Packet : Packet_Type);
   procedure Send_Packet_Alive;

   procedure Schedule is
      Packet : Packet_Type;

      Test_Packet : Packet_Type :=
        Packet_Type'
          (Packet_Variant => Command, Packet_Number => 0, Broadcast => False,
           Source => Device_Identifier, Target => 200, Payload_Length => 0,
           Payload        => Payload_Array_Default);

   begin

      Send_Packet_Alive;

      -- check if there is a new packet
      if Hardware.Ethernet.Is_New_Data then

         -- get the packet
         Receive_Packet (Packet);

         -- process the packet
         Process_Packet (Packet);

      end if;

      -- send a dummy packet
      Send_Packet (Test_Packet);

      -- get all the new packets

      -- process all the packets

      -- check if the intended destination is the local node
      -- if so add to array
      -- if not, forward the packet
      -- check if direct link
      -- if so, forward
      -- if not, forward to server
      -- server will forward to next hop

   end Schedule;

   procedure Receive_Packet (Packet : out Packet_Type) is
      Source_Address : Drivers.Ethernet.Address_V4_Type;
      Source_Port    : Drivers.Ethernet.Port_Type;
      Data : Ada.Streams.Stream_Element_Array (1 .. 1_024) := (others => 0);
      Last           : Ada.Streams.Stream_Element_Offset;

      New_Packet : Packet_Type;
      for New_Packet'Address use Data'Address;
   begin

      Hardware.Ethernet.Receive (Source_Address, Source_Port, Data, Last);

      Packet := New_Packet;

   end Receive_Packet;

   procedure Process_Packet (Packet : Packet_Type) is
   begin

      if Packet.Packet_Variant'Valid then

         case Packet.Packet_Variant is

            when Alive =>
               Ada.Text_IO.Put_Line ("Alive");

            when Telemetry =>
               Ada.Text_IO.Put_Line ("Data");

            when Command =>
               Ada.Text_IO.Put_Line ("Request");

            when Response =>
               Ada.Text_IO.Put_Line ("Response");

            when Unknown =>
               Ada.Text_IO.Put_Line ("Unknown");

         end case;

         null;

      else

         Ada.Text_IO.Put_Line ("Invalid");

      end if;

   end Process_Packet;

   function Is_Connected_Direct
     (Device_Identifier : Device_Identifier_Type) return Boolean
   is
   begin

      for Device_Index in Connected_Device_Index_Type loop

         if Connected_Device_Radio_Array (Device_Index).Active
           and then Connected_Device_Radio_Array (Device_Index).Identifier =
             Device_Identifier
         then

            return True;

         end if;

      end loop;

      return False;

   end Is_Connected_Direct;

   procedure Lookup_Address
     (Device_Identifier    :     Device_Identifier_Type;
      Device_Address_Array :     Device_Address_Array_Type;
      Device_Address       : out Drivers.Ethernet.Address_V4_Type)
   is
   begin

      -- loop through the array and find the address
      for Device_Address_Index in Device_Address_Index_Type loop

         if Device_Address_Array (Device_Address_Index).Identifier =
           Device_Identifier
         then

            Device_Address :=
              Device_Address_Array (Device_Address_Index).Address;

            return;

         end if;

      end loop;

   end Lookup_Address;

   procedure Send_Packet (Packet : Packet_Type) is
      Destination_Address    : Drivers.Ethernet.Address_V4_Type;
      Destination_Port_Radio : Drivers.Ethernet.Port_Type := 5_001;
      Destination_Port_Cloud : Drivers.Ethernet.Port_Type := 5_002;

      Last     : Ada.Streams.Stream_Element_Offset;
      New_Data : Ada.Streams.Stream_Element_Array (1 .. 512);
      for New_Data'Address use Packet'Address;
   begin

      -- check if a broadcast
      if not Packet.Broadcast then

         -- check if the intended destination is direct
         if Is_Connected_Direct (Packet.Target) then

            -- lookup the ip
            Lookup_Address
              (Packet.Target, Device_Address_Radio_Array, Destination_Address);

            -- send the packet
            Hardware.Ethernet.Send
              (Address => Destination_Address, Port => Destination_Port_Radio,
               Data    => New_Data, Last => Last);

         else

            -- lookup the ip
            Lookup_Address
              (Packet.Target, Device_Address_Cloud_Array, Destination_Address);

            -- send the packet
            Hardware.Ethernet.Send
              (Address => Destination_Address, Port => Destination_Port_Cloud,
               Data    => New_Data, Last => Last);

         end if;

      else

         -- send the packet
         Hardware.Ethernet.Send
           (Address => Hardware.Ethernet.Broadcast_Address.all,
            Port    => Destination_Port_Cloud, Data => New_Data, Last => Last);

      end if;

   end Send_Packet;

   procedure Send_Packet_Alive is
      Packet_Alive : Packet_Type;
   begin

      Packet_Alive :=
        Packet_Type'
          (Packet_Variant => Alive, Packet_Number => 0,
           Source => Device_Identifier, Target => 0, Payload_Length => 0,
           Payload        => Payload_Array_Default, Broadcast => True);

      Send_Packet (Packet_Alive);

   end Send_Packet_Alive;

end Network;
