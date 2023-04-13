with Config;
with Control;
with Estimation;
with Hardware;
with Network;
with State;

procedure Star_Demo_Core is
begin

   Config.Initialize;
   Hardware.Initialize;
   Network.Initialize;

   delay 2.0;

   loop

      Estimation.Schedule;
      Control.Schedule;
      Network.Schedule;

      delay 0.1;

   end loop;

end Star_Demo_Core;
