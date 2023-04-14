with Ada.Text_IO;

with Application.State;

with Types.Physics;

package body Application.Estimation is

   procedure Estimate_State;

   procedure Initialize is
   begin

      null;

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

      Time_Since_Last_Estimate_State_Exectution : Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Clock - Last_Estimate_State_Exectution;

      Time_Delta : Duration :=
        Ada.Real_Time.To_Duration (Time_Since_Last_Estimate_State_Exectution);

      Displacement : Types.Physics.Displacement_Vector_Type;
   begin
      -- calculate the velocity
      Application.State.Current_State.Physical_State.Velocity :=
        Types.Physics."*"
          (Application.State.Current_State.Physical_State.Acceleration,
           Time_Delta);

      -- calculate the displacement
      Displacement :=
        Types.Physics."*"
          (Application.State.Current_State.Physical_State.Velocity,
           Time_Delta);

      -- update the position
      Application.State.Current_State.Physical_State.Position :=
        Types.Physics."+"
          (Application.State.Current_State.Physical_State.Position,
           Displacement);

      -- update the last execution time
      Last_Estimate_State_Exectution := Ada.Real_Time.Clock;

   end Estimate_State;

end Application.Estimation;
