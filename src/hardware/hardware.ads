with Drivers.Ethernet;
with Drivers.Radio;

package Hardware is

   Local_Address : Drivers.Ethernet.Address_V4_Access_Type := new Drivers.Ethernet.Address_V4_Type'(0, 0, 0, 0);

   Ethernet : Drivers.Ethernet.Ethernet (Local_Address, 3_000);
   Radio : Drivers.Ethernet.Ethernet (Local_Address, 3_001);

   procedure Initialize;

end Hardware;
