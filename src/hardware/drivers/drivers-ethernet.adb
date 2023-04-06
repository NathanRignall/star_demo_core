package body Drivers.Ethernet is

   procedure Initialize (This : in out Ethernet) is
      Server_Address : GNAT.Sockets.Sock_Addr_Type;
   begin

      -- set the server address
      Server_Address :=
        GNAT.Sockets.Sock_Addr_Type'
          (Family => GNAT.Sockets.Family_Inet,
           Addr   =>
             GNAT.Sockets.Inet_Addr_Type'
               (Family => GNAT.Sockets.Family_Inet,
                Sin_V4 =>
                  GNAT.Sockets.Inet_Addr_V4_Type'
                    (1 => GNAT.Sockets.Inet_Addr_Comp_Type (This.Address (1)),
                     2 => GNAT.Sockets.Inet_Addr_Comp_Type (This.Address (2)),
                     3 => GNAT.Sockets.Inet_Addr_Comp_Type (This.Address (3)),
                     4 =>
                       GNAT.Sockets.Inet_Addr_Comp_Type (This.Address (4)))),
           Port   => GNAT.Sockets.Port_Type (This.Port));

      -- create the socket
      GNAT.Sockets.Create_Socket
        (This.Socket, GNAT.Sockets.Family_Inet, GNAT.Sockets.Socket_Datagram);

      -- create a selector
      GNAT.Sockets.Create_Selector (This.Selector);

      -- bind the socket to the address
      GNAT.Sockets.Bind_Socket (This.Socket, Server_Address);

   end Initialize;

   procedure Send
     (This :     Ethernet; Address : Address_V4_Type; Port : Port_Type;
      Data :     Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset)
   is
      Destination_Address : GNAT.Sockets.Sock_Addr_Type;
   begin

      -- set the destination address
      Destination_Address :=
        GNAT.Sockets.Sock_Addr_Type'
          (Family => GNAT.Sockets.Family_Inet,
           Addr   =>
             GNAT.Sockets.Inet_Addr_Type'
               (Family => GNAT.Sockets.Family_Inet,
                Sin_V4 =>
                  GNAT.Sockets.Inet_Addr_V4_Type'
                    (1 => GNAT.Sockets.Inet_Addr_Comp_Type (Address (1)),
                     2 => GNAT.Sockets.Inet_Addr_Comp_Type (Address (2)),
                     3 => GNAT.Sockets.Inet_Addr_Comp_Type (Address (3)),
                     4 => GNAT.Sockets.Inet_Addr_Comp_Type (Address (4)))),
           Port   => GNAT.Sockets.Port_Type (Port));

      -- send the data
      GNAT.Sockets.Send_Socket (This.Socket, Data, Last, Destination_Address);

   end Send;

   procedure Receive
     (This :     Ethernet; Address : out Address_V4_Type; Port : out Port_Type;
      Data : out Ada.Streams.Stream_Element_Array;
      Last : out Ada.Streams.Stream_Element_Offset)
   is
      Source_Address : GNAT.Sockets.Sock_Addr_Type;
   begin

      -- get the data
      GNAT.Sockets.Receive_Socket (This.Socket, Data, Last, Source_Address);

      -- set the source address
      Address :=
        Address_V4_Type'
          (1 => Address_Octet_Type (Source_Address.Addr.Sin_V4 (1)),
           2 => Address_Octet_Type (Source_Address.Addr.Sin_V4 (2)),
           3 => Address_Octet_Type (Source_Address.Addr.Sin_V4 (3)),
           4 => Address_Octet_Type (Source_Address.Addr.Sin_V4 (4)));

      Port := Port_Type (Source_Address.Port);

   end Receive;

   function Is_New_Data (This : Ethernet) return Boolean is
      R_Socket_Set : GNAT.Sockets.Socket_Set_Type;
      W_Socket_Set : GNAT.Sockets.Socket_Set_Type;

      Status  : GNAT.Sockets.Selector_Status;
      Timeout : Duration := 0.0;

      use type GNAT.Sockets.Selector_Status;
   begin

      GNAT.Sockets.Set (R_Socket_Set, This.Socket);

      -- check the selector
      GNAT.Sockets.Check_Selector
        (This.Selector, R_Socket_Set, W_Socket_Set, Status, Timeout);

      -- return the result
      return Status = GNAT.Sockets.Completed;

   end Is_New_Data;

end Drivers.Ethernet;
