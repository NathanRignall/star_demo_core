package Types.Physics is

   type Longitude_Type is delta 0.000_00_1 range -180.0 .. 180.0;
   type Latitude_Type is delta 0.000_00_1 range -90.0 .. 90.0;
   type Altitude_Type is delta 0.001 range -10_000.0 .. 40_000.0;

   type Position_Type is record
      Longitude : Longitude_Type;
      Latitude  : Latitude_Type;
      Altitude  : Altitude_Type;
   end record;

   type Axis_Type is (X, Y, Z);

   type Displacement_Type is delta 0.001 range -1_000.0 .. 1_000.0;
   type Displacement_Vector_Type is array (Axis_Type) of Displacement_Type;

   type Velocity_Type is delta 0.001 range -1_000.0 .. 1_000.0;
   type Velocity_Vector_Type is array (Axis_Type) of Velocity_Type;

   type Acceleration_Type is delta 0.001 range -1_000.0 .. 1_000.0;
   type Acceleration_Vector_Type is array (Axis_Type) of Acceleration_Type;

   type Rotation_Type is delta 0.001 range -1_000.0 .. 1_000.0;
   type Rotation_Vector_Type is array (Axis_Type) of Rotation_Type;

   type Angular_Velocity_Type is delta 0.001 range -1_000.0 .. 1_000.0;
   type Angular_Velocity_Vector_Type is array (Axis_Type) of Angular_Velocity_Type;

   type Angular_Acceleration_Type is delta 0.001 range -1_000.0 .. 1_000.0;
   type Angular_Acceleration_Vector_Type is array (Axis_Type) of Angular_Acceleration_Type;

   type Scientific is digits 15;

   -- constants
   Gravity : constant Scientific := 9.806_65;
   Pi      : constant Scientific := 3.141_592_653_589_793_238_46;

   -- earth constants
   Earth_Radius        : constant Scientific := 6_371_000.0;
   Earth_Circumference : constant Scientific := 2.0 * Pi * Earth_Radius;

   -- functions
   function "+"
     (Left : Position_Type; Right : Displacement_Vector_Type)
      return Position_Type;
   function "+"
     (Left : Displacement_Vector_Type; Right : Position_Type)
      return Position_Type;

   function "*"
     (Left : Velocity_Vector_Type; Right : Duration)
      return Displacement_Vector_Type;
   function "*"
     (Left : Duration; Right : Velocity_Vector_Type)
      return Displacement_Vector_Type;

   function "*"
     (Left : Acceleration_Vector_Type; Right : Duration)
      return Velocity_Vector_Type;
   function "*"
     (Left : Duration; Right : Acceleration_Vector_Type)
      return Velocity_Vector_Type;

end Types.Physics;
