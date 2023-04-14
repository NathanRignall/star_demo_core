with Drivers.Ethernet;

with Types.Schedule;

package Hardware is

   Radio_Address           : Drivers.Ethernet.Address_V4_Access_Type :=
     new Drivers.Ethernet.Address_V4_Type'(0, 0, 0, 0);
   Radio_Multicast_Address : Drivers.Ethernet.Address_V4_Access_Type :=
     new Drivers.Ethernet.Address_V4_Type'(255, 255, 255, 255);

   Cloud_Address           : Drivers.Ethernet.Address_V4_Access_Type :=
     new Drivers.Ethernet.Address_V4_Type'(0, 0, 0, 0);
   Cloud_Multicast_Address : Drivers.Ethernet.Address_V4_Access_Type :=
     new Drivers.Ethernet.Address_V4_Type'(255, 255, 255, 255);

   Radio :
     Drivers.Ethernet.Ethernet (Radio_Address, 3_000, Radio_Multicast_Address);

   Cloud :
     Drivers.Ethernet.Ethernet (Cloud_Address, 4_000, Cloud_Multicast_Address);

   procedure Initialize;

   procedure Schedule (Cycle : Types.Schedule.Cycle_Type);

end Hardware;
