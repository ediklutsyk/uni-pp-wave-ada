-- CountDownLatch.adb
with Ada.Text_IO; use Ada.Text_IO;

package Barrier is
      protected type Count_Down_Latch (TaskAmount : Natural) is
            entry Await;
            procedure CountDown;
            procedure Reset(TaskAmount : Natural);
      private
            Count : Natural := TaskAmount;
      end Count_Down_Latch;
end;
