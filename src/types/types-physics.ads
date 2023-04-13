package Types.Physics is

    type Bearing_Type is digits 7;

    type Position_Type is record
        Longitude : Bearing_Type;
        Latitude  : Bearing_Type;
    end record;

    type Altitude_Type is digits 7;

    type Axis_Type is (X, Y, Z);

    type Acceleration_Type is digits 7 range -1000.0 .. 1000.0;
    type Acceleration_Vector_Type is array (Axis_Type) of Acceleration_Type;

    type Velocity_Type is digits 7 range -1000.0 .. 1000.0;
    type Velocity_Vector_Type is array (Axis_Type) of Velocity_Type;

    type Rotation_Type is digits 7 range -180.0 .. 180.0;
    type Rotation_Vector_Type is array (Axis_Type) of Rotation_Type;

    -- constants
    Gravity : constant float := 9.80665;
    Earth_Circumference : constant float := 40075000.0;

    -- conversion constants
    Degrees_Per_Meter : constant float := 360.0 / Earth_Circumference;

end Types.Physics;
