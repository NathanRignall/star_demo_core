with Ada.Text_IO;

with Application.State;

package body Library.Telemetry is

   procedure Process_Telemetry (This : Telemetry_Type);
   procedure Send_Location (This : Telemetry_Type);

   procedure Initialize (This : Telemetry_Type) is
   begin

      Ada.Text_IO.Put_Line ("Telemetry Initialize");

   end Initialize;

   procedure Schedule
     (This : Telemetry_Type; Cycle : Types.Schedule.Cycle_Type)
   is
   begin

      case Cycle is

         when Types.Schedule.S_20ms =>
            This.Process_Telemetry;

         when Types.Schedule.S_5000ms =>
            This.Send_Location;

         when others =>
            null;

      end case;

   end Schedule;

   procedure Process_Telemetry (This : Telemetry_Type) is
      Packet : Library.Network.Packet_Type;

      use type Library.Network.Packet_Type;

      Payload : Library.Network.Payload_Array_Type;
      Variant : Variant_Type;
      for Variant'Address use Payload'Address;

   begin

      for Index in 1 .. 20 loop

         Packet := This.Network.Get_Packet (Library.Network.Telemetry);

         Payload := Packet.Payload;

         -- check if packet is not default
         if Packet /= Library.Network.Packet_Default then

            declare
               Telemetry_Packet : Telemetry_Packet_Type (Variant);

               for Telemetry_Packet'Address use Payload'Address;
            begin

               Payload := Packet.Payload;

               -- check the packet variant
               case Variant is

                  when Location =>
                     Ada.Text_IO.Put_Line ("Source: " & Packet.Source'Image);

                     Ada.Text_IO.Put_Line
                       ("Telemetry Position:" &
                        Telemetry_Packet.Location.Position'Image);

                     Ada.Text_IO.Put_Line
                       ("Telemetry Velocity:" &
                        Telemetry_Packet.Location.Velocity_Vector'Image);

                  when others =>
                     Ada.Text_IO.Put_Line ("Telemetry Unknown");

               end case;

            end;

         else

            -- no more packets to process
            return;

         end if;

      end loop;

   end Process_Telemetry;

   procedure Send_Location (This : Telemetry_Type) is

      Payload_Length : Library.Network.Payload_Index_Type := 1_023;
      Payload        : Library.Network.Payload_Array_Type := (others => 0);

      Telemetry_Packet : Telemetry_Packet_Type (Location);
      for Telemetry_Packet'Address use Payload'Address;

      New_Packet : Library.Network.Packet_Type;

   begin

      Telemetry_Packet :=
        Telemetry_Packet_Type'
          (Variant  => Location,
           Location =>
             Location_Type'
               (Position => Types.Physics.Position_Default,
                Velocity_Vector => Types.Physics.Velocity_Vector_Default,
                Rotation_Vector => Types.Physics.Rotation_Vector_Default));

      Telemetry_Packet.Location.Position :=
        Application.State.Core_State.Physical_State.Position;

      Telemetry_Packet.Location.Velocity_Vector :=
         Application.State.Core_State.Physical_State.Velocity_Vector;

      Telemetry_Packet.Location.Rotation_Vector :=
         Application.State.Core_State.Physical_State.Rotation_Vector;

      New_Packet :=
        Library.Network.Packet_Type'
          (Packet_Variant => Library.Network.Telemetry, Packet_Number => 45,
           Source         => This.Network.Device_Identifier, Target => 0,
           Payload_Length => Payload_Length, Payload => Payload,
           Broadcast      => Library.Network.False);

      -- send telemetry packet to all devices on radio network
      for Device_Index in Library.Network.Connected_Device_Index_Type loop

         -- check if the device is active
         if This.Network.Get_Connected (Library.Network.Radio, Device_Index)
             .Active
         then

            -- set the target
            New_Packet.Target :=
              This.Network.Get_Connected (Library.Network.Radio, Device_Index)
                .Identifier;

            -- send the packet
            This.Network.Send_Packet (New_Packet);

         end if;

      end loop;

      -- send telemetry to cloud server (temporary solution)
      New_Packet.Target := 0;
      This.Network.Send_Packet (New_Packet);

   end Send_Location;

end Library.Telemetry;
