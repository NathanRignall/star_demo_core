package State is

    type Bearing_Type is digits 7;

    type Position_Type is record
        Longitude : Bearing_Type;
        Latitude  : Bearing_Type;
    end record;

    type Altitude_Type is range 0 .. 1_000;

    type Axis_Type is (X, Y, Z);

    type Acceleration_Type is range -100 .. 100;
    type Acceleration_Vector_Type is array (Axis_Type) of Acceleration_Type;

    type Velocity_Type is range -100 .. 100;
    type Velocity_Vector_Type is array (Axis_Type) of Velocity_Type;

    type Rotation_Type is range -180 .. 180;
    type Rotation_Vector_Type is array (Axis_Type) of Rotation_Type;

    type Physical_State_Type is record
        Position     : Position_Type;
        Altitude     : Altitude_Type;
        Acceleration : Acceleration_Vector_Type;
        Velocity     : Velocity_Vector_Type;
        Rotation     : Rotation_Vector_Type;
    end record;

    type State_Type is record
        Physical_State : Physical_State_Type;
    end record;

    Current_State : State_Type;
    Previous_State : State_Type;

end State;
