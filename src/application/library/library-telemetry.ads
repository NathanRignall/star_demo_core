with Library.Network;

with Types.Physics;
with Types.Schedule;

package Library.Telemetry is

   type Variant_Type is (Debug, Location);
   Variant_Default : constant Variant_Type := Debug;

   type Debug_Type is record

      null;

   end record;

   type Location_Type is record
      Position : Types.Physics.Position_Type;
      Velocity : Types.Physics.Velocity_Type;
      Rotation : Types.Physics.Rotation_Type;
   end record;
   for Location_Type use record
      Position at 0 * 16 range 0 .. 95;
      Velocity at 0 * 16 range 96 .. 117;
      Rotation at 0 * 16 range 118 .. 139;
   end record;
   for Location_Type'Size use 140;

   type Telemetry_Packet_Type (Variant : Variant_Type) is record
      case Variant is
         when Debug =>
            Debug : Debug_Type;
         when Location =>
            Location : Location_Type;
      end case;
   end record;
   for Telemetry_Packet_Type use record
      Variant  at 0 * 16 range 0 ..  15;
      Debug    at 1 * 16 range 0 ..  15;
      Location at 1 * 16 range 0 .. 139;
   end record;
   for Telemetry_Packet_Type'Size use 272;

   type Telemetry_Type (Network : Library.Network.Network_Access_Type) is
     tagged private;

   type Telemetry_Access_Type is access all Telemetry_Type;

   procedure Initialize (This : Telemetry_Type);

   procedure Schedule
     (This : Telemetry_Type; Cycle : Types.Schedule.Cycle_Type);

private

   type Telemetry_Type (Network : Library.Network.Network_Access_Type) is
   tagged record

      null;

   end record;

end Library.Telemetry;
