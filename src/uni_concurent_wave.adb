with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Barrier; use Barrier;

procedure Uni_Concurent_Wave is
   TaskAmount : constant Integer := 10;
   ArrayLength : Integer := 1000_000_000;
   type WorkArrayType is array (Positive range <>) of Integer;
   WorkArray : constant access WorkArrayType := new WorkArrayType (1 .. ArrayLength);
   Latch : Count_Down_Latch (TaskAmount);
      
   task type Simple_Task (Index : Integer) is
      entry UpdateLength (Value : Integer);
   end Simple_Task;

   type Task_Ptr is access Simple_Task;
   Task_Array : array (1 .. TaskAmount) of Task_Ptr;

   task body Simple_Task is
      CurrentLength : Integer;
      TempIndex : Integer;
      IndexStep : Integer := 0;
   begin
      loop
         select
            accept UpdateLength (Value : Integer) do
               --  Put_Line("Get Length " & Integer'Image (Value) & " index: " & Integer'Image (Index));
               CurrentLength := Value;
            end UpdateLength;
            if Index > CurrentLength / 2 then
               --  Put_Line("Index is used: " & Integer'Image (Index));
               null;
            else
               IndexStep := 0;
               loop
                  TempIndex := Index + IndexStep * TaskAmount;
                  exit when TempIndex > CurrentLength / 2;
                  IndexStep := IndexStep + 1;
                  --  Put("Index: " & Integer'Image (Index) & ";");
                  --  Put("Value by Index: " & Integer'Image (WorkArray (TempIndex)) & ";");
                  --  Put_Line("Value by Index mirror: " & Integer'Image (WorkArray (CurrentLength - TempIndex + 1)) & ";");
                  WorkArray (TempIndex) := WorkArray (TempIndex) + WorkArray (CurrentLength - TempIndex + 1);
               end loop;
            end if;
            Latch.CountDown;
         or terminate;
         end select;
      end loop;
   end Simple_Task;

   Start_Time, End_Time : Time;
   Res_Duration : Duration;
begin
   Put_Line ("Initing array");
   Start_Time := Clock;
   for I in 1 .. ArrayLength loop
      WorkArray (I) := 1;
   end loop;
   End_Time := Clock;
   Put_Line ("Initing array took:" & Duration'Image (To_Duration (End_Time - Start_Time) * 1.0e3));
   Put_Line ("Starting");
   for I in 1 .. TaskAmount loop
      Task_Array (I) := new Simple_Task (Index => I);
   end loop;
   Start_Time := Clock;
   while ArrayLength > 1 loop
      for I in 1 .. TaskAmount loop
         Task_Array (I).UpdateLength (ArrayLength);
      end loop;
      Latch.Await;
      ArrayLength := ArrayLength / 2 + ArrayLength mod 2;
      Latch.Reset (TaskAmount);
   end loop;
   End_Time     := Clock;
   Res_Duration := To_Duration (End_Time - Start_Time) * 1.0e3;
   Put_Line (" Result: " & Integer'Image (WorkArray (1)));
   Put_Line (Duration'Image (Res_Duration) & " ms");

end Uni_Concurent_Wave;
