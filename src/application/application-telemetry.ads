package Application.Telemetry is

   type Variant_Type is (Debug, Location);
   Variant_Default : constant Variant_Type := Debug;

   type Debug_Type is record

      null;

   end record;

   type Float_Type is digits 7;
   for Float_Type'Size use 64;
   Float_Default : constant Float_Type := 0.0;

   type Position_Type is record
      Longitude : Float_Type;
      Latitude  : Float_Type;
      Altitude  : Float_Type;
   end record;
   for Position_Type use record
      Longitude at 0 * 16 range 0 .. 63;
      Latitude  at 1 * 16 range 0 .. 63;
      Altitude  at 2 * 16 range 0 .. 63;
   end record;
   for Position_Type'Size use 320;
   Position_Default : constant Position_Type := Position_Type'(0.0, 0.0, 0.0);

   type Location_Type is record
      Position : Position_Type;
   end record;
   for Location_Type use record
      Position at 0 * 16 range 0 .. 319;
   end record;
   for Location_Type'Size use 320;
   Location_Default : constant Location_Type :=
     Location_Type'(Position => Position_Default);

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
      Location at 1 * 16 range 0 .. 319;
   end record;
   for Telemetry_Packet_Type'Size use 448;
   Telemetry_Packet_Default :
     constant Telemetry_Packet_Type (Location) :=
     Telemetry_Packet_Type'(Variant => Location, Location => Location_Default);

   procedure Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type);

end Application.Telemetry;
