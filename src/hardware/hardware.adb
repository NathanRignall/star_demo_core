with Ada.Text_IO;

package body Hardware is

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Hardware Initialize");

      Ethernet.Initialize;
      Radio.Initialize;

   end Initialize;

end Hardware;
