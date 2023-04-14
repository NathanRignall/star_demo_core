with Types.Physics;

package Application.State is

   type Physical_State_Type is record
      Position                    : Types.Physics.Position_Type;
      Acceleration_Vector         : Types.Physics.Acceleration_Vector_Type;
      Velocity_Vector             : Types.Physics.Velocity_Vector_Type;
      Rotation_Vector             : Types.Physics.Rotation_Vector_Type;
      Angular_Velocity_Vector     : Types.Physics.Angular_Velocity_Vector_Type;
      Angular_Acceleration_Vector : Types.Physics
        .Angular_Acceleration_Vector_Type;
   end record;

   type State_Type is record
      Physical_State : Physical_State_Type;
   end record;

   Current_State : State_Type :=
     State_Type'
       (Physical_State =>
          Physical_State_Type'
            (Position                    =>
               Types.Physics.Position_Type'
                 (Latitude => 45.0, Longitude => 40.0, Altitude => 1_000.0),
             Acceleration_Vector         =>
               Types.Physics.Acceleration_Vector_Type'(100.0, 0.0, 0.0),
             Velocity_Vector             =>
               Types.Physics.Velocity_Vector_Type'(10.0, 0.0, 0.0),
             Rotation_Vector             =>
               Types.Physics.Rotation_Vector_Type'(0.0, 0.0, 0.0),
             Angular_Velocity_Vector     =>
               Types.Physics.Angular_Velocity_Vector_Type'(0.0, 0.0, 0.0),
             Angular_Acceleration_Vector =>
               Types.Physics.Angular_Acceleration_Vector_Type'
                 (0.0, 0.0, 0.0)));

end Application.State;
