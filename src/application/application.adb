with Ada.Text_IO;

with Application.Control;
with Application.Estimation;
with Application.Network;
with Application.Telemetry;

package body Application is

   procedure Initialize is
   begin

      Application.Estimation.Initialize;
      Application.Control.Initialize;
      Application.Telemetry.Initialize;
      Application.Network.Initialize;

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      Estimation.Schedule (Cycle);
      Control.Schedule (Cycle);
      Telemetry.Schedule (Cycle);
      Network.Schedule (Cycle);

   end Schedule;

end Application;
