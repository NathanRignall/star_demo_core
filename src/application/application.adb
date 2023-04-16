with Ada.Environment_Variables;

with Application.Control;
with Application.Estimation;
with Application.State;

with Hardware;
with Drivers.Ethernet;

with types.Physics;

package body Application is

   procedure Initialize is

      -- load the environment variables
      Device_Identifier_Env : constant String :=
        Ada.Environment_Variables.Value ("DEVICE_IDENTIFIER");

      Radio_Multicast_Address_Env : constant String :=
        Ada.Environment_Variables.Value ("RADIO_MULTICAST_ADDRESS");

      Cloud_Server_Address_Env : constant String :=
        Ada.Environment_Variables.Value ("CLOUD_SERVER_ADDRESS");

      Latitude_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_LATITUDE");

      Longitude_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_LONGITUDE");

      Velocity_X_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_VELOCITY_X");

      Velocity_Y_Env : constant String :=
        Ada.Environment_Variables.Value ("INITIAL_VELOCITY_Y");

      -- create the device identifier
      Device_Identifier : constant Library.Network.Device_Identifier_Type :=
        Library.Network.Device_Identifier_Type'Value (Device_Identifier_Env);

      -- create the addresses using the environment variables
      Radio_Multicast_Address : constant Drivers.Ethernet.Address_V4_Type :=
        Drivers.Ethernet.Address_V4_Type'
          ((1 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Radio_Multicast_Address_Env (1 .. 3)),
            2 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Radio_Multicast_Address_Env (5 .. 7)),
            3 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Radio_Multicast_Address_Env (9 .. 11)),
            4 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Radio_Multicast_Address_Env (13 .. 15))));

      Cloud_Server_Address : constant Drivers.Ethernet.Address_V4_Type :=
        Drivers.Ethernet.Address_V4_Type'
          ((1 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Cloud_Server_Address_Env (1 .. 3)),
            2 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Cloud_Server_Address_Env (5 .. 7)),
            3 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Cloud_Server_Address_Env (9 .. 11)),
            4 =>
              Drivers.Ethernet.Address_Octet_Type'Value
                (Cloud_Server_Address_Env (13 .. 15))));

   begin

      -- load the initial values on the state
      Application.State.Core_State.Physical_State.Position.Latitude :=
        Types.Physics.Latitude_Type'Value (Latitude_Env);
      
      Application.State.Core_State.Physical_State.Position.Longitude :=
         Types.Physics.Longitude_Type'Value (Longitude_Env);

      Application.State.Core_State.Physical_State.Velocity_Vector(Types.Physics.X) :=
         Types.Physics.Velocity_Type'Value (Velocity_X_Env);

      Application.State.Core_State.Physical_State.Velocity_Vector(Types.Physics.Y) :=
         Types.Physics.Velocity_Type'Value (Velocity_Y_Env);

      -- initialize demo applications
      Application.Estimation.Initialize;
      Application.Control.Initialize;

      -- create the applications
      Network   :=
        new Library.Network.Network_Type
          (Device_Identifier => Device_Identifier, Radio => Hardware.Radio,
           Cloud             => Hardware.Cloud);
      Telemetry := new Library.Telemetry.Telemetry_Type (Network => Network);

      -- initialize the applications
      Network.Initialize
        (Radio_Multicast_Address => Radio_Multicast_Address,
         Cloud_Server_Address    => Cloud_Server_Address);
      Telemetry.Initialize;

   end Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type) is
   begin

      -- schedule demo applications
      Estimation.Schedule (Cycle);
      Control.Schedule (Cycle);

      -- schedule the applications
      Network.Schedule (Cycle);
      Telemetry.Schedule (Cycle);

   end Schedule;

end Application;
