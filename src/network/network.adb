with Ada.Streams;
with Ada.Text_IO;

with Hardware;

package body Network is

   procedure Recieve_Process_Packets;

   procedure Receive_Packet
     (Transport           :     Transport_Type; Packet : out Packet_Type;
      Source_Address_Port : out Drivers.Ethernet.Address_Port_Type);

   procedure Process_Packet
     (Transport           : Transport_Type; Packet : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type);

   procedure Process_Alive_Packet
     (Transport           : Transport_Type; Packet : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type);

   procedure Send_Packet (Packet : Packet_Type);

   procedure Send_Packet_Alive;

   procedure Send_Telemetry;

   procedure Cleanup_Connected_Device_Array;

   procedure Lookup_Address
     (Transport : Transport_Type; Device_Identifier : Device_Identifier_Type;
      Device_Address : out Drivers.Ethernet.Address_V4_Type);

   function Is_Connected
     (Transport : Transport_Type; Device_Identifier : Device_Identifier_Type)
      return Boolean;

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Network Initialize");

      Ada.Text_IO.Put_Line ("Device Id" & Device_Identifier'Image);

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is

         when Types.Schedule.S_20ms =>
            Recieve_Process_Packets;

         when Types.Schedule.S_100ms =>
            Send_Telemetry;

         when Types.Schedule.S_500ms =>
            Cleanup_Connected_Device_Array;

         when Types.Schedule.S_2000ms =>
            Send_Packet_Alive;
            
         when others =>
            null;

      end case;

   end Schedule;

   procedure Recieve_Process_Packets is
      Packet              : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type;
   begin
      -- loop for a maximum of 100 times for radio
      for Index in 1 .. 100 loop

         -- check if there is a new packet
         if Hardware.Radio.Is_New_Data then

            -- get the packet
            Receive_Packet (Radio, Packet, Source_Address_Port);

            -- process the packet
            Process_Packet (Radio, Packet, Source_Address_Port);

         else

            exit;

         end if;

      end loop;

      -- loop for a maximum of 100 times for cloud
      for Index in 1 .. 100 loop

         -- check if there is a new packet
         if Hardware.Cloud.Is_New_Data then

            -- get the packet
            Receive_Packet (Cloud, Packet, Source_Address_Port);

            -- process the packet
            Process_Packet (Cloud, Packet, Source_Address_Port);

         else

            exit;

         end if;

      end loop;
   end Recieve_Process_Packets;

   procedure Receive_Packet
     (Transport           :     Transport_Type; Packet : out Packet_Type;
      Source_Address_Port : out Drivers.Ethernet.Address_Port_Type)
   is
      Data : Ada.Streams.Stream_Element_Array (1 .. 1_024) := (others => 0);
      Last : Ada.Streams.Stream_Element_Offset;

      New_Packet : Packet_Type;
      for New_Packet'Address use Data'Address;
   begin

      case Transport is

         when Radio =>
            Hardware.Radio.Receive
              (Source_Address_Port.Address, Source_Address_Port.Port, Data,
               Last);

         when Cloud =>
            Hardware.Cloud.Receive
              (Source_Address_Port.Address, Source_Address_Port.Port, Data,
               Last);

      end case;

      Packet := New_Packet;

   end Receive_Packet;

   procedure Process_Packet
     (Transport           : Transport_Type; Packet : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type)
   is
   begin

      if Packet.Packet_Variant'Valid then

         case Packet.Packet_Variant is

            when Alive =>

               Process_Alive_Packet (Transport, Packet, Source_Address_Port);

            when Telemetry =>
               Ada.Text_IO.Put_Line ("Telemetry" & Packet.Source'Image);

            when Command =>
               Ada.Text_IO.Put_Line ("Request" & Packet.Source'Image);

            when Response =>
               Ada.Text_IO.Put_Line ("Response" & Packet.Source'Image);

            when Unknown =>
               Ada.Text_IO.Put_Line ("Unknown" & Packet.Source'Image);

         end case;

         null;

      else

         Ada.Text_IO.Put_Line ("Invalid");

      end if;

   end Process_Packet;

   procedure Process_Alive_Packet
     (Transport           : Transport_Type; Packet : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type)
   is
      No_Space : exception;

      use type Drivers.Ethernet.Address_V4_Type;
   begin

      -- check if the device is already connected
      if not Is_Connected (Transport, Packet.Source) then

         -- add the device to the connected device array
         for Device_Index in Connected_Device_Index_Type loop

            if not Connected_Device_Transport_Array (Transport) (Device_Index)
                .Active
            then

               Connected_Device_Transport_Array (Transport) (Device_Index) :=
                 Connected_Device_Type'
                   (Identifier => Packet.Source, Active => True,
                    Time       => Ada.Real_Time.Clock);

               -- add the device to the device address array
               for Device_Address_Index in Device_Address_Index_Type loop

                  if Device_Address_Transport_Array (Transport)
                      (Device_Address_Index)
                      .Identifier =
                    0
                  then

                     Ada.Text_IO.Put_Line
                       ("Add IP:" & Source_Address_Port.Address (1)'Image &
                        "." & Source_Address_Port.Address (2)'Image & "." &
                        Source_Address_Port.Address (3)'Image & "." &
                        Source_Address_Port.Address (4)'Image & " ID:" &
                        Packet.Source'Image & " Transport: " &
                        Transport'Image);

                     Device_Address_Transport_Array (Transport)
                       (Device_Address_Index) :=
                       Device_Address_Type'
                         (Identifier => Packet.Source,
                          Address    => Source_Address_Port.Address);

                     return;

                  elsif Device_Address_Index = Device_Address_Index_Type'Last
                  then

                     -- exception
                     raise No_Space with "No Space in Device Address Array";

                  end if;

               end loop;

            elsif Device_Index = Connected_Device_Index_Type'Last then

               -- exception
               raise No_Space with "No Space in Connected Device Array";

            end if;

         end loop;

      else

         -- update the time
         for Device_Index in Connected_Device_Index_Type loop

            if Connected_Device_Transport_Array (Transport) (Device_Index)
                .Identifier =
              Packet.Source
            then

               Connected_Device_Transport_Array (Transport) (Device_Index)
                 .Time :=
                 Ada.Real_Time.Clock;

               -- check the ip address
               for Device_Address_Index in Device_Address_Index_Type loop

                  if Device_Address_Transport_Array (Transport)
                      (Device_Address_Index)
                      .Identifier =
                    Packet.Source
                  then

                     -- check if the ip address has changed
                     if Device_Address_Transport_Array (Transport)
                         (Device_Address_Index)
                         .Address /=
                       Source_Address_Port.Address
                     then

                        Ada.Text_IO.Put_Line
                          ("Update IP:" &
                           Source_Address_Port.Address (1)'Image & "." &
                           Source_Address_Port.Address (2)'Image & "." &
                           Source_Address_Port.Address (3)'Image & "." &
                           Source_Address_Port.Address (4)'Image & " ID:" &
                           Packet.Source'Image & " Transport: " &
                           Transport'Image);

                        -- update the ip address
                        Device_Address_Transport_Array (Transport)
                          (Device_Address_Index)
                          .Address :=
                          Source_Address_Port.Address;

                     end if;

                     return;

                  elsif Device_Address_Index = Device_Address_Index_Type'Last
                  then

                     -- exception
                     raise No_Space with "Device Address Not Found";

                  end if;

               end loop;

            elsif Device_Index = Connected_Device_Index_Type'Last then

               -- exception
               raise No_Space with "Device Not Found";

            end if;

         end loop;

      end if;

   end Process_Alive_Packet;

   procedure Send_Packet (Packet : Packet_Type) is
      Destination_Address : Drivers.Ethernet.Address_V4_Type := (127, 0, 0, 1);

      Last     : Ada.Streams.Stream_Element_Offset;
      New_Data : Ada.Streams.Stream_Element_Array (1 .. 263);
      for New_Data'Address use Packet'Address;
   begin

      -- check if a broadcast
      if not Packet.Broadcast then

         -- check if the intended destination is direct
         if Is_Connected (Radio, Packet.Target) then

            -- lookup the ip
            Lookup_Address (Radio, Packet.Target, Destination_Address);

            -- send the packet
            Hardware.Radio.Send
              (Address => Destination_Address, Port => Hardware.Radio.Port,
               Data    => New_Data, Last => Last);

         elsif Is_Connected (Cloud, Packet.Target) then

            -- lookup the ip
            Lookup_Address (Cloud, Packet.Target, Destination_Address);

            -- send the packet
            Hardware.Cloud.Send
              (Address => Destination_Address, Port => Hardware.Cloud.Port,
               Data    => New_Data, Last => Last);

         else

            Ada.Text_IO.Put_Line ("Unknown Target");

         end if;

      else

         -- send the packet on radio multicast
         Hardware.Radio.Send
           (Address => Hardware.Radio.Multicast_Address.all,
            Port    => Hardware.Radio.Port, Data => New_Data, Last => Last);

         -- send the packet on cloud multicast
         Hardware.Cloud.Send
           (Address => Hardware.Cloud.Multicast_Address.all,
            Port    => Hardware.Cloud.Port, Data => New_Data, Last => Last);

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

   procedure Send_Telemetry is
      Packet_Telemetry : Packet_Type;
   begin

      Packet_Telemetry :=
        Packet_Type'
          (Packet_Variant => Telemetry, Packet_Number => 0,
           Source => Device_Identifier, Target => 0, Payload_Length => 0,
           Payload        => Payload_Array_Default, Broadcast => False);

      -- telemetry needs to sent to all connected devices on the radio

      -- loop through the connected device array
      for Device_Index in Connected_Device_Index_Type loop

         -- check if the device is active
         if Connected_Device_Transport_Array (Radio) (Device_Index).Active
         then

            -- set the target
            Packet_Telemetry.Target :=
              Connected_Device_Transport_Array (Radio) (Device_Index)
                .Identifier;

            -- send the packet
            Send_Packet (Packet_Telemetry);

         end if;

      end loop;


   end Send_Telemetry;

   procedure Cleanup_Connected_Device_Array is
      Current_Time   : Ada.Real_Time.Time;
      Timeout_Time   : Ada.Real_Time.Time;

      use type Ada.Real_Time.Time;
   begin

      for Transport in Transport_Type loop

         -- loop through the connected device array
         for Device_Index in Connected_Device_Index_Type loop

            -- check if the device is active
            if Connected_Device_Transport_Array (Transport) (Device_Index)
                .Active
            then

               -- get the current time
               Current_Time := Ada.Real_Time.Clock;

               -- get the timeout time
               Timeout_Time :=
                 Connected_Device_Transport_Array (Transport) (Device_Index)
                   .Time +
                 Device_Timeout;

               -- check if the device has timed out
               if Current_Time > Timeout_Time then

                  -- remove the device from the device address array
                  for Device_Address_Index in Device_Address_Index_Type loop

                     if Device_Address_Transport_Array (Transport)
                         (Device_Address_Index)
                         .Identifier =
                       Connected_Device_Transport_Array (Transport)
                         (Device_Index)
                         .Identifier
                     then

                        Ada.Text_IO.Put_Line
                          ("Remove IP:" &
                           Device_Address_Transport_Array (Transport)
                             (Device_Address_Index)
                             .Address
                             (1)'
                             Image &
                           "." &
                           Device_Address_Transport_Array (Transport)
                             (Device_Address_Index)
                             .Address
                             (2)'
                             Image &
                           "." &
                           Device_Address_Transport_Array (Transport)
                             (Device_Address_Index)
                             .Address
                             (3)'
                             Image &
                           "." &
                           Device_Address_Transport_Array (Transport)
                             (Device_Address_Index)
                             .Address
                             (4)'
                             Image &
                           "." & " ID:" &
                           Connected_Device_Transport_Array (Transport)
                             (Device_Index)
                             .Identifier'
                             Image &
                           " Transport: " & Transport'Image);

                        -- remove the device from the device address array
                        Device_Address_Transport_Array (Transport)
                          (Device_Address_Index) :=
                          Device_Address_Default;

                     end if;

                  end loop;

                  -- remove the device from the connected device array
                  Connected_Device_Transport_Array (Transport)
                    (Device_Index) :=
                    Connected_Device_Default;

               end if;

            end if;

         end loop;

      end loop;

   end Cleanup_Connected_Device_Array;

   procedure Lookup_Address
     (Transport : Transport_Type; Device_Identifier : Device_Identifier_Type;
      Device_Address : out Drivers.Ethernet.Address_V4_Type)
   is
   begin

      for Device_Address_Index in Device_Address_Index_Type loop

         if Device_Address_Transport_Array (Transport) (Device_Address_Index)
             .Identifier =
           Device_Identifier
         then

            Device_Address :=
              Device_Address_Transport_Array (Transport) (Device_Address_Index)
                .Address;

            return;

         end if;

      end loop;

   end Lookup_Address;

   function Is_Connected
     (Transport : Transport_Type; Device_Identifier : Device_Identifier_Type)
      return Boolean
   is
   begin

      for Device_Index in Connected_Device_Index_Type loop

         if Connected_Device_Transport_Array (Transport) (Device_Index).Active
           and then
             Connected_Device_Transport_Array (Transport) (Device_Index)
               .Identifier =
             Device_Identifier
         then

            return True;

         end if;

      end loop;

      return False;

   end Is_Connected;

end Network;
