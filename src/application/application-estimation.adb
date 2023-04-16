with Ada.Environment_Variables;
with Ada.Text_IO;

with Application.State;

with Types.Physics;

package body Application.Estimation is

   procedure Estimate_State;

   procedure Initialize is

      -- load the environment variables
      Latitude_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_LATITUDE");

      Longitude_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_LONGITUDE");

      Velocity_X_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_VELOCITY_X");

      Velocity_Y_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_VELOCITY_Y");

   begin

      Ada.Text_IO.Put_Line ("Estimation Initialize");

      -- load the initial values on the state
      Application.State.Core_State.Physical_State.Position.Latitude :=
        Types.Physics.Latitude_Type'Value (Latitude_Env);
      
      Application.State.Core_State.Physical_State.Position.Longitude :=
         Types.Physics.Longitude_Type'Value (Longitude_Env);

      Application.State.Core_State.Physical_State.Velocity_Vector(Types.Physics.X) :=
         Types.Physics.Velocity_Type'Value (Velocity_X_Env);

      Application.State.Core_State.Physical_State.Velocity_Vector(Types.Physics.Y) :=
         Types.Physics.Velocity_Type'Value (Velocity_Y_Env);

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is

         when Types.Schedule.S_20ms =>
            Estimate_State;

         when others =>
            null;

      end case;

   end Schedule;

   procedure Estimate_State is
      use type Ada.Real_Time.Time_Span;

      Time_Since_Last_Estimate_State_Exectution :
        constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Clock - Last_Estimate_State_Exectution;

      Time_Delta : constant Duration :=
        Ada.Real_Time.To_Duration (Time_Since_Last_Estimate_State_Exectution);

      Displacement : Types.Physics.Displacement_Vector_Type;
   begin
      -- calculate the velocity
      Application.State.Core_State.Physical_State.Velocity_Vector :=
        Types.Physics."+"
          (Application.State.Core_State.Physical_State.Velocity_Vector,
           Types.Physics."*"
             (Application.State.Core_State.Physical_State.Acceleration_Vector,
              Time_Delta));

      -- calculate the displacement
      Displacement :=
        Types.Physics."*"
          (Application.State.Core_State.Physical_State.Velocity_Vector,
           Time_Delta);

      -- update the position
      Application.State.Core_State.Physical_State.Position :=
        Types.Physics."+"
          (Application.State.Core_State.Physical_State.Position, Displacement);

      -- update the last execution time
      Last_Estimate_State_Exectution := Ada.Real_Time.Clock;

   end Estimate_State;

end Application.Estimation;
