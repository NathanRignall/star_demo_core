with Dotenv;
with Ada.Environment_Variables;
with Ada.Text_IO;

with Network;

package body Config is

   procedure Load_Config;

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Config Initialize");

      Dotenv.Config;

      Load_Config;

   end Initialize;

   procedure Load_Config is
      Device_Identifier : constant String :=
        Ada.Environment_Variables.Value ("DEVICE_IDENTIFIER");
   begin

      Network.Device_Identifier :=
        Network.Device_Identifier_Type'Value (Device_Identifier);

   end Load_Config;

end Config;
