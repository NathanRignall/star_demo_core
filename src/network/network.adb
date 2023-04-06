with Ada.Streams;
with Ada.Text_IO;

with Hardware;

package body Network is

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Network Initialize");

      Ada.Text_IO.Put_Line ("Device Id" & Device_Identifier'Image);

      -- connect some dummy devices

      Connected_Device_Cloud_Array (1) := (Identifier => 1, Active => True);

   end Initialize;

   procedure Receive_Packet (Packet : out Packet_Type);
   procedure Process_Packet (Packet : Packet_Type);

   procedure Schedule is
      Packet : Packet_Type;
   begin

      Ada.Text_IO.Put_Line("Test");

      -- check if there is a new packet
      if Hardware.Ethernet.Is_New_Data then

         Ada.Text_IO.Put_Line("New Data");

        Process_Packet (Packet);

      end if;

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
      Source_Address : Drivers.Ethernet.Address_V4_Access_Type;
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
      Connected_Device : Connected_Device_Type;
   begin

      for Device_Index in Connected_Device_Index_Type loop

         Connected_Device := Connected_Device_Radio_Array (Device_Index);

         if Connected_Device.Active
           and then Connected_Device.Identifier = Device_Identifier
         then

            return True;

         end if;

      end loop;

      return False;

   end Is_Connected_Direct;

   procedure Send_Packet (Packet : Packet_Type) is
   begin

      if Is_Connected_Direct (Packet.Target) then

         -- lookup the port and ip of target

         null;

      end if;

      -- Check if destination is direct link
      -- if so, send packet to destination
      -- if not, send to server

      null;

   end Send_Packet;

   procedure Send_Packet_Alive is
      Packet_Alive : Packet_Type;

      Test_Address : Drivers.Ethernet.Address_V4_Access_Type :=
        new Drivers.Ethernet.Address_V4_Type'(10, 16, 0, 60);
   begin

      Packet_Alive :=
        Packet_Type'
          (Packet_Variant => Alive, Packet_Number => 0,
           Source => Device_Identifier, Target => 0, Payload_Length => 0,
           Payload        => Payload_Array_Default, Broadcast => True);

      Send_Packet (Packet_Alive);

   end Send_Packet_Alive;

end Network;
