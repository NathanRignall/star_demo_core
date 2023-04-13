with Ada.Real_Time;

with Types.Schedule;

package Application.Estimation is

   Last_Estimate_State_Exectution : Ada.Real_Time.Time := Ada.Real_Time.Clock;

   procedure Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type);

end Application.Estimation;
