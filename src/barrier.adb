-- CountDownLatch.adb
with Ada.Text_IO; use Ada.Text_IO;

package body Barrier is
   protected body Count_Down_Latch is
      entry Await when Count = 0 is
         begin
            --  Put_Line("Await!");
            null; -- No action needed, just waiting for count to reach 0
      end Await;

      procedure CountDown is
         begin
            if Count > 0 then
               Count := Count - 1;
            end if;
      end CountDown;

      procedure Reset (TaskAmount : Natural) is
         begin
            Count := TaskAmount;
      end Reset;
   end Count_Down_Latch;
end Barrier;

