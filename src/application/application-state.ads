with Types.Physics;

package Application.State is

   type Physical_State_Type is record
      Position     : Types.Physics.Position_Type;
      Acceleration : Types.Physics.Acceleration_Vector_Type;
      Velocity     : Types.Physics.Velocity_Vector_Type;
      Rotation     : Types.Physics.Rotation_Vector_Type;
   end record;

   type State_Type is record
      Physical_State : Physical_State_Type;
   end record;

   Current_State : State_Type :=
     State_Type'
       (Physical_State =>
          Physical_State_Type'
            (Position     =>
               Types.Physics.Position_Type'
                 (Latitude => 100.0, Longitude => 40.0, Altitude => 1000.0),
             Acceleration =>
               Types.Physics.Acceleration_Vector_Type'(100.0, 0.0, 0.0),
             Velocity => Types.Physics.Velocity_Vector_Type'(0.0, 0.0, 0.0),
             Rotation => Types.Physics.Rotation_Vector_Type'(0.0, 0.0, 0.0)));

end Application.State;
