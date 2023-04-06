with Drivers.Ethernet;
with Drivers.Radio;

package Hardware is

   Local_Address      : Drivers.Ethernet.Address_V4_Access_Type :=
     new Drivers.Ethernet.Address_V4_Type'(127, 0, 0, 1);
   Broadcast_Adddress : Drivers.Ethernet.Address_V4_Access_Type :=
     new Drivers.Ethernet.Address_V4_Type'(127, 0, 0, 2);

   Ethernet :
     Drivers.Ethernet.Ethernet (Local_Address, 3_000, Broadcast_Adddress);
   Radio    :
     Drivers.Ethernet.Ethernet (Local_Address, 3_001, Broadcast_Adddress);

   procedure Initialize;

end Hardware;
