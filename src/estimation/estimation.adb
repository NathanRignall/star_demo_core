with Ada.Text_IO;

with State;

with Types.Physics;

package body Estimation is

    procedure Estimate_State;

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
           Ada.Real_Time.To_Duration
              (Time_Since_Last_Estimate_State_Exectution);

        New_Position : Types.Physics.Position_Type;
        New_Velocity : Types.Physics.Velocity_Type;
    begin
        --  -- print the time since the last execution
        --  Ada.Text_IO.Put_Line ("Time delta: " & Time_Delta'Image);

        -- update the last execution time
        Last_Estimate_State_Exectution := Ada.Real_Time.Clock;

    end Estimate_State;

end Estimation;
