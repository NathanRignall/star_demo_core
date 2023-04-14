with Ada.Text_IO;

with Application.State;
with Application.Network;

package body Application.Telemetry is

   procedure Send_Location;

   procedure Initialize is
   begin

      null;

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is

         when Types.Schedule.S_5000ms =>
            Send_Location;

         when others =>
            null;

      end case;

   end Schedule;

   procedure Send_Location is

      use type Application.Network.Payload_Index_Type;

      Telemetry_Packet : Telemetry_Packet_Type (Location);

      Payload_Length : Application.Network.Payload_Index_Type := 1_023;
      Payload        : Application.Network.Payload_Array_Type;
      for Payload'Address use Telemetry_Packet'Address;

      New_Packet : Application.Network.Packet_Type;

   begin

      New_Packet :=
        Application.Network.Packet_Type'
          (Packet_Variant => Application.Network.Telemetry,
           Packet_Number  => 45,
           Source => Application.Network.Device_Identifier, Target => 0,
           Payload_Length => Payload_Length, Payload => Payload,
           Broadcast      => Application.Network.False);

      Telemetry_Packet.Location.Position.Longitude :=
        Float_Type
          (Application.State.Current_State.Physical_State.Position.Longitude);
      Telemetry_Packet.Location.Position.Latitude  :=
        Float_Type
          (Application.State.Current_State.Physical_State.Position.Latitude);
      Telemetry_Packet.Location.Position.Altitude  :=
        Float_Type
          (Application.State.Current_State.Physical_State.Position.Altitude);

      -- send telemetry packet to all devices on radio network
      for Device_Index in Application.Network.Connected_Device_Index_Type loop

         -- check if the device is active
         if Application.Network.Connected_Device_Transport_Array
             (Application.Network.Radio)
             (Device_Index)
             .Active
         then

            -- set the target
            New_Packet.Target :=
              Application.Network.Connected_Device_Transport_Array
                (Application.Network.Radio)
                (Device_Index)
                .Identifier;

            -- send the packet
            Application.Network.Send_Packet (New_Packet);

         end if;

      end loop;

   end Send_Location;

end Application.Telemetry;
