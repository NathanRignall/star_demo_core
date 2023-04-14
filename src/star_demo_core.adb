with Ada.Exceptions;
with Ada.Real_Time;
with Ada.Text_IO;

with Hardware;
with Application;

with Types.Physics;
with Types.Schedule;

procedure Star_Demo_Core is

   use type Ada.Real_Time.Time;

   task Schedule;

   procedure Dispatch_Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      Hardware.Schedule (Cycle);
      Application.Schedule (Cycle);

   end Dispatch_Schedule;

   task body Schedule is
      Cycle_Delay : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds (20);

      Start_Delay : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Milliseconds (3_000);
      Next        : Ada.Real_Time.Time := Ada.Real_Time.Clock + Start_Delay;

      type Cycle_Count is range 1 .. 250;
      Cycle : Cycle_Count := Cycle_Count'First;

   begin

      Ada.Text_IO.Put_Line ("Starting Schedule");

      Hardware.Initialize;
      Application.Initialize;

      loop
         delay until Next;

         -- run 20ms cycle
         Dispatch_Schedule (Types.Schedule.S_20ms);

         -- chek if 50ms cycle is due
         if Cycle mod 2 = 0 then
            Dispatch_Schedule (Types.Schedule.S_50ms);
         end if;

         -- check if 100ms cycle is due
         if Cycle mod 5 = 0 then
            Dispatch_Schedule (Types.Schedule.S_100ms);
         end if;

         -- check if 200ms cycle is due
         if Cycle mod 10 = 0 then
            Dispatch_Schedule (Types.Schedule.S_200ms);
         end if;

         -- check if 500ms cycle is due
         if Cycle mod 25 = 0 then
            Dispatch_Schedule (Types.Schedule.S_500ms);
         end if;

         -- check if 1s cycle is due
         if Cycle mod 50 = 0 then
            Dispatch_Schedule (Types.Schedule.S_1000ms);
         end if;

         -- check if 2s cycle is due
         if Cycle mod 100 = 0 then
            Dispatch_Schedule (Types.Schedule.S_2000ms);
         end if;

         -- check if 5s cycle is due
         if Cycle mod 250 = 0 then
            Dispatch_Schedule (Types.Schedule.S_5000ms);
         end if;

         -- update cycle counter if not at end
         if Cycle < Cycle_Count'Last then
            Cycle := Cycle + 1;
         else
            Cycle := Cycle_Count'First;
         end if;

         -- update next time
         Next := Next + Cycle_Delay;

         if Next < Ada.Real_Time.Clock then
            Ada.Text_IO.Put_Line ("Schedule overrun in cycle counter " & Cycle'Image);
         end if;

      end loop;

   exception

      when Exep : others =>
         Ada.Text_IO.Put_Line ("Exception");
         Ada.Text_IO.Put_Line (Ada.Exceptions.Exception_Message(Exep));

   end Schedule;

begin

   null;

   Ada.Text_IO.Put_Line ("Longitude_Type requires " & Integer'Image (Types.Physics.Longitude_Type'Size) & " bits");
   Ada.Text_IO.Put_Line ("The delta value of Longitude_Type is " & Types.Physics.Longitude_Type'Image (Types.Physics.Longitude_Type'Delta));
   Ada.Text_IO.Put_Line ("The minimum value of Longitude_Type is " & Types.Physics.Longitude_Type'Image (Types.Physics.Longitude_Type'First));
   Ada.Text_IO.Put_Line ("The maximum value of Longitude_Type is " & Types.Physics.Longitude_Type'Image (Types.Physics.Longitude_Type'Last));

end Star_Demo_Core;
