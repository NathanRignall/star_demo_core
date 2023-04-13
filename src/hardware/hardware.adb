with Ada.Text_IO;

package body Hardware is

   procedure Initialize is
   begin

      Ada.Text_IO.Put_Line ("Hardware Initialize");

      Radio.Initialize;
      Cloud.Initialize;
      
   end Initialize;

end Hardware;
