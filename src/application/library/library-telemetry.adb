with Ada.Text_IO;

with Application.State;

package body Library.Telemetry is

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

         when Types.Schedule.S_5000ms =>
            This.Send_Location;

         when others =>
            null;

      end case;

   end Schedule;

   procedure Send_Location (This : Telemetry_Type) is

      Telemetry_Packet : Telemetry_Packet_Type (Location);

      Payload_Length : Library.Network.Payload_Index_Type := 1_023;
      Payload        : Library.Network.Payload_Array_Type;
      for Payload'Address use Telemetry_Packet'Address;

      New_Packet : Library.Network.Packet_Type;

   begin

      New_Packet :=
        Library.Network.Packet_Type'
          (Packet_Variant => Library.Network.Telemetry, Packet_Number => 45,
           Source         => This.Network.Device_Identifier, Target => 0,
           Payload_Length => Payload_Length, Payload => Payload,
           Broadcast      => Library.Network.False);

      Telemetry_Packet.Location.Position := Application.State.Current_State.Physical_State.Position;

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

   end Send_Location;

end Library.Telemetry;
