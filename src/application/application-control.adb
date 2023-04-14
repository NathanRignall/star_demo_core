with Ada.Text_IO;

package body Application.Control is

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Control Initialize");

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is

         when others =>
            null;
            
      end case;

   end Schedule;

end Application.Control;
