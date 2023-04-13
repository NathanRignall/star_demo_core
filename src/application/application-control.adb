with Application.Network;

package body Application.Control is

   procedure Initialize is
   begin

      null;

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is
         when others =>
            null;
      end case;

   end Schedule;

end Application.Control;
