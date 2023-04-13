package body Control is

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      case Cycle is
         when others =>
            null;
      end case;

   end Schedule;

end Control;
