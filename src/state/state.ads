with Types.Physics;

package State is
    type Physical_State_Type is record
        Position     : Types.Physics.Position_Type;
        Altitude     : Types.Physics.Altitude_Type;
        Acceleration : Types.Physics.Acceleration_Vector_Type;
        Velocity     : Types.Physics.Velocity_Vector_Type;
        Rotation     : Types.Physics.Rotation_Vector_Type;
    end record;

    type State_Type is record
        Physical_State : Physical_State_Type;
    end record;

    Current_State : State_Type;
    Previous_State : State_Type;

end State;
