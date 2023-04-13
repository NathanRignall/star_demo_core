with Ada.Streams;
with Ada.Text_IO;

with Hardware;

package body Network is

   procedure Receive_Packet
     (Packet              : out Packet_Type;
      Source_Address_Port : out Drivers.Ethernet.Address_Port_Type);

   procedure Process_Packet
     (Packet              : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type);

   procedure Process_Alive_Packet
     (Packet              : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type);

   procedure Send_Packet (Packet : Packet_Type);

   procedure Send_Packet_Alive;

   procedure Cleanup_Connected_Device_Array;

   procedure Lookup_Address
     (Device_Identifier    :     Device_Identifier_Type;
      Device_Address_Array :     Device_Address_Array_Type;
      Device_Address       : out Drivers.Ethernet.Address_V4_Type);

   function Is_Connected_Direct
     (Device_Identifier : Device_Identifier_Type) return Boolean;

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Network Initialize");

      Ada.Text_IO.Put_Line ("Device Id" & Device_Identifier'Image);

      -- connect some dummy devices

      --  Connected_Device_Radio_Array (0) := (Identifier => 200, Active => True);
      --  Device_Address_Radio_Array (0)   :=
      --    Device_Address_Type'
      --      (Identifier => 200,
      --       Address    => Drivers.Ethernet.Address_V4_Type'(127, 0, 0, 1));

   end Initialize;

   procedure Schedule is
      Packet : Packet_Type;

      Test_Packet : Packet_Type :=
        Packet_Type'
          (Packet_Variant => Command, Packet_Number => 0, Broadcast => False,
           Source => Device_Identifier, Target => 200, Payload_Length => 0,
           Payload        => Payload_Array_Default);

      Source_Address_Port : Drivers.Ethernet.Address_Port_Type;

   begin

      Send_Packet_Alive;

      -- loop for a maximum of 20 times for radio
      for Index in 1 .. 20 loop

         -- check if there is a new packet
         if Hardware.Radio.Is_New_Data then

            -- get the packet
            Receive_Packet (Packet, Source_Address_Port);

            -- process the packet
            Process_Packet (Packet, Source_Address_Port);

         else

            exit;

         end if;

      end loop;

      Cleanup_Connected_Device_Array;

      --  -- loop for a maximum of 20 times for radio
      --  for Index in 1 .. 20 loop

      --     -- check if there is a new packet
      --     if Hardware.Radio.Is_New_Data then

      --        Ada.Text_IO.Put_Line("New Data Radio");

      --        -- get the packet
      --        Receive_Packet (Packet);

      --        -- process the packet
      --        Process_Packet (Packet);

      --     else

      --        exit;

      --        Ada.Text_IO.Put_Line("No New Data");

      --     end if;

      --  end loop;

      -- send a dummy packet
      --  Send_Packet (Test_Packet);

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

   procedure Receive_Packet
     (Packet              : out Packet_Type;
      Source_Address_Port : out Drivers.Ethernet.Address_Port_Type)
   is
      Data : Ada.Streams.Stream_Element_Array (1 .. 1_024) := (others => 0);
      Last : Ada.Streams.Stream_Element_Offset;

      New_Packet : Packet_Type;
      for New_Packet'Address use Data'Address;
   begin

      Hardware.Radio.Receive
        (Source_Address_Port.Address, Source_Address_Port.Port, Data, Last);

      Packet := New_Packet;

   end Receive_Packet;

   procedure Process_Packet
     (Packet              : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type)
   is
   begin

      if Packet.Packet_Variant'Valid then

         case Packet.Packet_Variant is

            when Alive =>

               Process_Alive_Packet (Packet, Source_Address_Port);

            when Telemetry =>
               Ada.Text_IO.Put_Line ("Data" & Packet.Source'Image);

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
     (Packet              : Packet_Type;
      Source_Address_Port : Drivers.Ethernet.Address_Port_Type)
   is
      No_Space : exception;

      use type Drivers.Ethernet.Address_V4_Type;
   begin

      -- check if the device is already connected
      if not Is_Connected_Direct (Packet.Source) then

         -- add the device to the connected device array
         for Device_Index in Connected_Device_Index_Type loop

            if not Connected_Device_Radio_Array (Device_Index).Active then

               Connected_Device_Radio_Array (Device_Index) :=
                 Connected_Device_Type'
                   (Identifier => Packet.Source, Active => True,
                    Time       => Ada.Real_Time.Clock);

               -- add the device to the device address array
               for Device_Address_Index in Device_Address_Index_Type loop

                  if Device_Address_Radio_Array (Device_Address_Index)
                      .Identifier =
                    0
                  then

                     Ada.Text_IO.Put_Line
                       ("Add Radio IP:" &
                        Source_Address_Port.Address (1)'Image & "." &
                        Source_Address_Port.Address (2)'Image & "." &
                        Source_Address_Port.Address (3)'Image & "." &
                        Source_Address_Port.Address (4)'Image & " ID:" &
                        Packet.Source'Image);

                     Device_Address_Radio_Array (Device_Address_Index) :=
                       Device_Address_Type'
                         (Identifier => Packet.Source,
                          Address    => Source_Address_Port.Address);

                     return;

                  elsif Device_Address_Index = Device_Address_Index_Type'Last
                  then

                     -- exception
                     raise No_Space
                       with "No Space in Device Address Array (Radio)";

                  end if;

               end loop;

            elsif Device_Index = Connected_Device_Index_Type'Last then

               -- exception
               raise No_Space
                 with "No Space in Connected Device Array (Radio)";

            end if;

         end loop;

      else

         -- update the time
         for Device_Index in Connected_Device_Index_Type loop

            if Connected_Device_Radio_Array (Device_Index).Identifier =
              Packet.Source
            then

               Connected_Device_Radio_Array (Device_Index).Time :=
                 Ada.Real_Time.Clock;

               -- check the ip address
               for Device_Address_Index in Device_Address_Index_Type loop

                  if Device_Address_Radio_Array (Device_Address_Index)
                      .Identifier =
                    Packet.Source
                  then

                     -- check if the ip address has changed
                     if Device_Address_Radio_Array (Device_Address_Index)
                         .Address /=
                       Source_Address_Port.Address
                     then

                        Ada.Text_IO.Put_Line
                          ("Update Radio IP:" &
                           Source_Address_Port.Address (1)'Image & "." &
                           Source_Address_Port.Address (2)'Image & "." &
                           Source_Address_Port.Address (3)'Image & "." &
                           Source_Address_Port.Address (4)'Image & " ID:" &
                           Packet.Source'Image);

                        -- update the ip address
                        Device_Address_Radio_Array (Device_Address_Index)
                          .Address :=
                          Source_Address_Port.Address;

                     end if;

                     return;

                  elsif Device_Address_Index = Device_Address_Index_Type'Last
                  then

                     -- exception
                     raise No_Space with "Device Address Not Found (Radio)";

                  end if;

               end loop;

            elsif Device_Index = Connected_Device_Index_Type'Last then

               -- exception
               raise No_Space with "Device Not Found (Radio)";

            end if;

         end loop;

      end if;

   end Process_Alive_Packet;

   procedure Send_Packet (Packet : Packet_Type) is
      Destination_Address : Drivers.Ethernet.Address_V4_Type := (127, 0, 0, 1);
      Destination_Port    : Drivers.Ethernet.Port_Type       := 3_000;

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
            Hardware.Radio.Send
              (Address => Destination_Address, Port => Destination_Port,
               Data    => New_Data, Last => Last);

         else

            -- lookup the ip
            Lookup_Address
              (Packet.Target, Device_Address_Cloud_Array, Destination_Address);

            -- send the packet
            Hardware.Radio.Send
              (Address => Destination_Address, Port => Destination_Port,
               Data    => New_Data, Last => Last);

         end if;

      else

         -- send the packet on radio multicast
         Hardware.Radio.Send
           (Address => Hardware.Radio.Multicast_Address.all,
            Port    => Destination_Port, Data => New_Data, Last => Last);

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

   procedure Cleanup_Connected_Device_Array is
      Device_Timeout : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Seconds (2);
      Current_Time   : Ada.Real_Time.Time;
      Timeout_Time   : Ada.Real_Time.Time;

      No_Space : exception;

      use type Ada.Real_Time.Time;
   begin

      -- loop through the connected device array (radio)
      for Device_Index in Connected_Device_Index_Type loop

         -- check if the device is active
         if Connected_Device_Radio_Array (Device_Index).Active then

            -- get the current time
            Current_Time := Ada.Real_Time.Clock;

            -- get the timeout time
            Timeout_Time :=
              Connected_Device_Radio_Array (Device_Index).Time +
              Device_Timeout;

            -- check if the device has timed out
            if Current_Time > Timeout_Time then

               Ada.Text_IO.Put_Line
                 ("Remove Radio ID:" &
                  Connected_Device_Radio_Array (Device_Index).Identifier'
                    Image);

               -- remove the device from the device address array
               for Device_Address_Index in Device_Address_Index_Type loop

                  if Device_Address_Radio_Array (Device_Address_Index)
                      .Identifier =
                    Connected_Device_Radio_Array (Device_Index).Identifier
                  then

                     -- remove the device from the device address array
                     Device_Address_Radio_Array (Device_Address_Index) :=
                       Device_Address_Default;

                     -- remove the device from the connected device array
                     Connected_Device_Radio_Array (Device_Index) :=
                       Connected_Device_Default;

                  elsif Device_Address_Index = Device_Address_Index_Type'Last
                  then

                     -- exception
                     raise No_Space with "Device Address Not Found (Radio)";

                  end if;

               end loop;

            end if;

         end if;

      end loop;

      -- loop through the connected device array (cloud)
      for Device_Index in Connected_Device_Index_Type loop

         -- check if the device is active
         if Connected_Device_Cloud_Array (Device_Index).Active then

            -- get the current time
            Current_Time := Ada.Real_Time.Clock;

            -- get the timeout time
            Timeout_Time :=
              Connected_Device_Cloud_Array (Device_Index).Time +
              Device_Timeout;

            -- check if the device has timed out
            if Current_Time > Timeout_Time then

               Ada.Text_IO.Put_Line
                 ("Remove Cloud ID:" &
                  Connected_Device_Cloud_Array (Device_Index).Identifier'
                    Image);

               -- remove the device from the device address array
               for Device_Address_Index in Device_Address_Index_Type loop

                  if Device_Address_Cloud_Array (Device_Address_Index)
                      .Identifier =
                    Connected_Device_Cloud_Array (Device_Index).Identifier
                  then

                     -- remove the device from the device address array
                     Device_Address_Cloud_Array (Device_Address_Index) :=
                       Device_Address_Default;

                     -- remove the device from the connected device array
                     Connected_Device_Cloud_Array (Device_Index) :=
                       Connected_Device_Default;

                  elsif Device_Address_Index = Device_Address_Index_Type'Last
                  then

                     -- exception
                     raise No_Space with "Device Address Not Found (Cloud)";

                  end if;

               end loop;

            end if;

         end if;

      end loop;

   end Cleanup_Connected_Device_Array;

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

end Network;
